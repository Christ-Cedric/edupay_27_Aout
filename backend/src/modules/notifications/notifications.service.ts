import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { whatsAppProvider } from './providers/whatsapp-cloud-provider.js';
import { fcmProvider } from './providers/fcm-provider.js';
import { toNotificationDto } from './notifications.serializer.js';

export type NotificationType =
  | 'contribution_received'
  | 'contribution_failed'
  | 'goal_completed'
  | 'goal_threshold_70'       // 70 % atteint → commande déclenchable
  | 'goal_completed_admin'   // 100 % atteint → alerte admin spécifique
  | 'delivery_confirmed'
  | 'delivery_issue'
  | 'late_reminder'
  | 'account_approved'
  | 'account_rejected'
  | 'agent_assigned'
  | 'refund_processed'
  | 'family_archived'
  | 'family_updated_by_agent'
  | 'family_assigned_to_agent'
  | 'new_registration';

/**
 * Écrit toujours la ligne `Notification` (persistance in-app — source de
 * vérité de l'inbox, réussit toujours) PUIS tente WhatsApp ET push FCM en
 * parallèle, tous deux fire-and-forget. Un échec d'un canal (pas de config,
 * panne réseau) ne doit jamais faire échouer la transaction métier qui a
 * déclenché cette notif (encaissement, livraison...), ni empêcher l'autre
 * canal de partir.
 */
export async function notify(
  userId: string,
  type: NotificationType,
  title: string,
  body: string,
): Promise<void> {
  const notification = await prisma.notification.create({
    data: { userId, type, title, body, channel: 'whatsapp' },
  });
  dispatchWhatsApp(notification.id, userId, body).catch(() => {
    // dispatchWhatsApp gère déjà ses propres erreurs en interne (voir plus
    // bas) ; ce .catch est un filet de sécurité si jamais elle en laissait
    // échapper une, pour ne jamais remonter jusqu'à l'appelant métier.
  });
  dispatchPush(notification.id, userId, title, body).catch(() => {});
}

/** Notifie tous les admins (fire-and-forget, un `.catch` par envoi) — utilisé
 * quand l'événement n'a pas d'agent référent précis à prévenir (nouvelle
 * inscription en attente de traitement, incident sans agent assigné). */
export async function notifyAdmins(type: NotificationType, title: string, body: string): Promise<void> {
  const admins = await prisma.user.findMany({ where: { role: 'admin' }, select: { id: true } });
  for (const admin of admins) {
    notify(admin.id, type, title, body).catch(() => {});
  }
}

async function dispatchWhatsApp(notificationId: string, userId: string, body: string): Promise<void> {
  try {
    const user = await prisma.user.findUnique({ where: { id: userId }, select: { phone: true } });
    if (!user) return;

    const result = await whatsAppProvider.send(user.phone, body);
    await prisma.notification.update({
      where: { id: notificationId },
      data: result.success
        ? { sentAt: new Date() }
        : { error: result.reason ?? 'Échec inconnu.' },
    });
  } catch (err) {
    await prisma.notification
      .update({
        where: { id: notificationId },
        data: { error: err instanceof Error ? err.message : 'Échec inconnu.' },
      })
      .catch(() => {});
  }
}

/** Push FCM — tente tous les appareils enregistrés de l'utilisateur, purge
 * ceux que Firebase signale invalides/expirés (l'app a été désinstallée,
 * réinstallée sur un autre appareil, etc.). */
async function dispatchPush(notificationId: string, userId: string, title: string, body: string): Promise<void> {
  try {
    const devices = await prisma.deviceToken.findMany({ where: { userId }, select: { token: true } });
    const result = await fcmProvider.send(devices.map((d) => d.token), title, body);

    await prisma.notification.update({
      where: { id: notificationId },
      data: result.success
        ? { pushSentAt: new Date() }
        : { pushError: result.reason ?? 'Échec inconnu.' },
    });

    if (result.invalidTokens.length > 0) {
      await prisma.deviceToken.deleteMany({ where: { token: { in: result.invalidTokens } } });
    }
  } catch (err) {
    await prisma.notification
      .update({
        where: { id: notificationId },
        data: { pushError: err instanceof Error ? err.message : 'Échec inconnu.' },
      })
      .catch(() => {});
  }
}

/** Enregistre (ou réattribue, si déjà connu pour un autre compte — voir
 * schéma) le token FCM de l'appareil courant. */
export async function registerDeviceToken(userId: string, token: string, platform?: string): Promise<void> {
  await prisma.deviceToken.upsert({
    where: { token },
    create: { userId, token, platform: platform ?? null },
    update: { userId, platform: platform ?? null, lastUsedAt: new Date() },
  });
}

/** Retire un token — appelé à la déconnexion pour ne plus pousser vers un
 * appareil qui vient de se déconnecter. */
export async function unregisterDeviceToken(userId: string, token: string): Promise<void> {
  await prisma.deviceToken.deleteMany({ where: { userId, token } });
}

/** Inbox in-app de l'utilisateur connecté (parent ou agent), plus récentes d'abord. */
export async function listForUser(userId: string) {
  const notifications = await prisma.notification.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    take: 50,
  });
  return notifications.map(toNotificationDto);
}

export async function markRead(userId: string, notificationId: string) {
  const notification = await prisma.notification.findFirst({
    where: { id: notificationId, userId },
  });
  if (!notification) throw ApiError.notFound('Notification introuvable.');

  const updated = await prisma.notification.update({
    where: { id: notificationId },
    data: { readAt: new Date() },
  });
  return toNotificationDto(updated);
}
