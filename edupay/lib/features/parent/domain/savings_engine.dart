import 'parent_models.dart';
import 'school_catalogue.dart';

/// Moteur de calcul d'épargne scolaire.
///
/// Principe (voir la spécification produit) :
/// - la date limite est **fixe** ([kSubscriptionDeadline], le 15 septembre) ;
/// - chaque enfant a un objectif = coût total de son/ses kit(s) ;
/// - le **reste global** = Σ des restes dus de chaque enfant ;
/// - ce reste global est réparti sur le **temps restant** jusqu'à la date
///   limite selon la fréquence choisie (journalier / hebdomadaire / mensuel) ;
/// - à chaque évènement (paiement, ajout/suppression d'enfant, changement de
///   kit ou de date), on **recalcule tout** à partir de l'état courant : il n'y
///   a jamais de calendrier séparé par enfant. Un enfant ajouté tardivement
///   voit simplement son coût s'ajouter au reste global, et une nouvelle
///   cotisation par période est recalculée sur le temps restant — si bien que
///   tous les enfants atteignent 100 % au plus tard à la même date.
///
/// Le moteur est **pur** (aucun effet de bord, `now`/`deadline` injectables)
/// donc entièrement testable et réutilisable hors de la couche présentation.

/// Date limite fixe de la campagne : tous les objectifs doivent être financés
/// à 100 % au plus tard à cette date.
final DateTime kSubscriptionDeadline = DateTime(2026, 9, 15);

/// Résultat immuable d'un calcul de plan d'épargne à un instant donné.
class SavingsPlanComputation {
  const SavingsPlanComputation({
    required this.frequency,
    required this.deadline,
    required this.totalGoal,
    required this.totalSaved,
    required this.globalRemaining,
    required this.periodsRemaining,
    required this.perPeriodAmount,
    required this.hasChildren,
    required this.goalReached,
    required this.expired,
  });

  final SavingsPlan frequency;
  final DateTime deadline;

  /// Objectif global = somme des coûts des kits de tous les enfants.
  final int totalGoal;

  /// Somme des montants déjà épargnés (bornée à l'objectif : pas de sur-épargne).
  final int totalSaved;

  /// Reste global à épargner = Σ max(0, coût_enfant − épargne_enfant).
  final int globalRemaining;

  /// Nombre de périodes restantes avant la date limite (0 si expirée).
  final int periodsRemaining;

  /// Montant à cotiser par période pour atteindre 100 % à la date limite.
  /// - 0 si l'objectif est déjà atteint (ou aucun enfant) ;
  /// - la totalité du reste si la date limite est dépassée (dû immédiatement).
  final int perPeriodAmount;

  final bool hasChildren;
  final bool goalReached;

  /// Vrai si la date limite est atteinte/dépassée alors qu'il reste à payer.
  final bool expired;

  /// Progression globale en pourcentage (0–100).
  int get progressPercent => totalGoal == 0
      ? 0
      : ((totalSaved / totalGoal) * 100).round().clamp(0, 100);
}

/// Calcule le plan d'épargne courant à partir de l'état des enfants.
///
/// Recalcul complet et déterministe : appeler cette fonction après **chaque**
/// évènement (paiement, ajout/suppression, changement de kit ou de date)
/// suffit à garder le plan à jour.
SavingsPlanComputation computeSavingsPlan({
  required List<ChildProfile> children,
  required SavingsPlan frequency,
  DateTime? now,
  DateTime? deadline,
  SavingsGoalType? targetGoalType,
}) {
  final effectiveDeadline = deadline ?? kSubscriptionDeadline;
  final reference = now ?? DateTime.now();

  var totalGoal = 0;
  var totalSavedTowardGoal = 0;
  var globalRemaining = 0;
  for (final child in children) {
    int cost = 0;
    int saved = 0;

    if (targetGoalType == null) {
      cost = child.totalCost;
      saved = child.savedAmount;
    } else {
      switch (targetGoalType) {
        case SavingsGoalType.supplies:
        case SavingsGoalType.exam:
        case SavingsGoalType.canteen:
        case SavingsGoalType.uniform:
          cost = child.suppliesCost;
          saved = child.kitSavedAmount;
          break;
        case SavingsGoalType.registration:
          cost = child.tuitionAmount;
          saved = child.tuitionSavedAmount;
          break;
        case SavingsGoalType.transport:
          cost = child.transportAmount;
          saved = child.transportSavedAmount;
          break;
      }
    }

    final savedTowardGoal = saved.clamp(0, cost);
    totalGoal += cost;
    totalSavedTowardGoal += savedTowardGoal;
    globalRemaining += cost - savedTowardGoal; // toujours >= 0
  }

  final hasChildren = children.isNotEmpty;
  final goalReached = totalGoal > 0 && globalRemaining <= 0;
  // Expirée seulement s'il reste effectivement quelque chose à payer.
  final periodsAvailable = _periodsUntil(
    reference,
    effectiveDeadline,
    frequency,
  );
  final expired = globalRemaining > 0 && periodsAvailable <= 0;

  final int perPeriodAmount;
  if (globalRemaining <= 0) {
    perPeriodAmount = 0;
  } else if (periodsAvailable <= 0) {
    // Période expirée : la totalité du reste est due immédiatement.
    perPeriodAmount = globalRemaining;
  } else {
    // Arrondi au supérieur pour garantir 100 % au plus tard à la date limite.
    perPeriodAmount = (globalRemaining / periodsAvailable).ceil();
  }

  return SavingsPlanComputation(
    frequency: frequency,
    deadline: effectiveDeadline,
    totalGoal: totalGoal,
    totalSaved: totalSavedTowardGoal,
    globalRemaining: globalRemaining,
    periodsRemaining: periodsAvailable < 0 ? 0 : periodsAvailable,
    perPeriodAmount: perPeriodAmount,
    hasChildren: hasChildren,
    goalReached: goalReached,
    expired: expired,
  );
}

/// Nombre de périodes entières restantes entre [from] et [to] pour la fréquence
/// donnée. Renvoie 0 si la date limite est atteinte/dépassée.
int _periodsUntil(DateTime from, DateTime to, SavingsPlan frequency) {
  final days = to.difference(from).inDays;
  if (days <= 0) return 0;
  return switch (frequency) {
    SavingsPlan.daily => days,
    SavingsPlan.weekly => (days / 7).ceil(),
    SavingsPlan.monthly => (days / 30).ceil(),
  };
}

/// Répartit [amount] entre les enfants au prorata de leur **reste dû**, plafonné
/// au reste de chacun. L'arrondi est absorbé par le dernier enfant ayant encore
/// un reste, afin que la somme allouée soit exacte.
///
/// Cas limites gérés :
/// - **paiement supérieur au reste global** : l'excédent n'est pas alloué (aucun
///   enfant ne dépasse son objectif) ;
/// - **enfant déjà soldé** (reste 0) : ignoré ;
/// - **aucun enfant / aucun reste** : renvoie des parts nulles.
///
/// La répartition au prorata du *reste* (et non du coût total) garantit que tous
/// les enfants convergent vers 100 % à la même échéance.
List<int> allocateContribution({
  required List<int> remainingByChild,
  required int amount,
}) {
  final count = remainingByChild.length;
  final shares = List<int>.filled(count, 0);
  final dues = [for (final r in remainingByChild) r < 0 ? 0 : r];
  final globalRemaining = dues.fold(0, (total, r) => total + r);
  if (globalRemaining <= 0 || amount <= 0) return shares;

  // On n'alloue jamais plus que le reste global (paiement excédentaire borné).
  final capped = amount > globalRemaining ? globalRemaining : amount;

  var lastDue = -1;
  for (var i = 0; i < count; i++) {
    if (dues[i] > 0) lastDue = i;
  }

  var distributed = 0;
  for (var i = 0; i < count; i++) {
    if (dues[i] == 0) continue;
    if (i == lastDue) {
      // Le dernier enfant dû absorbe l'arrondi (reliquat exact).
      shares[i] = (capped - distributed).clamp(0, dues[i]);
    } else {
      shares[i] = ((capped * dues[i]) ~/ globalRemaining).clamp(0, dues[i]);
    }
    distributed += shares[i];
  }
  return shares;
}

/// Part d'une cotisation revenant à un enfant donné (au prorata de son reste),
/// utile pour l'affichage prévisionnel « prochaine échéance » par enfant.
int childShareOfContribution({
  required int contribution,
  required int childRemaining,
  required int globalRemaining,
}) {
  if (globalRemaining <= 0 || childRemaining <= 0 || contribution <= 0) {
    return 0;
  }
  final share = ((contribution * childRemaining) / globalRemaining).round();
  return share.clamp(0, childRemaining);
}
