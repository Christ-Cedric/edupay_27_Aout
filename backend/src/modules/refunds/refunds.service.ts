import type { Prisma } from '@prisma/client';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { getActiveGoalsForCapacity } from '../payments/payments.service.js';
import { allocateProrata } from '../payments/prorata.js';
import * as notificationsService from '../notifications/notifications.service.js';
import type { RequestRefundInput } from './refunds.schemas.js';

// Frais retenus par remboursement si aucune saison courante (fallback prototype).
const REFUND_FEE_FALLBACK = 500;

type RefundWithParent = Prisma.RefundGetPayload<{
  include: { parent: { select: { fullName: true } } };
}>;

/** Référence lisible synthétisée (le schéma n'a pas encore de colonne dédiée —
 * à remplacer par une vraie séquence quand la création de demande sera câblée). */
function makeReference(r: { createdAt: Date; id: string }): string {
  return `RMB-${r.createdAt.getFullYear()}-${r.id.slice(-6).toUpperCase()}`;
}

function toRefundRequestDto(r: RefundWithParent) {
  return {
    id: r.id,
    reference: makeReference(r),
    family_name: r.parent.fullName,
    amount: r.amount,
    reason: r.reason,
  };
}

/**
 * Écran `ad_re` : renvoie EN UNE FOIS les demandes en attente et le bilan du
 * mois (les deux seams Flutter `fetchPending`/`fetchMonthSummary` frappent ce
 * même endpoint).
 */
export async function listRefunds() {
  const startOfMonth = new Date();
  startOfMonth.setDate(1);
  startOfMonth.setHours(0, 0, 0, 0);

  const [pending, currentSeason, processedThisMonth] = await Promise.all([
    prisma.refund.findMany({
      where: { status: { in: ['requested', 'processing'] } },
      include: { parent: { select: { fullName: true } } },
      orderBy: { createdAt: 'desc' },
    }),
    prisma.season.findFirst({ where: { isCurrent: true }, select: { refundFee: true } }),
    prisma.refund.findMany({
      where: { status: { in: ['approved', 'refunded'] }, createdAt: { gte: startOfMonth } },
      select: { amount: true },
    }),
  ]);

  const fee = currentSeason?.refundFee ?? REFUND_FEE_FALLBACK;
  const approvedCount = processedThisMonth.length;
  const approvedAmount = processedThisMonth.reduce((sum, r) => sum + r.amount, 0);

  return {
    pending: pending.map(toRefundRequestDto),
    month_summary: {
      approved_count: approvedCount,
      approved_amount: approvedAmount,
      fees_retained: approvedCount * fee,
    },
  };
}

function toSelfRefundDto(r: { id: string; createdAt: Date; amount: number; reason: string; status: string }) {
  return {
    id: r.id,
    reference: makeReference(r),
    amount: r.amount,
    reason: r.reason,
    status: r.status,
    created_at: r.createdAt.toISOString(),
  };
}

/** Historique des demandes de remboursement d'une famille. */
export async function listMyRefunds(parentId: string) {
  const refunds = await prisma.refund.findMany({
    where: { parentId },
    orderBy: { createdAt: 'desc' },
  });
  return refunds.map(toSelfRefundDto);
}

/**
 * Crée une demande de remboursement — montant TOUJOURS calculé serveur
 * (solde disponible actuel moins les frais de la saison courante), jamais
 * saisi par le parent. Reste `requested` jusqu'à traitement admin
 * (`approveRefund`/`rejectRefund` ci-dessous, déjà en place).
 *
 * Une seule demande active à la fois par famille : le remboursement porte
 * sur l'objectif TOTAL de la famille (somme des kits de tous les enfants,
 * pas un solde par enfant/kit — voir `getActiveGoalsForCapacity`), donc
 * plusieurs demandes simultanées n'auraient aucun sens à représenter
 * (elles porteraient sur le même solde). Décision produit (2026-07-28).
 */
export async function requestRefund(parentId: string, input: RequestRefundInput) {
  const existingPending = await prisma.refund.findFirst({
    where: { parentId, status: { in: ['requested', 'processing'] } },
    select: { id: true },
  });
  if (existingPending) {
    throw ApiError.conflict('Une demande de remboursement est déjà en cours pour cette famille.');
  }

  const [goals, currentSeason] = await Promise.all([
    getActiveGoalsForCapacity(prisma, parentId, 'withdraw'),
    prisma.season.findFirst({ where: { isCurrent: true }, select: { refundFee: true } }),
  ]);
  const available = goals.reduce((sum, g) => sum + g.capacity, 0);
  const fee = currentSeason?.refundFee ?? REFUND_FEE_FALLBACK;
  const amount = Math.max(0, available - fee);

  if (amount <= 0) {
    throw ApiError.businessRule(
      'REFUND_NO_BALANCE',
      'Aucun solde disponible à rembourser après déduction des frais.',
    );
  }

  const refund = await prisma.$transaction(async (tx) => {
    const r = await tx.refund.create({
      data: { parentId, amount, reason: input.reason },
    });
    await writeAudit(tx, {
      actorId: parentId,
      action: 'refund.requested',
      entity: 'refund',
      entityId: r.id,
      after: { amount, reason: input.reason },
    });
    return r;
  });

  return toSelfRefundDto(refund);
}

async function getPendingRefundOrThrow(id: string) {
  const refund = await prisma.refund.findUnique({ where: { id } });
  if (!refund) throw ApiError.notFound('Demande de remboursement introuvable.');
  if (refund.status !== 'requested' && refund.status !== 'processing') {
    throw ApiError.conflict('Cette demande a déjà été traitée.');
  }
  return refund;
}

/**
 * Détail d'un remboursement (dossier remboursement) — contrairement à
 * `getPendingRefundOrThrow`, fonctionne aussi pour une demande déjà traitée
 * (approuvée/rejetée), pour en consulter l'historique.
 */
export async function getRefundById(id: string) {
  const refund = await prisma.refund.findUnique({
    where: { id },
    include: { parent: { select: { fullName: true } } },
  });
  if (!refund) throw ApiError.notFound('Demande de remboursement introuvable.');

  const processedByAdmin = refund.processedByAdminId
    ? await prisma.user.findUnique({
        where: { id: refund.processedByAdminId },
        select: { fullName: true },
      })
    : null;

  return {
    id: refund.id,
    reference: makeReference(refund),
    family_name: refund.parent.fullName,
    amount: refund.amount,
    reason: refund.reason,
    status: refund.status,
    processed_by_admin_name: processedByAdmin?.fullName ?? null,
    created_at: refund.createdAt.toISOString(),
  };
}

/**
 * Approuve un remboursement : débite le solde de la famille (proportionnellement
 * à ses objectifs actifs, même moteur prorata que les cotisations — contrat
 * §6.1) et écrit l'écriture négative correspondante au ledger. Sans ce
 * traitement, le solde affiché au parent resterait incohérent avec un
 * remboursement pourtant marqué « approuvé ».
 *
 * Ne déclenche PAS (encore) de reversement réel via LigdiCash — seule la
 * comptabilité interne (solde + ledger) est mise à jour. Le virement effectif
 * au parent reste, à ce stade, une opération manuelle hors app.
 */
export async function approveRefund(actorId: string, id: string) {
  const refund = await getPendingRefundOrThrow(id);

  // Pré-validation optimiste ; relu dans la transaction juste avant de
  // débiter (protection anti-course, même logique que `payments.service`).
  const precheckGoals = await getActiveGoalsForCapacity(prisma, refund.parentId, 'withdraw');
  const precheckAvailable = precheckGoals.reduce((sum, g) => sum + g.capacity, 0);
  if (refund.amount > precheckAvailable) {
    throw ApiError.conflict(
      `Solde disponible (${precheckAvailable} FCFA) insuffisant pour ce remboursement de ${refund.amount} FCFA.`,
    );
  }

  await prisma.$transaction(async (tx) => {
    const freshGoals = await getActiveGoalsForCapacity(tx, refund.parentId, 'withdraw');
    const freshAvailable = freshGoals.reduce((sum, g) => sum + g.capacity, 0);
    if (refund.amount > freshAvailable) {
      throw ApiError.conflict(
        `Solde disponible (${freshAvailable} FCFA) insuffisant pour ce remboursement de ${refund.amount} FCFA.`,
      );
    }

    const allocations = allocateProrata(refund.amount, freshGoals);
    const reference = `RMB-${id.slice(-6).toUpperCase()}`;
    for (const alloc of allocations) {
      await tx.savingsGoal.update({
        where: { id: alloc.savingsGoalId },
        data: { savedAmount: { decrement: alloc.amount } },
      });
      await tx.ledgerEntry.create({
        data: {
          entryType: 'refund',
          parentId: refund.parentId,
          savingsGoalId: alloc.savingsGoalId,
          amount: -alloc.amount, // signé négatif (contrat §3.11)
          reference,
        },
      });
    }

    await tx.refund.update({
      where: { id },
      data: { status: 'approved', processedByAdminId: actorId },
    });
    await writeAudit(tx, {
      actorId,
      action: 'refund.approved',
      entity: 'refund',
      entityId: id,
      before: { status: refund.status },
      after: { status: 'approved', amount: refund.amount, allocations: allocations.length },
    });
  });

  notificationsService
    .notify(
      refund.parentId,
      'refund_processed',
      'Remboursement approuvé',
      `Votre demande de remboursement de ${refund.amount} FCFA a été approuvée.`,
    )
    .catch(() => {});
}

export async function rejectRefund(actorId: string, id: string) {
  const refund = await getPendingRefundOrThrow(id);
  await prisma.$transaction(async (tx) => {
    await tx.refund.update({
      where: { id },
      data: { status: 'rejected', processedByAdminId: actorId },
    });
    await writeAudit(tx, {
      actorId,
      action: 'refund.rejected',
      entity: 'refund',
      entityId: id,
      before: { status: refund.status },
      after: { status: 'rejected' },
    });
  });

  notificationsService
    .notify(refund.parentId, 'refund_processed', 'Remboursement rejeté', 'Votre demande de remboursement a été rejetée.')
    .catch(() => {});
}
