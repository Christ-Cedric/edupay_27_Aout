import { randomBytes } from 'node:crypto';
import { Prisma } from '@prisma/client';
import type { Contribution, ContributionMethod, SavingsGoalType } from '@prisma/client';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import * as notificationsService from '../notifications/notifications.service.js';
import { cashProvider } from './providers/cash-provider.js';
import { ligdiCashProvider } from './providers/ligdicash-provider.js';
import type { PaymentProvider } from './providers/payment-provider.js';
import { allocateProrata, type Allocatable } from './prorata.js';
import { toContributionDto } from './payments.serializer.js';
import type { RecordCashContributionInput } from './payments.schemas.js';

/** Acteur système pour les actions déclenchées par un webhook (pas d'admin). */
const SYSTEM_ACTOR = 'system:ligdicash-webhook';

function resolveProvider(method: ContributionMethod): PaymentProvider {
  return method === 'cashAgent' ? cashProvider : ligdiCashProvider;
}

function generateReference(prefix: string): string {
  return `${prefix}-${new Date().getFullYear()}-${randomBytes(4).toString('hex').toUpperCase()}`;
}

/**
 * Objectifs d'épargne actifs d'une famille, avec leur capacité pour
 * l'opération demandée (créditer un versement ou débiter un remboursement —
 * voir `prorata.ts`). Accepte le client Prisma singleton OU un client de
 * transaction : appelé aussi bien en pré-validation (hors transaction) qu'en
 * lecture faisant autorité juste avant d'écrire (dans la transaction, pour
 * éviter un TOCTOU entre la vérification et l'écriture).
 */
export async function getActiveGoalsForCapacity(
  db: Prisma.TransactionClient,
  parentId: string,
  mode: 'fund' | 'withdraw',
  targetGoalType?: SavingsGoalType,
): Promise<Allocatable[]> {
  const goals = await db.savingsGoal.findMany({
    where: { 
      parentId, 
      status: 'active',
      ...(targetGoalType ? { type: targetGoalType } : {})
    },
    select: { id: true, childId: true, targetAmount: true, savedAmount: true },
  });
  return goals.map((g) => ({
    savingsGoalId: g.id,
    childId: g.childId,
    capacity: mode === 'fund' ? Math.max(0, g.targetAmount - g.savedAmount) : g.savedAmount,
  }));
}

/** Enfant dont l'objectif vient d'être entièrement financé par cette cotisation. */
interface CompletedGoal {
  savingsGoalId: string;
  childId: string | null;
}

/**
 * Écrit les `ContributionAllocation` + `LedgerEntry` + incrémente
 * `SavingsGoal.savedAmount` pour une cotisation confirmée, marque la
 * cotisation `confirmed`, détecte les objectifs désormais entièrement
 * financés (`GoalStatus.completed`), et crédite la commission de l'agent
 * s'il a personnellement collecté ce versement (jamais sur un paiement
 * mobile money en self-service — voir `collectedByAgentId`). `goals` doit
 * avoir été relu DANS la même transaction juste avant cet appel (voir
 * appelants). Les notifications (WhatsApp) sont émises par l'appelant APRÈS
 * le commit, jamais ici — un échec d'envoi ne doit jamais faire échouer la
 * transaction financière.
 */
async function creditConfirmedContribution(
  tx: Prisma.TransactionClient,
  actorId: string,
  contribution: Pick<Contribution, 'id' | 'parentId' | 'amount' | 'reference' | 'collectedByAgentId' | 'targetGoalType'>,
  goals: Allocatable[],
): Promise<{ completedGoals: CompletedGoal[] }> {
  const allocations = allocateProrata(contribution.amount, goals);
  const capacityById = new Map(goals.map((g) => [g.savingsGoalId, g.capacity]));
  const completedGoals: CompletedGoal[] = [];

  for (const alloc of allocations) {
    await tx.contributionAllocation.create({
      data: {
        contributionId: contribution.id,
        childId: alloc.childId,
        savingsGoalId: alloc.savingsGoalId,
        amount: alloc.amount,
      },
    });
    await tx.savingsGoal.update({
      where: { id: alloc.savingsGoalId },
      data: { savedAmount: { increment: alloc.amount } },
    });
    await tx.ledgerEntry.create({
      data: {
        entryType: 'contribution_confirmed',
        parentId: contribution.parentId,
        savingsGoalId: alloc.savingsGoalId,
        amount: alloc.amount,
        reference: contribution.reference,
      },
    });

    // Capacité restante après ce crédit : 0 signifie que cet objectif vient
    // d'atteindre exactement sa cible (allocateProrata ne peut jamais faire
    // dépasser `capacity`, donc jamais négatif ici).
    const remaining = (capacityById.get(alloc.savingsGoalId) ?? 0) - alloc.amount;
    if (remaining <= 0) {
      const updated = await tx.savingsGoal.updateMany({
        where: { id: alloc.savingsGoalId, status: 'active' },
        data: { status: 'completed' },
      });
      if (updated.count > 0) {
        completedGoals.push({ savingsGoalId: alloc.savingsGoalId, childId: alloc.childId });
        await writeAudit(tx, {
          actorId,
          action: 'goal.completed',
          entity: 'savings_goal',
          entityId: alloc.savingsGoalId,
          after: { childId: alloc.childId },
        });
      }
    }
  }

  await tx.contribution.update({
    where: { id: contribution.id },
    data: { status: 'confirmed', confirmedAt: new Date() },
  });

  await writeAudit(tx, {
    actorId,
    action: 'contribution.confirmed',
    entity: 'contribution',
    entityId: contribution.id,
    after: { amount: contribution.amount, allocations: allocations.length },
  });

  // Commission agent — uniquement sur un encaissement cash réellement
  // collecté par un agent sur le terrain, jamais sur un paiement mobile
  // money en self-service (même distinction déjà appliquée à
  // `collected_this_month` dans le dashboard agent).
  if (contribution.collectedByAgentId) {
    const agentProfile = await tx.agentProfile.findUnique({
      where: { userId: contribution.collectedByAgentId },
      select: { commissionRateBps: true },
    });
    if (agentProfile) {
      const commissionAmount = Math.round((contribution.amount * agentProfile.commissionRateBps) / 10_000);
      if (commissionAmount > 0) {
        await tx.agentCommission.create({
          data: {
            agentId: contribution.collectedByAgentId,
            contributionId: contribution.id,
            amount: commissionAmount,
            rateBps: agentProfile.commissionRateBps,
          },
        });
        await writeAudit(tx, {
          actorId,
          action: 'commission.credited',
          entity: 'agent_commission',
          entityId: contribution.id,
          after: { agentId: contribution.collectedByAgentId, amount: commissionAmount },
        });
      }
    }
  }

  return { completedGoals };
}

/** Notifications post-transaction (fire-and-forget) pour une cotisation
 * confirmée — jamais dans la transaction financière elle-même (voir
 * `creditConfirmedContribution`). */
async function notifyContributionConfirmed(
  parentId: string,
  amount: number,
  completedGoals: CompletedGoal[],
): Promise<void> {
  notificationsService
    .notify(
      parentId,
      'contribution_received',
      'Cotisation reçue',
      `Nous avons bien reçu votre cotisation de ${amount} FCFA. Merci de votre confiance !`,
    )
    .catch(() => {});

  if (completedGoals.length === 0) return;

  const childIds = completedGoals.map((g) => g.childId).filter((id): id is string => id !== null);
  const children = childIds.length
    ? await prisma.child.findMany({ where: { id: { in: childIds } }, select: { id: true, firstName: true } })
    : [];
  const nameByChildId = new Map(children.map((c) => [c.id, c.firstName]));

  for (const goal of completedGoals) {
    const childName = goal.childId ? nameByChildId.get(goal.childId) : undefined;
    notificationsService
      .notify(
        parentId,
        'goal_completed',
        'Épargne complète',
        `L'épargne pour ${childName ?? 'un enfant de votre famille'} est complète ! Le kit sera préparé pour la livraison.`,
      )
      .catch(() => {});
  }
}

/** Marque une cotisation en échec (hors toute transaction englobante). */
async function failContributionStandalone(contributionId: string, reason: string): Promise<void> {
  const notified = await prisma.$transaction(async (tx) => {
    const current = await tx.contribution.findUnique({ where: { id: contributionId } });
    if (!current || current.status !== 'pendingValidation') return null; // déjà traité
    await tx.contribution.update({ where: { id: contributionId }, data: { status: 'failed' } });
    await writeAudit(tx, {
      actorId: SYSTEM_ACTOR,
      action: 'contribution.failed',
      entity: 'contribution',
      entityId: contributionId,
      after: { reason },
    });
    return { parentId: current.parentId, amount: current.amount };
  });

  if (notified) {
    notificationsService
      .notify(
        notified.parentId,
        'contribution_failed',
        'Paiement refusé',
        `Votre cotisation de ${notified.amount} FCFA n'a pas abouti (paiement refusé). Vous pouvez réessayer.`,
      )
      .catch(() => {});
  }
}

/**
 * Point d'entrée générique : initie une cotisation via le provider adapté à
 * `method`. Le cash (provider synchrone) est crédité immédiatement, dans la
 * même transaction que la création — le mobile money (LigdiCash, asynchrone)
 * reste `pendingValidation` jusqu'au webhook de confirmation.
 */
export async function initiateContribution(
  actorId: string,
  parentId: string,
  amount: number,
  method: ContributionMethod,
  collectedByAgentId?: string,
  idempotencyKey?: string,
  targetGoalType?: SavingsGoalType,
): Promise<ReturnType<typeof toContributionDto>> {
  // Déduplication d'un double-tap (réseau terrain instable) : rejouer la
  // même clé renvoie la cotisation déjà créée au lieu d'en recréer une.
  if (idempotencyKey) {
    const existing = await prisma.contribution.findUnique({ where: { idempotencyKey } });
    if (existing) return toContributionDto(existing);
  }

  const parent = await prisma.user.findFirst({ where: { id: parentId, role: 'client' } });
  if (!parent) throw ApiError.notFound('Famille introuvable.');

  // Le compte doit être actif pour recevoir de l'argent : un compte encore
  // `pendingValidation` n'a pas été vérifié par l'admin, un compte
  // `rejected`/`suspended` ne doit plus rien encaisser. Le statut est
  // revalidé ici (pas seulement côté UI) car le backend est la source de
  // vérité des mouvements d'argent (contrat §0).
  if (parent.status === 'pendingValidation') {
    throw ApiError.accountPending(
      'Ce compte est en attente de validation — impossible d’enregistrer une cotisation avant son approbation.',
    );
  }
  if (parent.status !== 'active') {
    throw ApiError.forbidden('Ce compte n’est pas actif — impossible d’enregistrer une cotisation.');
  }

  // Pré-validation optimiste : évite d'appeler la passerelle externe pour un
  // montant manifestement impossible. Revalidée avec des données fraîches
  // DANS la transaction juste avant de créditer (protection anti-course).
  let precheckGoals = await getActiveGoalsForCapacity(prisma, parentId, 'fund', targetGoalType);
  if (targetGoalType && precheckGoals.reduce((sum, g) => sum + g.capacity, 0) === 0) {
    // Si la catégorie ciblée est déjà pleine, on retombe sur tous les objectifs
    precheckGoals = await getActiveGoalsForCapacity(prisma, parentId, 'fund');
  }
  const precheckTotal = precheckGoals.reduce((sum, g) => sum + g.capacity, 0);
  if (precheckTotal <= 0) {
    throw ApiError.conflict('Cette famille n’a aucun objectif d’épargne actif à créditer.');
  }
  if (amount > precheckTotal) {
    throw ApiError.badRequest(`Le montant dépasse le besoin restant (${precheckTotal} FCFA).`, [
      { field: 'amount', issue: 'Supérieur au besoin restant.' },
    ]);
  }

  const provider = resolveProvider(method);
  const reference = generateReference('COT');
  const initResult = await provider.initiate({ amount, phone: parent.phone, reference });

  const baseData = {
    parentId,
    amount,
    method,
    reference,
    targetGoalType: targetGoalType ?? null,
    collectedByAgentId: collectedByAgentId ?? null,
    idempotencyKey: idempotencyKey ?? null,
    provider: provider.name === cashProvider.name ? null : provider.name,
    providerReference: initResult.providerReference,
  };

  try {
    if (initResult.status !== 'confirmed') {
      // Passerelle asynchrone : la confirmation arrive plus tard via webhook.
      const created = await prisma.$transaction(async (tx) => {
        const c = await tx.contribution.create({ data: { ...baseData, status: 'pendingValidation' } });
        await writeAudit(tx, {
          actorId,
          action: 'contribution.initiated',
          entity: 'contribution',
          entityId: c.id,
          after: { parentId, amount, method, status: 'pendingValidation' },
        });
        return c;
      });
      return toContributionDto(created);
    }

    const { created, completedGoals } = await prisma.$transaction(async (tx) => {
      const c = await tx.contribution.create({ data: { ...baseData, status: 'pendingValidation' } });
      await writeAudit(tx, {
        actorId,
        action: 'contribution.initiated',
        entity: 'contribution',
        entityId: c.id,
        after: { parentId, amount, method },
      });

      // Lecture faisant autorité, dans la transaction : si le besoin a changé
      // depuis la pré-validation (course avec une autre cotisation), on échoue
      // proprement plutôt que de créditer un montant incorrect.
      let freshGoals = await getActiveGoalsForCapacity(tx, parentId, 'fund', targetGoalType);
      if (targetGoalType && freshGoals.reduce((sum, g) => sum + g.capacity, 0) === 0) {
        freshGoals = await getActiveGoalsForCapacity(tx, parentId, 'fund');
      }
      const freshTotal = freshGoals.reduce((sum, g) => sum + g.capacity, 0);
      if (amount > freshTotal) {
        await tx.contribution.update({ where: { id: c.id }, data: { status: 'failed' } });
        await writeAudit(tx, {
          actorId,
          action: 'contribution.failed',
          entity: 'contribution',
          entityId: c.id,
          after: { reason: 'Besoin restant insuffisant au moment de créditer (course).' },
        });
        throw ApiError.conflict('Le besoin restant de cette famille a changé entre-temps ; réessayez.');
      }

      const { completedGoals } = await creditConfirmedContribution(tx, actorId, c, freshGoals);
      const finalContribution = await tx.contribution.findUniqueOrThrow({ where: { id: c.id } });
      return { created: finalContribution, completedGoals };
    });

    notifyContributionConfirmed(parentId, amount, completedGoals).catch(() => {});
    return toContributionDto(created);
  } catch (err) {
    // Course sur la clé d'idempotence : deux requêtes concurrentes avec le
    // même `X-Idempotency-Key` peuvent toutes deux passer la pré-vérification
    // avant qu'aucune n'ait écrit — la contrainte unique tranche, on renvoie
    // alors la cotisation gagnante plutôt qu'une erreur au client qui a
    // simplement doublé sa requête.
    if (
      idempotencyKey &&
      err instanceof Prisma.PrismaClientKnownRequestError &&
      err.code === 'P2002'
    ) {
      const existing = await prisma.contribution.findUnique({ where: { idempotencyKey } });
      if (existing) return toContributionDto(existing);
    }
    throw err;
  }
}

/** Historique des cotisations d'une famille, plus récentes d'abord. */
export async function listContributions(parentId: string) {
  const contributions = await prisma.contribution.findMany({
    where: { parentId },
    orderBy: { createdAt: 'desc' },
    include: {
      allocations: {
        select: {
          amount: true,
          savingsGoal: {
            select: { child: { select: { firstName: true } } },
          },
        },
      },
    },
  });
  return contributions.map((contribution) =>
    toContributionDto(contribution, contribution.allocations),
  );
}

/** Toutes les cotisations personnellement collectées par un agent (tous
 * clients confondus), plus récentes d'abord — distinct de `listContributions`
 * (une seule famille) et de `listAllContributions` côté admin (toutes
 * familles, sans filtre agent). */
export async function listContributionsByAgent(agentId: string) {
  const contributions = await prisma.contribution.findMany({
    where: { collectedByAgentId: agentId },
    orderBy: { createdAt: 'desc' },
  });
  return contributions.map((contribution) => toContributionDto(contribution));
}

/** Détail d'une cotisation par id — 404 si absente. */
export async function getContributionById(id: string) {
  const contribution = await prisma.contribution.findUnique({ where: { id } });
  if (!contribution) throw ApiError.notFound('Cotisation introuvable.');
  return toContributionDto(contribution);
}

/** Encaissement cash saisi par l'admin ou un agent sur le terrain. */
export async function recordCashContribution(
  actorId: string,
  parentId: string,
  input: RecordCashContributionInput,
  idempotencyKey?: string,
) {
  return initiateContribution(
    actorId,
    parentId,
    input.amount,
    'cashAgent',
    input.collected_by_agent_id,
    idempotencyKey,
    input.targetGoalType,
  );
}

/**
 * Confirme une cotisation en attente à partir de la référence transaction de
 * la passerelle (appelé par le webhook LigdiCash). Idempotent : un webhook
 * rejoué sur une cotisation déjà traitée est un no-op silencieux.
 */
async function confirmContributionByProviderReference(providerReference: string): Promise<void> {
  const existing = await prisma.contribution.findUnique({ where: { providerReference } });
  if (!existing) {
    throw ApiError.notFound('Aucune cotisation ne correspond à cette référence de transaction.');
  }
  if (existing.status !== 'pendingValidation') return; // déjà traité (webhook rejoué)

  const result = await prisma.$transaction(async (tx) => {
    // Relecture dans la transaction : protège contre un traitement concurrent
    // du même webhook (retry LigdiCash) entre la vérification ci-dessus et ici.
    const fresh = await tx.contribution.findUnique({ where: { id: existing.id } });
    if (!fresh || fresh.status !== 'pendingValidation') return null;

    const goals = await getActiveGoalsForCapacity(tx, fresh.parentId, 'fund', fresh.targetGoalType ?? undefined);
    const totalRemaining = goals.reduce((sum, g) => sum + g.capacity, 0);
    if (fresh.amount > totalRemaining) {
      // Le besoin a changé entre l'initiation et la confirmation (ex. un
      // autre versement est arrivé entre-temps) : réconciliation manuelle
      // plutôt qu'une allocation incorrecte ou un crash.
      await tx.contribution.update({ where: { id: fresh.id }, data: { status: 'failed' } });
      await writeAudit(tx, {
        actorId: SYSTEM_ACTOR,
        action: 'contribution.failed',
        entity: 'contribution',
        entityId: fresh.id,
        after: { reason: 'Écart de réconciliation : besoin restant insuffisant à la confirmation.' },
      });
      return null;
    }

    const { completedGoals } = await creditConfirmedContribution(tx, SYSTEM_ACTOR, fresh, goals);
    return { parentId: fresh.parentId, amount: fresh.amount, completedGoals };
  });

  if (result) {
    notifyContributionConfirmed(result.parentId, result.amount, result.completedGoals).catch(() => {});
  }
}

/** Traite un webhook LigdiCash déjà authentifié (signature vérifiée en amont). */
export async function handleLigdiCashWebhookEvent(
  providerReference: string,
  status: 'confirmed' | 'failed',
): Promise<void> {
  if (status === 'failed') {
    const contribution = await prisma.contribution.findUnique({ where: { providerReference } });
    if (!contribution) {
      throw ApiError.notFound('Aucune cotisation ne correspond à cette référence de transaction.');
    }
    await failContributionStandalone(contribution.id, 'Paiement refusé par la passerelle.');
    return;
  }
  await confirmContributionByProviderReference(providerReference);
}
