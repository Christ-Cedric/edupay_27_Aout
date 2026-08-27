import type { SavingsFrequency, Season } from '@prisma/client';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';

/**
 * Souscription (§4 chez la référence Client, adapté à vos modèles) — les
 * montants (`total_goal`/`per_period_amount`) ne sont JAMAIS stockés : ils
 * sont toujours recalculés à la volée depuis `SavingsGoal`, cohérent avec le
 * reste du projet (`savedAmount`/`targetAmount` sur `Season.deliveryDeadline`
 * pilote déjà le calcul des échéances ailleurs — réutilisé ici tel quel,
 * pas de nouvelle config saison). Pas de table `SubscriptionRevision`
 * séparée : l'historique passe par `AuditLog`, déjà générique.
 */

// Constantes métier (mêmes valeurs par défaut que la référence, ajustables).
const ADD_CHILD_MIN_DAYS_BEFORE_DEADLINE = 7;
const UNAFFORDABLE_MULTIPLIER = 2;
const PER_PERIOD_WARNING_RATIO = 1.5;
const MS_PER_DAY = 24 * 60 * 60 * 1000;

const PERIOD_LENGTH_DAYS: Record<SavingsFrequency, number> = {
  daily: 1,
  weekly: 7,
  monthly: 30,
};

const REJECTION_MESSAGES: Record<string, string> = {
  SUBSCRIPTION_CLOSED: 'La souscription est close.',
  TOO_LATE_TO_ADD_CHILD: "Trop proche de l'échéance pour ajouter un enfant.",
  INSUFFICIENT_PERIODS: "Pas assez d'échéances restantes.",
  UNAFFORDABLE_PLAN: 'Le nouveau montant par échéance dépasse le plafond autorisé.',
};

export function rejectionMessage(code: string | null): string {
  return (code && REJECTION_MESSAGES[code]) || "Ajout impossible pour ce plan.";
}

async function getCurrentSeasonOrThrow(): Promise<Season> {
  const season = await prisma.season.findFirst({ where: { isCurrent: true } });
  if (!season) {
    throw ApiError.badRequest('Aucune saison courante : définissez-en une avant de gérer les souscriptions.');
  }
  return season;
}

function periodsUntilDeadline(frequency: SavingsFrequency, deadline: Date, now = new Date()): number {
  const daysLeft = Math.max(1, Math.ceil((deadline.getTime() - now.getTime()) / MS_PER_DAY));
  return Math.max(1, Math.ceil(daysLeft / PERIOD_LENGTH_DAYS[frequency]));
}

/** Σ target/saved des objectifs actifs de la saison — même calcul que
 * `admin.service.ts::toFamilyDto`/`isFamilyLate`, pas de logique dupliquée. */
export async function computeTotals(parentId: string, seasonId: string) {
  const goals = await prisma.savingsGoal.findMany({
    where: { parentId, seasonId, status: 'active' },
    select: { targetAmount: true, savedAmount: true },
  });
  const totalGoal = goals.reduce((sum, g) => sum + g.targetAmount, 0);
  const totalSaved = goals.reduce((sum, g) => sum + g.savedAmount, 0);
  return { totalGoal, totalSaved, remaining: Math.max(0, totalGoal - totalSaved) };
}

export interface AddChildPreview {
  current_goal: number;
  new_goal: number;
  saved_amount: number;
  remaining: number;
  remaining_periods: number;
  current_per_period: number;
  new_per_period: number;
  increase_ratio: number | null;
  feasible: boolean;
  requires_revision: boolean;
  warnings: string[];
  rejection_code: string | null;
}

/**
 * Aperçu de faisabilité d'ajout d'un enfant (AUCUNE écriture). Sans
 * souscription confirmée → toujours faisable (ajout simple, pas de
 * révision). Avec souscription confirmée → recalcule le montant par
 * échéance et refuse selon les mêmes règles que la référence.
 */
export async function previewAddChild(parentId: string, addedKitPrice: number): Promise<AddChildPreview> {
  const season = await getCurrentSeasonOrThrow();
  const subscription = await prisma.subscription.findUnique({ where: { parentId } });
  const { totalGoal: currentGoal, totalSaved } = await computeTotals(parentId, season.id);
  const newGoal = currentGoal + addedKitPrice;

  if (!subscription || subscription.status !== 'confirmed') {
    return {
      current_goal: currentGoal,
      new_goal: newGoal,
      saved_amount: totalSaved,
      remaining: Math.max(0, newGoal - totalSaved),
      remaining_periods: 0,
      current_per_period: 0,
      new_per_period: 0,
      increase_ratio: null,
      feasible: true,
      requires_revision: false,
      warnings: [],
      rejection_code: null,
    };
  }

  const now = new Date();
  const daysLeft = Math.ceil((season.deliveryDeadline.getTime() - now.getTime()) / MS_PER_DAY);
  const remainingPeriods = periodsUntilDeadline(subscription.frequency, season.deliveryDeadline, now);
  const remaining = Math.max(0, newGoal - totalSaved);
  // "Actuel" par échéance = besoin restant AVANT cet ajout, réparti sur les
  // échéances restantes — jamais stocké, toujours dérivé (cohérence projet).
  const currentRemaining = Math.max(0, currentGoal - totalSaved);
  const currentPerPeriod = currentRemaining <= 0 ? 0 : Math.ceil(currentRemaining / remainingPeriods);
  const newPerPeriod = remaining <= 0 ? 0 : Math.ceil(remaining / remainingPeriods);
  const increaseRatio = currentPerPeriod > 0 ? Math.round((newPerPeriod / currentPerPeriod) * 100) / 100 : null;

  const warnings: string[] = [];
  if (currentPerPeriod > 0 && newPerPeriod > currentPerPeriod * PER_PERIOD_WARNING_RATIO) {
    warnings.push('PER_PERIOD_INCREASE_ABOVE_50_PERCENT');
  }

  let rejection: string | null = null;
  if (season.deliveryDeadline <= now) rejection = 'SUBSCRIPTION_CLOSED';
  else if (daysLeft < ADD_CHILD_MIN_DAYS_BEFORE_DEADLINE) rejection = 'TOO_LATE_TO_ADD_CHILD';
  else if (remainingPeriods < 2) rejection = 'INSUFFICIENT_PERIODS';
  else if (currentPerPeriod > 0 && newPerPeriod > currentPerPeriod * UNAFFORDABLE_MULTIPLIER) {
    rejection = 'UNAFFORDABLE_PLAN';
  }

  return {
    current_goal: currentGoal,
    new_goal: newGoal,
    saved_amount: totalSaved,
    remaining,
    remaining_periods: remainingPeriods,
    current_per_period: currentPerPeriod,
    new_per_period: newPerPeriod,
    increase_ratio: increaseRatio,
    feasible: rejection === null,
    requires_revision: true,
    warnings,
    rejection_code: rejection,
  };
}

/** Aperçu pour l'écran — résout le prix du kit choisi avant de déléguer à
 * `previewAddChild`. */
export async function previewChildForKit(parentId: string, kitId: string): Promise<AddChildPreview> {
  const kit = await prisma.kit.findUnique({ where: { id: kitId } });
  if (!kit) throw ApiError.badRequest('Kit inconnu.', [{ field: 'kit_id', issue: 'Introuvable.' }]);
  return previewAddChild(parentId, kit.totalPrice);
}

/**
 * Confirme (crée si besoin — upsert) la souscription du parent. Un compte
 * auto-inscrit par OTP n'a jamais eu de `Subscription` (contrairement à un
 * enrôlement direct par admin/agent, qui en crée une `confirmed` d'emblée) —
 * ce chemin comble ce cas.
 */
export async function confirmSubscription(parentId: string, frequency?: SavingsFrequency, signature?: string) {
  const season = await getCurrentSeasonOrThrow();

  const subscription = await prisma.subscription.upsert({
    where: { parentId },
    create: {
      parentId,
      frequency: frequency ?? 'weekly',
      status: 'confirmed',
      confirmedAt: new Date(),
      ...(signature ? { signature } : {}),
    },
    update: {
      ...(frequency ? { frequency } : {}),
      status: 'confirmed',
      confirmedAt: new Date(),
      ...(signature ? { signature } : {}),
    },
  });

  const totals = await computeTotals(parentId, season.id);
  const remainingPeriods = periodsUntilDeadline(subscription.frequency, season.deliveryDeadline);
  const perPeriodAmount = totals.remaining <= 0 ? 0 : Math.ceil(totals.remaining / remainingPeriods);

  await writeAudit(prisma, {
    actorId: parentId,
    action: 'subscription.confirmed',
    entity: 'subscription',
    entityId: subscription.id,
    after: { frequency: subscription.frequency, totalGoal: totals.totalGoal },
  });

  return {
    id: subscription.id,
    frequency: subscription.frequency,
    status: subscription.status,
    confirmed_at: subscription.confirmedAt?.toISOString() ?? null,
    total_goal: totals.totalGoal,
    per_period_amount: perPeriodAmount,
    remaining_periods: remainingPeriods,
  };
}
