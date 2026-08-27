import 'parent_models.dart';

/// Moteur de quotas figés (règle métier « Calcul des quotas et de
/// progression », 2026-07-24).
///
/// À la différence du [SavingsPlanComputation] (savings_engine.dart) — qui
/// recalcule en continu la cotisation par période à chaque lecture — la
/// VALEUR d'un quota est ici figée **une seule fois**, à la confirmation de la
/// souscription (une fois tous les kits choisis), et ne change plus jusqu'à la
/// fin de la campagne : `quotaValue = coût total des kits / périodes
/// restantes à cet instant`.
///
/// IMPORTANT (exigence explicite) : ce moteur ne remplace PAS la logique de
/// progression existante (barre de progression, seuils 25/50/75/100 %, verrou
/// des kits à 75 %, réinitialisation après réception) — il détermine
/// seulement QUAND un quota est considéré comme acquis. Une fois un quota
/// validé, sa valeur est créditée aux enfants exactement via le même
/// mécanisme qu'avant (`allocateContribution` / `ChildProfile.savedAmount`,
/// voir `ParentUseCases.makePayment`), qui reste inchangé.
class QuotaState {
  const QuotaState({
    required this.quotaValue,
    required this.subscriptionStartDate,
    required this.frequency,
    this.totalGoalAtFreeze = 0,
    this.quotasAcquired = 0,
    this.availableBalance = 0,
  });

  /// Valeur du quota au dernier calcul. Ne change QUE lorsqu'un nouveau kit
  /// est sélectionné et validé pour un enfant (voir règle métier « Recalcul
  /// lors de l'ajout d'un nouveau kit ») — jamais à la simple lecture, jamais
  /// pour un enfant ajouté sans kit, jamais pour un changement de fréquence.
  final int quotaValue;

  /// Date de référence (première confirmation de la souscription) pour
  /// compter les périodes écoulées et détecter un retard de paiement. Ne
  /// change PAS lors d'un recalcul de quotaValue (seule la valeur change).
  final DateTime subscriptionStartDate;
  final SavingsPlan frequency;

  /// Montant total des kits pris en compte au dernier calcul de [quotaValue]
  /// — sert à détecter qu'un NOUVEAU kit vient d'être sélectionné et validé
  /// (déclencheur du recalcul) : si le total actuel diffère de cette valeur,
  /// il faut recalculer ; sinon (enfant ajouté sans kit, fréquence changée),
  /// aucun recalcul.
  final int totalGoalAtFreeze;

  /// Nombre de quotas entièrement validés depuis le début de la campagne.
  /// Jamais réinitialisé ni diminué par un recalcul (règle : les quotas déjà
  /// validés restent définitivement acquis).
  final int quotasAcquired;

  /// Reliquat non encore transformé en quota complet (toujours < quotaValue).
  /// Aucun montant versé n'est perdu : il est reporté sur le prochain paiement.
  /// Conservé tel quel lors d'un recalcul.
  final int availableBalance;

  QuotaState copyWith({
    int? quotaValue,
    int? totalGoalAtFreeze,
    int? quotasAcquired,
    int? availableBalance,
  }) => QuotaState(
    quotaValue: quotaValue ?? this.quotaValue,
    subscriptionStartDate: subscriptionStartDate,
    frequency: frequency,
    totalGoalAtFreeze: totalGoalAtFreeze ?? this.totalGoalAtFreeze,
    quotasAcquired: quotasAcquired ?? this.quotasAcquired,
    availableBalance: availableBalance ?? this.availableBalance,
  );
}

/// Résultat de l'application d'un paiement à un [QuotaState].
class QuotaPaymentResult {
  const QuotaPaymentResult({
    required this.state,
    required this.quotasValidatedNow,
  });

  final QuotaState state;

  /// Nombre de quotas validés PAR ce paiement précis (0 si le paiement ne
  /// fait que grossir le reliquat sans compléter de quota — règle §4).
  final int quotasValidatedNow;
}

/// Applique un paiement de [amount] : l'ajoute au solde disponible puis valide
/// autant de quotas complets que possible (règles §2/§3/§4). Le reliquat
/// (toujours < quotaValue) est conservé pour le prochain paiement.
QuotaPaymentResult applyQuotaPayment(QuotaState state, int amount) {
  if (state.quotaValue <= 0 || amount <= 0) {
    return QuotaPaymentResult(state: state, quotasValidatedNow: 0);
  }
  var balance = state.availableBalance + amount;
  var validatedNow = 0;
  while (balance >= state.quotaValue) {
    balance -= state.quotaValue;
    validatedNow += 1;
  }
  return QuotaPaymentResult(
    state: state.copyWith(
      quotasAcquired: state.quotasAcquired + validatedNow,
      availableBalance: balance,
    ),
    quotasValidatedNow: validatedNow,
  );
}

/// Nombre de périodes ENTIÈREMENT écoulées entre [start] et [now] pour la
/// fréquence donnée (0 si aucune période complète n'est encore passée).
int periodsElapsedSince(DateTime start, DateTime now, SavingsPlan frequency) {
  final days = now.difference(start).inDays;
  if (days <= 0) return 0;
  return switch (frequency) {
    SavingsPlan.daily => days,
    SavingsPlan.weekly => days ~/ 7,
    SavingsPlan.monthly => days ~/ 30,
  };
}

/// Règle métier §6 : retard de paiement dès que le nombre de périodes qui
/// auraient dû être couvertes dépasse d'au moins 3 le nombre de quotas
/// effectivement validés (les quotas payés d'avance sont épuisés depuis au
/// moins 3 échéances consécutives).
bool isInArrears(QuotaState state, {DateTime? now}) {
  final elapsed = periodsElapsedSince(
    state.subscriptionStartDate,
    now ?? DateTime.now(),
    state.frequency,
  );
  return (elapsed - state.quotasAcquired) >= 3;
}
