/**
 * test_cotisations.ts
 * ===================
 * Suite de tests complets du moteur de cotisation EduPay.
 *
 * Couvre :
 *   1. Indépendance totale des 3 types d'objectif (fournitures / scolarité / transport)
 *   2. Allocation prorata multi-enfants (méthode du plus grand reste)
 *   3. Détection de complétion d'objectif (status → 'completed')
 *   4. Robustesse aux arrondis sur de nombreux paiements successifs
 *   5. Paiements ciblés (targetGoalType) → ne débordent pas sur d'autres catégories
 *   6. Statistiques globales cohérentes avec la somme des catégories
 *   7. Détection des seuils 70 % et 100 % (checkAndNotifyMilestones logic)
 *
 * Usage : npx tsx scripts/test_cotisations.ts
 */

import { allocateProrata, assertWithinCapacity } from '../src/modules/payments/prorata.js';

// ─── Couleurs terminal ────────────────────────────────────────────────────────
const G = '\x1b[32m✔\x1b[0m';   // vert  = PASS
const R = '\x1b[31m✘\x1b[0m';   // rouge = FAIL
const Y = '\x1b[33m⚠\x1b[0m';   // jaune = WARN
const B = '\x1b[1m';            // gras
const E = '\x1b[0m';

// ─── Cadre de test minimaliste ────────────────────────────────────────────────
let _pass = 0;
let _fail = 0;
const _failures: string[] = [];

function expect(label: string, actual: unknown, expected: unknown): void {
  const ok = JSON.stringify(actual) === JSON.stringify(expected);
  if (ok) {
    console.log(`  ${G} ${label}`);
    _pass++;
  } else {
    console.log(`  ${R} ${label}`);
    console.log(`       attendu : ${JSON.stringify(expected)}`);
    console.log(`       recu    : ${JSON.stringify(actual)}`);
    _fail++;
    _failures.push(label);
  }
}

function expectClose(label: string, actual: number, expected: number, tol = 1): void {
  const ok = Math.abs(actual - expected) <= tol;
  if (ok) {
    console.log(`  ${G} ${label}  (${actual} approx ${expected})`);
    _pass++;
  } else {
    console.log(`  ${R} ${label}`);
    console.log(`       attendu : ${expected} +/- ${tol}`);
    console.log(`       recu    : ${actual}`);
    _fail++;
    _failures.push(label);
  }
}

function section(title: string): void {
  console.log(`\n${B}== ${title} ==${E}`);
}

// ─── Simulateur local d'état d'objectif ──────────────────────────────────────
interface Goal {
  id: string;
  type: 'supplies' | 'registration' | 'transport';
  targetAmount: number;
  savedAmount: number;
  status: 'active' | 'completed';
  childId: string | null;
}

function simulatePayment(
  goals: Goal[],
  amount: number,
  targetType?: Goal['type'],
): { allocated: Record<string, number>; completed: string[] } {
  const subset = goals.filter(
    (g) => g.status === 'active' && (targetType ? g.type === targetType : true),
  );

  const allocatables = subset.map((g) => ({
    savingsGoalId: g.id,
    childId: g.childId,
    capacity: Math.max(0, g.targetAmount - g.savedAmount),
  }));

  const totalCap = allocatables.reduce((s, a) => s + a.capacity, 0);
  if (totalCap <= 0) return { allocated: {}, completed: [] };

  const capped = Math.min(amount, totalCap);
  const allocations = allocateProrata(capped, allocatables);

  const allocated: Record<string, number> = {};
  const completed: string[] = [];

  for (const alloc of allocations) {
    const goal = goals.find((g) => g.id === alloc.savingsGoalId)!;
    goal.savedAmount += alloc.amount;
    allocated[alloc.savingsGoalId] = (allocated[alloc.savingsGoalId] ?? 0) + alloc.amount;

    if (goal.savedAmount >= goal.targetAmount) {
      goal.status = 'completed';
      completed.push(goal.id);
    }
  }

  return { allocated, completed };
}

function progress(goal: Goal): number {
  return goal.targetAmount === 0 ? 0 : goal.savedAmount / goal.targetAmount;
}

function remaining(goal: Goal): number {
  return Math.max(0, goal.targetAmount - goal.savedAmount);
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 1 — Independance des 3 categories
// ─────────────────────────────────────────────────────────────────────────────
section('SCENARIO 1 — Independance des 3 categories (paiements cibles)');

const goals1: Goal[] = [
  { id: 'G-SUPPLY',  type: 'supplies',      targetAmount: 12_000, savedAmount: 0, status: 'active', childId: 'child-1' },
  { id: 'G-TUITION', type: 'registration',  targetAmount: 50_000, savedAmount: 0, status: 'active', childId: 'child-1' },
  { id: 'G-TRANSP',  type: 'transport',     targetAmount: 30_000, savedAmount: 0, status: 'active', childId: 'child-1' },
];

simulatePayment(goals1, 3_000, 'supplies');
expect('[S1] Fournitures savedAmount = 3 000',           goals1[0]!.savedAmount, 3_000);
expect('[S1] Scolarite non touchee apres paiement F',    goals1[1]!.savedAmount, 0);
expect('[S1] Transport non touche apres paiement F',     goals1[2]!.savedAmount, 0);

simulatePayment(goals1, 10_000, 'registration');
expect('[S1] Fournitures inchangee apres paiement S',    goals1[0]!.savedAmount, 3_000);
expect('[S1] Scolarite savedAmount = 10 000',            goals1[1]!.savedAmount, 10_000);
expect('[S1] Transport inchange apres paiement S',       goals1[2]!.savedAmount, 0);

simulatePayment(goals1, 15_000, 'transport');
expect('[S1] Fournitures inchangee apres paiement T',    goals1[0]!.savedAmount, 3_000);
expect('[S1] Scolarite inchangee apres paiement T',      goals1[1]!.savedAmount, 10_000);
expect('[S1] Transport savedAmount = 15 000',            goals1[2]!.savedAmount, 15_000);

expect('[S1] Reste Fournitures = 9 000',  remaining(goals1[0]!), 9_000);
expect('[S1] Reste Scolarite  = 40 000',  remaining(goals1[1]!), 40_000);
expect('[S1] Reste Transport  = 15 000',  remaining(goals1[2]!), 15_000);

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 2 — Completion d'objectif
// ─────────────────────────────────────────────────────────────────────────────
section("SCENARIO 2 — Completion d'objectif (status -> completed)");

const goals2: Goal[] = [
  { id: 'G2-SUP', type: 'supplies',     targetAmount: 12_000, savedAmount: 9_000, status: 'active', childId: 'c1' },
  { id: 'G2-TUI', type: 'registration', targetAmount: 50_000, savedAmount: 0,     status: 'active', childId: 'c1' },
];

const r2 = simulatePayment(goals2, 3_000, 'supplies');
expect('[S2] Fournitures completee (status = completed)', goals2[0]!.status, 'completed');
expect('[S2] Fournitures savedAmount = 12 000',           goals2[0]!.savedAmount, 12_000);
expect('[S2] Scolarite non touchee',                      goals2[1]!.savedAmount, 0);
expect('[S2] ID complete retourne',                       r2.completed.includes('G2-SUP'), true);

const r2b = simulatePayment(goals2, 5_000, 'supplies');
expect('[S2] Fournitures ne deborde pas apres completion', goals2[0]!.savedAmount, 12_000);
expect('[S2] Aucune allocation apres completion',          Object.keys(r2b.allocated).length, 0);

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 3 — Prorata multi-enfants
// ─────────────────────────────────────────────────────────────────────────────
section('SCENARIO 3 — Prorata multi-enfants (2 enfants, meme categorie)');

const goals3: Goal[] = [
  { id: 'G3-A', type: 'supplies', targetAmount: 12_000, savedAmount: 0, status: 'active', childId: 'c-awa' },
  { id: 'G3-B', type: 'supplies', targetAmount: 18_000, savedAmount: 0, status: 'active', childId: 'c-bora' },
];

simulatePayment(goals3, 6_000);
expectClose('[S3] Awa  recoit ~2 400 F (prorata 12k/30k)',  goals3[0]!.savedAmount, 2_400, 1);
expectClose('[S3] Bora recoit ~3 600 F (prorata 18k/30k)', goals3[1]!.savedAmount, 3_600, 1);

const total3 = goals3[0]!.savedAmount + goals3[1]!.savedAmount;
expect('[S3] Somme des parts = 6 000 F (pas de perte)', total3, 6_000);

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 4 — Robustesse arrondis (100 paiements non divisibles)
// ─────────────────────────────────────────────────────────────────────────────
section('SCENARIO 4 — Robustesse arrondis (100 paiements de 13 F sur 3 enfants)');

const goals4: Goal[] = [
  { id: 'G4-A', type: 'supplies', targetAmount: 1_000, savedAmount: 0, status: 'active', childId: 'c1' },
  { id: 'G4-B', type: 'supplies', targetAmount: 1_000, savedAmount: 0, status: 'active', childId: 'c2' },
  { id: 'G4-C', type: 'supplies', targetAmount: 1_000, savedAmount: 0, status: 'active', childId: 'c3' },
];

for (let i = 0; i < 100; i++) {
  simulatePayment(goals4, 13);
}
const total4 = goals4.reduce((s, g) => s + g.savedAmount, 0);
expect('[S4] Somme totale = 1 300 F (aucun centime perdu)', total4, 1_300);
const overflows4 = goals4.filter((g) => g.savedAmount > g.targetAmount);
expect('[S4] Aucun objectif ne depasse son target', overflows4.length, 0);

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 5 — Paiements mixtes global + cibles
// ─────────────────────────────────────────────────────────────────────────────
section('SCENARIO 5 — Mixte : paiements globaux alternes avec paiements cibles');

const goals5: Goal[] = [
  { id: 'G5-SUP', type: 'supplies',     targetAmount: 10_000, savedAmount: 0, status: 'active', childId: 'c1' },
  { id: 'G5-TUI', type: 'registration', targetAmount: 20_000, savedAmount: 0, status: 'active', childId: 'c1' },
  { id: 'G5-TRA', type: 'transport',    targetAmount: 15_000, savedAmount: 0, status: 'active', childId: 'c1' },
];

simulatePayment(goals5, 4_500);
const sumAfterGlobal = goals5.reduce((s, g) => s + g.savedAmount, 0);
expect('[S5] Paiement global 4 500 F bien distribue (somme = 4 500)', sumAfterGlobal, 4_500);

const beforeTra5 = goals5[2]!.savedAmount;
simulatePayment(goals5, 2_000, 'transport');
expect('[S5] Transport augmente de 2 000 F exactement', goals5[2]!.savedAmount, beforeTra5 + 2_000);

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 6 — Coherence global vs somme categories
// ─────────────────────────────────────────────────────────────────────────────
section('SCENARIO 6 — Coherence : global = somme des categories');

const globalTarget5 = goals5.reduce((s, g) => s + g.targetAmount, 0);
const globalSaved5  = goals5.reduce((s, g) => s + g.savedAmount, 0);
const globalRemain5 = goals5.reduce((s, g) => s + remaining(g), 0);

expect('[S6] globalTarget = 45 000', globalTarget5, 45_000);
expect('[S6] globalSaved  = 4 500 + 2 000 = 6 500', globalSaved5, 6_500);
expect('[S6] globalTarget = globalSaved + globalRemaining', globalTarget5, globalSaved5 + globalRemain5);

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 7 — Seuils de progression
// ─────────────────────────────────────────────────────────────────────────────
section('SCENARIO 7 — Detection des seuils 70 % et 100 %');

function computeProgressPercent(goals: Goal[]): number {
  const target = goals.reduce((s, g) => s + g.targetAmount, 0);
  const saved  = goals.reduce((s, g) => s + g.savedAmount, 0);
  return target === 0 ? 0 : Math.round((saved / target) * 100);
}

const goals7: Goal[] = [
  { id: 'G7-S', type: 'supplies',     targetAmount: 10_000, savedAmount: 0, status: 'active', childId: 'c1' },
  { id: 'G7-T', type: 'registration', targetAmount: 10_000, savedAmount: 0, status: 'active', childId: 'c1' },
];

simulatePayment(goals7, 7_000);
const p7a = computeProgressPercent(goals7);
expect('[S7] Progression apres 7 000 F = 35 %', p7a, 35);

simulatePayment(goals7, 7_000);
const p7b = computeProgressPercent(goals7);
expect('[S7] Progression apres 14 000 F = 70 %', p7b, 70);

simulatePayment(goals7, 6_000);
const p7c = computeProgressPercent(goals7);
expect('[S7] Progression apres 20 000 F = 100 %', p7c, 100);
const completedAll7 = goals7.every((g) => g.status === 'completed');
expect('[S7] Tous les objectifs sont completed a 100 %', completedAll7, true);

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 8 — assertWithinCapacity
// ─────────────────────────────────────────────────────────────────────────────
section('SCENARIO 8 — assertWithinCapacity (garde-fou depassement)');

let threw8 = false;
try {
  assertWithinCapacity(999_999, [{ savingsGoalId: 'x', childId: null, capacity: 1_000 }]);
} catch {
  threw8 = true;
}
expect('[S8] assertWithinCapacity leve une erreur si montant > capacite', threw8, true);

let noThrow8 = true;
try {
  assertWithinCapacity(500, [{ savingsGoalId: 'x', childId: null, capacity: 1_000 }]);
} catch {
  noThrow8 = false;
}
expect('[S8] assertWithinCapacity ne leve pas si montant <= capacite', noThrow8, true);

// ─────────────────────────────────────────────────────────────────────────────
//  SCENARIO 9 — Paiements partiels successifs jusqu'a 100%
// ─────────────────────────────────────────────────────────────────────────────
section("SCENARIO 9 — Paiements partiels successifs (verifiation reste etape par etape)");

const goals9: Goal[] = [
  { id: 'G9-SUP', type: 'supplies',     targetAmount: 12_000, savedAmount: 0, status: 'active', childId: 'c1' },
  { id: 'G9-TUI', type: 'registration', targetAmount: 60_000, savedAmount: 0, status: 'active', childId: 'c1' },
  { id: 'G9-TRA', type: 'transport',    targetAmount: 25_000, savedAmount: 0, status: 'active', childId: 'c1' },
];

const payments9 = [
  { amount:  5_000, type: 'supplies'     as Goal['type'] },
  { amount:  7_000, type: 'supplies'     as Goal['type'] },
  { amount: 20_000, type: 'registration' as Goal['type'] },
  { amount: 10_000, type: 'transport'    as Goal['type'] },
  { amount: 15_000, type: 'transport'    as Goal['type'] },
  { amount: 40_000, type: 'registration' as Goal['type'] },
];

for (const p of payments9) {
  simulatePayment(goals9, p.amount, p.type);
}

expect('[S9] Fournitures = 12 000 F',          goals9[0]!.savedAmount, 12_000);
expect('[S9] Fournitures status = completed',  goals9[0]!.status, 'completed');
expect('[S9] Scolarite = 60 000 F',            goals9[1]!.savedAmount, 60_000);
expect('[S9] Scolarite status = completed',    goals9[1]!.status, 'completed');
expect('[S9] Transport = 25 000 F',            goals9[2]!.savedAmount, 25_000);
expect('[S9] Transport status = completed',    goals9[2]!.status, 'completed');
expect('[S9] Reste global = 0 F',             goals9.reduce((s, g) => s + remaining(g), 0), 0);

// ─────────────────────────────────────────────────────────────────────────────
//  RAPPORT FINAL
// ─────────────────────────────────────────────────────────────────────────────
console.log('\n' + '='.repeat(62));
console.log(`${B}RAPPORT FINAL - Moteur de Cotisation EduPay${E}`);
console.log('='.repeat(62));
console.log(`  Tests PASS : ${B}${_pass}${E}`);
console.log(`  Tests FAIL : ${_fail > 0 ? R : G} ${B}${_fail}${E}`);

if (_failures.length > 0) {
  console.log(`\n${Y} Tests echoues :`);
  for (const f of _failures) {
    console.log(`   - ${f}`);
  }
}

// Statistiques detaillees Scenario 9
console.log('\n' + '-'.repeat(62));
console.log(`${B}Statistiques detaillees — Scenario 9 (3 objectifs boules)${E}`);
console.log('-'.repeat(62));

const labels9: Record<string, string> = {
  'G9-SUP': 'Fournitures scolaires',
  'G9-TUI': 'Scolarite',
  'G9-TRA': 'Moyen de deplacement',
};

for (const g of goals9) {
  const pct = Math.round(progress(g) * 100);
  const rem = remaining(g);
  console.log(
    `  ${g.status === 'completed' ? G : Y} ${labels9[g.id] ?? g.id}\n` +
    `       Objectif : ${g.targetAmount} FCFA\n` +
    `       Verse    : ${g.savedAmount} FCFA\n` +
    `       Restant  : ${rem} FCFA\n` +
    `       Progress : ${pct} %\n` +
    `       Statut   : ${g.status}`,
  );
}

const totalTarget9 = goals9.reduce((s, g) => s + g.targetAmount, 0);
const totalSaved9  = goals9.reduce((s, g) => s + g.savedAmount, 0);
const totalRemain9 = goals9.reduce((s, g) => s + remaining(g), 0);

console.log('\n' + '-'.repeat(62));
console.log(`  ${B}GLOBAL (Scenario 9)${E}`);
console.log(`  Objectifs crees  : 3 (1 Fournitures, 1 Scolarite, 1 Transport)`);
console.log(`  Paiements faits  : ${payments9.length}`);
console.log(`  Total objectif   : ${totalTarget9} FCFA`);
console.log(`  Total verse      : ${totalSaved9} FCFA`);
console.log(`  Reste global     : ${totalRemain9} FCFA`);
console.log(`  Progression      : ${Math.round((totalSaved9 / totalTarget9) * 100)} %`);
console.log(`  Anomalies        : ${_fail === 0 ? 'Aucune' : `${_fail} ERREUR(S) detectee(s)`}`);
console.log('='.repeat(62) + '\n');

if (_fail > 0) process.exit(1);
