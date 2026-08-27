/**
 * Répartition prorata multi-enfants (contrat §6.1) : un versement global est
 * automatiquement réparti entre les objectifs d'épargne actifs d'une famille
 * — le parent ne choisit JAMAIS quel enfant/objectif créditer.
 *
 * Fonction générique réutilisée dans les deux sens :
 *  - cotisation (créditer) : `capacity` = besoin restant (target − saved) ;
 *  - remboursement (débiter) : `capacity` = solde actuellement disponible
 *    (saved) à retirer.
 * Dans les deux cas, `capacity` borne ce qu'un objectif peut absorber, et
 * l'appelant garantit `amount <= somme des capacités` avant d'appeler cette
 * fonction (voir `assertWithinCapacity`) — sans quoi il faudrait décider quoi
 * faire de l'excédent, ce qui n'a pas de réponse sûre à ce stade.
 */

export interface Allocatable {
  savingsGoalId: string;
  childId: string | null;
  /** Montant maximum que cet objectif peut absorber pour cette opération. */
  capacity: number;
}

export interface Allocation {
  savingsGoalId: string;
  childId: string | null;
  amount: number;
}

/** Lève si `amount` dépasse la somme des capacités (voir doc de module). */
export function assertWithinCapacity(amount: number, goals: Allocatable[]): number {
  const total = goals.reduce((sum, g) => sum + g.capacity, 0);
  if (amount > total) {
    throw new RangeError(
      `Montant (${amount}) supérieur à la capacité totale disponible (${total}).`,
    );
  }
  return total;
}

/**
 * Répartit `amount` proportionnellement à `capacity` parmi les objectifs
 * ayant une capacité strictement positive. La somme des montants alloués vaut
 * exactement `amount` (le reliquat d'arrondi va aux objectifs dont la part
 * fractionnaire est la plus grande — méthode du plus grand reste).
 *
 * Cas particulier (et actuellement le seul rencontré en pratique, aucun
 * `Child`/objectif multiple n'existant encore en base — voir §7 #2) : un seul
 * objectif actif → il reçoit `amount` en entier, sans calcul de proportion.
 */
export function allocateProrata(amount: number, goals: Allocatable[]): Allocation[] {
  const eligible = goals.filter((g) => g.capacity > 0);
  if (eligible.length === 0) {
    throw new RangeError('allocateProrata : aucun objectif avec une capacité disponible.');
  }
  if (amount === 0) return [];

  if (eligible.length === 1) {
    const only = eligible[0]!;
    return [{ savingsGoalId: only.savingsGoalId, childId: only.childId, amount }];
  }

  assertWithinCapacity(amount, eligible);
  const totalCapacity = eligible.reduce((sum, g) => sum + g.capacity, 0);

  const raw = eligible.map((g) => (amount * g.capacity) / totalCapacity);
  const floored = raw.map(Math.floor);
  const distributed = floored.reduce((a, b) => a + b, 0);
  const remainder = amount - distributed;

  const byFractionDesc = raw
    .map((v, i) => ({ i, frac: v - floored[i]! }))
    .sort((a, b) => b.frac - a.frac);

  const amounts = [...floored];
  for (let k = 0; k < remainder; k++) {
    const idx = byFractionDesc[k % byFractionDesc.length]!.i;
    amounts[idx] = amounts[idx]! + 1;
  }

  return eligible.map((g, i) => ({
    savingsGoalId: g.savingsGoalId,
    childId: g.childId,
    amount: amounts[i]!,
  }));
}
