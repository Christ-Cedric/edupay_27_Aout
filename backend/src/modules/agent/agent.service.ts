import { env } from '../../config/env.js';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import {
  addChild as adminAddChild,
  archiveFamily as adminArchiveFamily,
  assignKit as adminAssignKit,
  enrollFamily as adminEnrollFamily,
  getAgent,
  getFamily,
  listFamilies,
  listFamilyContributions,
  listFamilyLedger,
  updateFamilyProfile as adminUpdateFamilyProfile,
} from '../admin/admin.service.js';
import type {
  AddChildInput,
  AssignKitInput,
  EnrollFamilyInput,
  UpdateFamilyProfileInput,
} from '../admin/admin.schemas.js';
import * as paymentsService from '../payments/payments.service.js';
import * as deliveryService from '../delivery/delivery.service.js';
import type { AdvanceStatusInput, ConfirmByAgentInput, ScheduleDeliveryInput } from '../delivery/delivery.schemas.js';
import * as notificationsService from '../notifications/notifications.service.js';
import type { AgentDeliveriesQuery, AgentFamiliesQuery, UpdateAgentProfileInput } from './agent.schemas.js';

function startOfMonth(): Date {
  const d = new Date();
  d.setDate(1);
  d.setHours(0, 0, 0, 0);
  return d;
}

function monthRange(monthsAgo: number): { gte: Date; lte: Date } {
  const gte = new Date();
  gte.setMonth(gte.getMonth() - monthsAgo, 1);
  gte.setHours(0, 0, 0, 0);
  const lte = new Date(gte);
  lte.setMonth(lte.getMonth() + 1);
  lte.setDate(0);
  lte.setHours(23, 59, 59, 999);
  return { gte, lte };
}

export async function getProfile(agentId: string) {
  return getAgent(agentId);
}

/** Auto-édition du profil agent (nom, zone, quartier) — écran « Mon profil ». */
export async function updateProfile(agentId: string, input: UpdateAgentProfileInput) {
  if (Object.keys(input).length === 0) {
    throw ApiError.badRequest('Aucun champ fourni.');
  }
  await prisma.$transaction(async (tx) => {
    if (input.full_name !== undefined) {
      await tx.user.update({ where: { id: agentId }, data: { fullName: input.full_name } });
    }
    if (input.zone !== undefined || input.district !== undefined) {
      await tx.agentProfile.update({
        where: { userId: agentId },
        data: {
          ...(input.zone !== undefined ? { zone: input.zone } : {}),
          ...(input.district !== undefined ? { district: input.district } : {}),
        },
      });
    }
  });
  return getAgent(agentId);
}

/** KPI terrain de l'agent — dérivés des familles qui lui sont assignées,
 * jamais un total global (réservé au dashboard admin). */
export async function getDashboard(agentId: string) {
  const since = startOfMonth();
  const thisMonth = monthRange(0);
  const lastMonth = monthRange(1);
  const seasonWindow = { gte: monthRange(2).gte };

  const [allFamilies, lateFamilies, contributionsThisMonth, commissionsThisMonth, commissionsLastMonth, commissionsSeason] =
    await Promise.all([
      listFamilies({ assignedAgentId: agentId }),
      listFamilies({ assignedAgentId: agentId, status: 'lateOverdue' }),
      // `collectedByAgentId`, pas `parent.assignedAgentId` : une famille
      // assignée à cet agent peut payer elle-même en mobile money sans passer
      // par lui — ça ne doit pas gonfler ce qu'il a personnellement encaissé
      // (même distinction que la commission, voir `payments.service.ts`).
      prisma.contribution.aggregate({
        where: { status: 'confirmed', createdAt: { gte: since }, collectedByAgentId: agentId },
        _sum: { amount: true },
      }),
      prisma.agentCommission.aggregate({
        where: { agentId, createdAt: thisMonth },
        _sum: { amount: true },
      }),
      prisma.agentCommission.aggregate({
        where: { agentId, createdAt: lastMonth },
        _sum: { amount: true },
      }),
      prisma.agentCommission.aggregate({
        where: { agentId, createdAt: seasonWindow },
        _sum: { amount: true },
      }),
    ]);

  return {
    active_clients: allFamilies.filter((f) => f.status === 'active').length,
    new_this_month: allFamilies.filter((f) => new Date(f.registered_at) >= since).length,
    collected_this_month: contributionsThisMonth._sum.amount ?? 0,
    late_count: lateFamilies.length,
    commissions: {
      this_month: commissionsThisMonth._sum.amount ?? 0,
      last_month: commissionsLastMonth._sum.amount ?? 0,
      total_season: commissionsSeason._sum.amount ?? 0,
    },
  };
}

/** Familles assignées à cet agent (§ contrat : un client a au plus un agent
 * référent, `User.assignedAgentId`), filtrables par statut (ex. `lateOverdue`
 * pour retrouver rapidement qui relancer). */
export async function getMyFamilies(agentId: string, query: AgentFamiliesQuery = {}) {
  return listFamilies({ assignedAgentId: agentId, status: query.status });
}

/** Vérifie que `familyId` est bien assigné à cet agent avant toute action
 * (encaissement, etc.) — un agent n'agit jamais pour une famille qu'on ne
 * lui a pas confiée. */
async function assertOwnFamily(agentId: string, familyId: string): Promise<void> {
  const family = await prisma.user.findFirst({
    where: { id: familyId, role: 'client', assignedAgentId: agentId },
    select: { id: true },
  });
  if (!family) throw ApiError.notFound('Famille introuvable ou non assignée à cet agent.');
}

/** Encaissement cash sur le terrain — `collected_by_agent_id` est toujours
 * l'agent authentifié, jamais une valeur envoyée par le client. Le header
 * `X-Idempotency-Key` (optionnel) protège d'un double-tap sur un réseau
 * terrain instable — rejouer la même clé renvoie la même cotisation. */
export async function recordContribution(
  agentId: string,
  familyId: string,
  amount: number,
  idempotencyKey?: string,
  targetGoalType?: any,
) {
  await assertOwnFamily(agentId, familyId);
  return paymentsService.recordCashContribution(
    agentId,
    familyId,
    { amount, collected_by_agent_id: agentId, targetGoalType },
    idempotencyKey,
  );
}

/** Historique des commissions de l'agent, plus récentes d'abord — pas de
 * pagination (volume borné par famille, même choix que `getMyFamilies`). */
export async function listCommissions(agentId: string) {
  const commissions = await prisma.agentCommission.findMany({
    where: { agentId },
    orderBy: { createdAt: 'desc' },
    include: { contribution: { select: { amount: true, method: true, parentId: true } } },
  });
  return commissions.map((c) => ({
    id: c.id,
    contribution_id: c.contributionId,
    amount: c.amount,
    rate_bps: c.rateBps,
    contribution_amount: c.contribution.amount,
    method: c.contribution.method,
    created_at: c.createdAt.toISOString(),
  }));
}

/**
 * Relance une famille en retard — refuse si la famille n'est pas
 * effectivement `lateOverdue` (pas de relance sur un compte à jour) ou si
 * elle n'est pas assignée à cet agent. Incrémente l'historique persistant
 * (`lateReminderCount`/`lastLateReminderAt` — le statut `lateOverdue`
 * lui-même reste dérivé, jamais stocké) et notifie le parent par WhatsApp.
 */
export async function remindLateFamily(agentId: string, familyId: string) {
  await assertOwnFamily(agentId, familyId);
  const lateFamilies = await listFamilies({ assignedAgentId: agentId, status: 'lateOverdue' });
  if (!lateFamilies.some((f) => f.id === familyId)) {
    throw ApiError.conflict('Cette famille n’est pas en retard de paiement.');
  }

  await prisma.$transaction(async (tx) => {
    await tx.user.update({
      where: { id: familyId },
      data: { lateReminderCount: { increment: 1 }, lastLateReminderAt: new Date() },
    });
    await writeAudit(tx, {
      actorId: agentId,
      action: 'family.reminded',
      entity: 'user',
      entityId: familyId,
    });
  });

  notificationsService
    .notify(
      familyId,
      'late_reminder',
      'Rappel de cotisation',
      'Votre épargne EduPay a pris du retard — pensez à régulariser dès que possible.',
    )
    .catch(() => {});

  return { reminded: true };
}

/** Identification terrain rapide (QR agent) — retrouve une famille par son
 * `familyCode`, uniquement si elle est assignée à cet agent. */
export async function getFamilyByCode(agentId: string, code: string) {
  const family = await prisma.user.findFirst({
    where: { familyCode: code, role: 'client', assignedAgentId: agentId },
    select: { id: true },
  });
  if (!family) throw ApiError.notFound('Famille introuvable ou non assignée à cet agent.');
  const families = await listFamilies({ assignedAgentId: agentId });
  return families.find((f) => f.id === family.id);
}

/** Enrôle une nouvelle famille — `assigned_agent_id` est toujours l'agent
 * authentifié, jamais une valeur envoyée par le client (même principe que
 * `collected_by_agent_id` sur les cotisations). */
export async function enrollFamily(agentId: string, input: EnrollFamilyInput) {
  return adminEnrollFamily(agentId, { ...input, assigned_agent_id: agentId });
}

/** Détail d'une famille assignée à cet agent. */
export async function getFamilyDetail(agentId: string, familyId: string) {
  await assertOwnFamily(agentId, familyId);
  return getFamily(familyId);
}

/** Modifie le profil (nom/ville/quartier) d'une famille assignée à cet agent. */
export async function updateFamily(agentId: string, familyId: string, input: UpdateFamilyProfileInput) {
  await assertOwnFamily(agentId, familyId);
  return adminUpdateFamilyProfile(agentId, familyId, input);
}

/** Ajoute un enfant à une famille assignée à cet agent. */
export async function addChild(agentId: string, familyId: string, input: AddChildInput) {
  await assertOwnFamily(agentId, familyId);
  return adminAddChild(agentId, familyId, input);
}

/** Assigne un kit à un enfant d'une famille assignée à cet agent. */
export async function assignChildKit(agentId: string, familyId: string, childId: string, input: AssignKitInput) {
  await assertOwnFamily(agentId, familyId);
  return adminAssignKit(agentId, familyId, childId, input);
}

/** Archive une famille assignée à cet agent. */
export async function archiveFamily(agentId: string, familyId: string) {
  await assertOwnFamily(agentId, familyId);
  return adminArchiveFamily(agentId, familyId);
}

/** Historique des cotisations d'une famille assignée à cet agent. */
export async function getFamilyContributions(agentId: string, familyId: string) {
  await assertOwnFamily(agentId, familyId);
  return listFamilyContributions(familyId);
}

/** Toutes les cotisations personnellement collectées par cet agent (toutes
 * familles confondues) — distinct de l'historique par famille ci-dessus. */
export async function listMyContributions(agentId: string) {
  return paymentsService.listContributionsByAgent(agentId);
}

/** Détail d'une cotisation — réservé à celle que cet agent a lui-même
 * collectée (404 sinon, jamais un aperçu des encaissements d'un autre agent
 * ou d'un paiement mobile money en self-service). */
export async function getContribution(agentId: string, contributionId: string) {
  const contribution = await paymentsService.getContributionById(contributionId);
  if (contribution.collected_by_agent_id !== agentId) {
    throw ApiError.notFound('Cotisation introuvable.');
  }
  return contribution;
}

/** Historique comptable complet (équivalent "wallet transactions") d'une
 * famille assignée à cet agent. */
export async function getFamilyLedger(agentId: string, familyId: string) {
  await assertOwnFamily(agentId, familyId);
  return listFamilyLedger(familyId);
}

/** Historique des notifications in-app d'une famille assignée à cet agent. */
export async function getFamilyNotifications(agentId: string, familyId: string) {
  await assertOwnFamily(agentId, familyId);
  return notificationsService.listForUser(familyId);
}

/** Détail d'une livraison — réservé aux livraisons des familles assignées à
 * cet agent (même garde que `advanceDelivery`/`confirmDelivery`). */
export async function getDelivery(agentId: string, deliveryId: string) {
  const delivery = await prisma.delivery.findUnique({
    where: { id: deliveryId },
    select: { parentId: true },
  });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');
  await assertOwnFamily(agentId, delivery.parentId);
  return deliveryService.getById(deliveryId);
}

/** Livraisons des familles assignées à l'agent, filtrables par date de
 * passage prévue et statut — « livraisons du jour ». */
export async function getDeliveriesToday(agentId: string, query: AgentDeliveriesQuery) {
  return deliveryService.listForAgent(agentId, query);
}

/** Fait avancer d'un cran la livraison d'un enfant — réservé aux livraisons
 * des familles assignées à cet agent. */
export async function advanceDelivery(agentId: string, deliveryId: string, input: AdvanceStatusInput) {
  const delivery = await prisma.delivery.findUnique({
    where: { id: deliveryId },
    select: { parentId: true },
  });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');
  await assertOwnFamily(agentId, delivery.parentId);
  return deliveryService.advanceStatus(agentId, deliveryId, input);
}

/** Confirmation avec signature capturée sur l'appareil de l'agent — chemin
 * alternatif à la confirmation self-service du parent. */
export async function confirmDelivery(agentId: string, deliveryId: string, input: ConfirmByAgentInput) {
  const delivery = await prisma.delivery.findUnique({
    where: { id: deliveryId },
    select: { parentId: true },
  });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');
  await assertOwnFamily(agentId, delivery.parentId);
  return deliveryService.confirmByAgent(agentId, deliveryId, input);
}

/** Planifie la date de passage d'une livraison — réservé aux familles
 * assignées à cet agent. */
export async function scheduleDelivery(agentId: string, deliveryId: string, input: ScheduleDeliveryInput) {
  const delivery = await prisma.delivery.findUnique({
    where: { id: deliveryId },
    select: { parentId: true },
  });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');
  await assertOwnFamily(agentId, delivery.parentId);
  return deliveryService.schedule(agentId, deliveryId, input);
}

/**
 * Génère un lien WhatsApp pré-rempli avec les KPI du mois — aucun appel API
 * externe, juste une URL `wa.me` que l'app ouvre elle-même (équivalent de
 * `sendReportToDirector` chez la référence Agent terrain). `null` si
 * `WHATSAPP_DIRECTOR_NUMBER` n'est pas configuré.
 */
export async function sendReportToDirector(agentId: string) {
  const [agent, dashboard] = await Promise.all([getAgent(agentId), getDashboard(agentId)]);
  const directorNumber = env.WHATSAPP_DIRECTOR_NUMBER;

  const message =
    `Bonjour Directeur EduPay,\n\n` +
    `Rapport d'activité — ${agent.full_name} (${agent.zone}).\n\n` +
    `Nouveaux clients ce mois : ${dashboard.new_this_month}\n` +
    `Montant collecté ce mois : ${dashboard.collected_this_month} FCFA\n` +
    `Commissions ce mois : ${dashboard.commissions.this_month} FCFA\n\n` +
    `Généré le ${new Date().toLocaleDateString('fr-FR')}.`;

  const whatsappUrl = directorNumber
    ? `https://wa.me/${directorNumber.replace(/^\+/, '')}?text=${encodeURIComponent(message)}`
    : null;

  return { whatsapp_url: whatsappUrl };
}

/** Coordonnées du directeur (contact rapide) — `null` si non configuré. */
export function getDirectorContact() {
  const number = env.WHATSAPP_DIRECTOR_NUMBER;
  return {
    whatsapp_url: number ? `https://wa.me/${number.replace(/^\+/, '')}` : null,
    phone_number: number ?? null,
  };
}
