import { Prisma, type Delivery, type DeliveryIssue, type DeliveryStatus } from '@prisma/client';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { currentSeasonId } from '../kits/kits.service.js';
import * as notificationsService from '../notifications/notifications.service.js';
import { toDeliveryDto, toDeliveryIssueDto } from './delivery.serializer.js';
import type {
  AdvanceStatusInput,
  ConfirmByAgentInput,
  ReportIssueInput,
  ScheduleDeliveryInput,
  SendLocationInput,
} from './delivery.schemas.js';

const withIssues = { issues: { orderBy: { createdAt: 'desc' as const } } };

// Ordre autorisé — progression seule, aucun retour arrière sans admin (même
// règle que le backend Client audité).
const ORDER: DeliveryStatus[] = ['preparation', 'shipped', 'outForDelivery', 'delivered', 'receiptConfirmed'];

/**
 * Refuse un changement de kit si la livraison de cet enfant a déjà dépassé
 * la préparation (expédiée et au-delà) — appelée par `admin.service.assignKit`
 * AVANT toute écriture. Décision produit (2026-07-28) : pas de flux de
 * retour/échange pour l'instant, donc un kit déjà en route ne peut plus être
 * changé depuis l'app ; un échange reste possible mais passe par un canal
 * manuel (agent/admin hors app), pas cette route.
 */
export async function assertKitChangeAllowed(childId: string): Promise<void> {
  const delivery = await prisma.delivery.findFirst({ where: { childId } });
  if (delivery && delivery.status !== 'preparation') {
    throw ApiError.conflict(
      'Ce kit est déjà en cours de livraison — impossible de le changer depuis l’app. Contactez un agent pour un échange.',
    );
  }
}

/**
 * Un kit = une livraison (§7 #2 : kit par enfant, pas par famille). Crée les
 * lignes manquantes pour les objectifs de la saison courante qui ont déjà un
 * kit choisi ET dont l'épargne est complète — un enfant encore en cotisation
 * n'a pas encore de kit à livrer.
 *
 * Une seule livraison par enfant à la fois : si l'enfant change de kit
 * avant que quoi que ce soit n'ait été physiquement préparé (livraison
 * encore `preparation`), la ligne existante est mise à jour vers le nouveau
 * kit plutôt que d'en créer une seconde. Le cas "livraison déjà expédiée"
 * ne devrait plus être atteignable en pratique (`assertKitChangeAllowed`
 * bloque `assignKit` en amont) — la branche ci-dessous ne touche
 * délibérément pas une ligne déjà avancée, filet de sécurité si jamais elle
 * est atteinte par un autre chemin.
 */
async function ensureDeliveriesForFamily(parentId: string): Promise<void> {
  const seasonId = await currentSeasonId();
  const goals = await prisma.savingsGoal.findMany({
    where: {
      parentId,
      seasonId,
      childId: { not: null },
      OR: [
        { kitId: { not: null } },
        { customAddedItems: { not: Prisma.DbNull } },
      ],
      AND: [
        {
          OR: [
            { status: 'completed' },
            { savedAmount: { gte: prisma.savingsGoal.fields.targetAmount } },
          ],
        },
      ],
    },
    select: {
      id: true,
      childId: true,
      kitId: true,
      customAddedItems: true,
    },
  });

  for (const goal of goals) {
    const childId = goal.childId!;
    const kitId = goal.kitId ?? (await ensureCustomKitGoal(goal));
    if (!kitId) continue;

    const existing = await prisma.delivery.findFirst({ where: { childId } });

    if (!existing) {
      await prisma.delivery.create({ data: { parentId, childId, kitId } });
    } else if (existing.kitId !== kitId && existing.status === 'preparation') {
      await prisma.delivery.update({ where: { id: existing.id }, data: { kitId } });
    }
  }
}

async function familyDeliveries(parentId: string): Promise<(Delivery & { issues: DeliveryIssue[] })[]> {
  return prisma.delivery.findMany({
    where: { parentId },
    include: withIssues,
    orderBy: { createdAt: 'asc' },
  });
}

export async function getDeliveries(parentId: string) {
  await ensureDeliveriesForFamily(parentId);
  const deliveries = await familyDeliveries(parentId);
  return deliveries.map(toDeliveryDto);
}

/** Détail d'une livraison par id — 404 si absente. L'appelant (agent) est
 * responsable de vérifier l'appartenance via `assertOwnFamily` avant d'appeler
 * cette fonction, comme pour `advanceDelivery`/`confirmDelivery`. */
export async function getById(deliveryId: string): Promise<ReturnType<typeof toDeliveryDto>> {
  const delivery = await prisma.delivery.findUnique({ where: { id: deliveryId }, include: withIssues });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');
  return toDeliveryDto(delivery);
}

/** Position envoyée par le parent — s'applique à toutes les livraisons non
 * encore confirmées de la famille (un seul lieu de livraison par visite). */
export async function sendLocation(parentId: string, input: SendLocationInput) {
  await ensureDeliveriesForFamily(parentId);
  await prisma.delivery.updateMany({
    where: { parentId, status: { not: 'receiptConfirmed' } },
    data: { locationLat: input.lat, locationLng: input.lng, address: input.address },
  });
  await writeAudit(prisma, {
    actorId: parentId,
    action: 'delivery.location_sent',
    entity: 'delivery',
    after: { parentId, lat: input.lat, lng: input.lng },
  });
  return getDeliveries(parentId);
}

/** Confirme la réception de toutes les livraisons `delivered` de la famille
 * en une fois (un seul signalement pour toute la visite). `signature` (base64,
 * tracé manuscrit du parent) est apposée sur chacune, comme `confirmByAgent`. */
export async function confirmReceipt(parentId: string, signature?: string) {
  const deliveries = await familyDeliveries(parentId);
  const ready = deliveries.filter((d) => d.status === 'delivered');
  if (ready.length === 0) {
    throw ApiError.businessRule(
      'DELIVERY_NOT_READY',
      'Aucune livraison à confirmer (rien au statut "livré").',
    );
  }

  await prisma.$transaction(async (tx) => {
    const now = new Date();
    await tx.delivery.updateMany({
      where: { id: { in: ready.map((d) => d.id) } },
      data: { status: 'receiptConfirmed', signedAt: now, signature: signature ?? null },
    });
    await writeAudit(tx, {
      actorId: parentId,
      action: 'delivery.receipt_confirmed',
      entity: 'delivery',
      after: { parentId, count: ready.length },
    });
  });

  return getDeliveries(parentId);
}

/** Signale un problème sur la livraison d'UN enfant précis. */
export async function reportIssue(parentId: string, input: ReportIssueInput) {
  const delivery = await prisma.delivery.findFirst({
    where: { parentId, childId: input.child_id },
  });
  if (!delivery) throw ApiError.notFound('Livraison introuvable pour cet enfant.');

  const issue = await prisma.deliveryIssue.create({
    data: {
      deliveryId: delivery.id,
      type: input.type,
      description: input.description,
      photoUrl: input.photo_url ?? null,
    },
  });
  await writeAudit(prisma, {
    actorId: parentId,
    action: 'delivery.issue_reported',
    entity: 'delivery_issue',
    entityId: issue.id,
    after: { deliveryId: delivery.id, type: input.type },
  });

  notifyIssueReported(delivery.parentId).catch(() => {});
  return toDeliveryIssueDto(issue);
}

/** Alerte l'agent référent de la famille (ou, à défaut, tous les admins) —
 * fire-and-forget, jamais dans la transaction métier. */
async function notifyIssueReported(deliveryParentId: string): Promise<void> {
  const family = await prisma.user.findUnique({
    where: { id: deliveryParentId },
    select: { assignedAgentId: true, fullName: true },
  });
  if (!family) return;

  const title = 'Incident livraison signalé';
  const body = `${family.fullName} a signalé un problème sur une livraison.`;

  if (family.assignedAgentId) {
    notificationsService.notify(family.assignedAgentId, 'delivery_issue', title, body).catch(() => {});
    return;
  }
  await notificationsService.notifyAdmins('delivery_issue', title, body);
}

/** Avance d'un cran la livraison d'UN enfant — réservé agent/admin. */
export async function advanceStatus(actorId: string, deliveryId: string, input: AdvanceStatusInput) {
  const delivery = await prisma.delivery.findUnique({ where: { id: deliveryId } });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');

  // Décision produit (2026-07-28) : même garde que les mouvements d'argent
  // (`payments.service.initiateContribution`) — un compte suspendu/rejeté/en
  // attente ne doit pas continuer à recevoir des biens physiques tant que sa
  // situation n'est pas réglée.
  const family = await prisma.user.findUnique({
    where: { id: delivery.parentId },
    select: { status: true },
  });
  if (family?.status !== 'active') {
    throw ApiError.forbidden(
      'Compte non actif — la livraison ne peut pas avancer tant que le compte n’est pas validé/réactivé.',
    );
  }

  const from = ORDER.indexOf(delivery.status);
  const next = ORDER.indexOf(input.to);
  if (next !== from + 1) {
    throw ApiError.businessRule(
      'INVALID_DELIVERY_TRANSITION',
      `Transition ${delivery.status} → ${input.to} interdite.`,
    );
  }

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.delivery.update({
      where: { id: deliveryId },
      data: { status: input.to },
      include: withIssues,
    });
    await writeAudit(tx, {
      actorId,
      action: 'delivery.status_advanced',
      entity: 'delivery',
      entityId: deliveryId,
      before: { status: delivery.status },
      after: { status: input.to },
    });
    return u;
  });

  if (input.to === 'delivered') {
    notificationsService
      .notify(
        delivery.parentId,
        'delivery_confirmed',
        'Livraison arrivée',
        'Votre kit scolaire est arrivé — confirmez la réception depuis l’app dès que possible.',
      )
      .catch(() => {});
  }

  return toDeliveryDto(updated);
}

/**
 * Confirmation par l'AGENT sur le terrain, avec signature capturée sur son
 * propre appareil — chemin alternatif à `confirmReceipt` (parent,
 * self-service). Fonctionne quel que soit le statut précédent (même avant
 * `delivered` : un agent peut tout boucler en une seule visite), tant que le
 * compte reste actif (même garde que `advanceStatus`). Équivalent de
 * `confirmLivraison` chez la référence Agent terrain.
 */
export async function confirmByAgent(
  actorId: string,
  deliveryId: string,
  input: ConfirmByAgentInput,
): Promise<ReturnType<typeof toDeliveryDto>> {
  const delivery = await prisma.delivery.findUnique({ where: { id: deliveryId } });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');

  if (delivery.status === 'receiptConfirmed') {
    throw ApiError.conflict('Cette livraison a déjà été confirmée.');
  }

  const family = await prisma.user.findUnique({
    where: { id: delivery.parentId },
    select: { status: true },
  });
  if (family?.status !== 'active') {
    throw ApiError.forbidden(
      'Compte non actif — la livraison ne peut pas être confirmée tant que le compte n’est pas validé/réactivé.',
    );
  }

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.delivery.update({
      where: { id: deliveryId },
      data: {
        status: 'receiptConfirmed',
        signedAt: new Date(),
        signature: input.signature ?? null,
      },
      include: withIssues,
    });
    await writeAudit(tx, {
      actorId,
      action: 'delivery.confirmed_by_agent',
      entity: 'delivery',
      entityId: deliveryId,
      before: { status: delivery.status },
      after: { status: 'receiptConfirmed', notes: input.notes ?? null },
    });
    return u;
  });

  notificationsService
    .notify(
      delivery.parentId,
      'delivery_confirmed',
      'Livraison confirmée',
      'Le kit scolaire a bien été remis par votre agent. Merci de votre confiance !',
    )
    .catch(() => {});

  return toDeliveryDto(updated);
}

/** Planifie la date de passage (« livraisons du jour ») — agent ou admin. */
export async function schedule(
  actorId: string,
  deliveryId: string,
  input: ScheduleDeliveryInput,
): Promise<ReturnType<typeof toDeliveryDto>> {
  const delivery = await prisma.delivery.findUnique({ where: { id: deliveryId }, include: withIssues });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');

  const updated = await prisma.delivery.update({
    where: { id: deliveryId },
    data: { scheduledAt: new Date(input.scheduled_at) },
    include: withIssues,
  });
  await writeAudit(prisma, {
    actorId,
    action: 'delivery.scheduled',
    entity: 'delivery',
    entityId: deliveryId,
    after: { scheduledAt: input.scheduled_at },
  });
  return toDeliveryDto(updated);
}

/**
 * Livraisons des familles assignées à cet agent (`assignedAgentId` sur la
 * famille — pas `Delivery.assignedAgentId`, qui reste un champ libre non
 * utilisé par ce chantier), filtrables par date de passage prévue et statut
 * — équivalent de leur écran « livraisons du jour ».
 */
export async function listForAgent(
  agentId: string,
  query: { date?: string; status?: DeliveryStatus },
): Promise<ReturnType<typeof toDeliveryDto>[]> {
  // Cette liste doit être exacte même si aucun parent n'a jamais ouvert
  // l'écran livraison de son app (ce qui, jusqu'ici, était le seul
  // déclencheur de `ensureDeliveriesForFamily`) — un agent doit voir toutes
  // les livraisons dues, pas seulement celles qu'un parent a fait exister.
  const assignedParents = await prisma.user.findMany({
    where: { assignedAgentId: agentId, role: 'client' },
    select: { id: true },
  });
  await Promise.all(assignedParents.map((p) => ensureDeliveriesForFamily(p.id)));

  const dateRange = query.date
    ? {
        gte: new Date(`${query.date}T00:00:00.000Z`),
        lt: new Date(`${query.date}T23:59:59.999Z`),
      }
    : undefined;

  const deliveries = await prisma.delivery.findMany({
    where: {
      parent: { assignedAgentId: agentId },
      ...(query.status ? { status: query.status } : {}),
      ...(dateRange ? { scheduledAt: dateRange } : {}),
    },
    include: withIssues,
    orderBy: { scheduledAt: 'asc' },
  });
  
  return deliveries.map(toDeliveryDto);
}

/**
 * Crée un kit personnalisé pour un objectif de kit personnalisé existant
 * (ajout d'articles en plus du kit de base) — appelé par l'admin lors de
 * la création/réattribution d'un objectif.
 */
export async function ensureCustomKitGoal(
  goal: { id: string; childId: string | null; kitId: string | null; customAddedItems: unknown },
): Promise<string | null> {
  if (goal.kitId) return goal.kitId;
  if (!goal.customAddedItems || !Array.isArray(goal.customAddedItems) || goal.customAddedItems.length === 0) {
    return null;
  }

  if (!goal.childId) return null;

  const child = await prisma.child.findUnique({
    where: { id: goal.childId },
    select: { level: true },
  });

  const customItems = goal.customAddedItems.map((item) => {
    const val = item as Record<string, unknown>;
    return {
      name: String(val.name ?? 'Article personnalisé'),
      quantity: Number(val.quantity ?? 1),
      price: Number(val.price ?? 0),
    };
  });

  const totalPrice = customItems.reduce((sum, item) => sum + item.quantity * item.price, 0);
  const customKit = await prisma.kit.create({
    data: {
      tier: 'basic',
      levelScope: child?.level?.trim() || 'CP1',
      name: 'Kit Personnalisé',
      totalPrice,
      seasonId: await currentSeasonId(),
      isActive: true,
    },
  });

  await prisma.kitItem.createMany({
    data: customItems.map((item) => ({
      kitId: customKit.id,
      category: 'Personnalisé',
      label: item.name,
      quantity: item.quantity,
      unit: 'unité',
      unitPrice: item.price,
    })),
  });

  await prisma.savingsGoal.update({
    where: { id: goal.id },
    data: { kitId: customKit.id },
  });

  return customKit.id;
}
