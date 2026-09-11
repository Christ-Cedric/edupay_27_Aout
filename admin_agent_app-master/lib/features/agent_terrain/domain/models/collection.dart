import 'package:freezed_annotation/freezed_annotation.dart';

import 'collection_mode.dart';

part 'collection.freezed.dart';

/// Détail de répartition d'une cotisation par objectif d'épargne.
@freezed
sealed class CollectionAllocation with _$CollectionAllocation {
  const factory CollectionAllocation({
    required String goalType,
    required double amount,
    String? childName,
    String? goalName,
  }) = _CollectionAllocation;
}

/// Un encaissement de cotisation par un agent terrain (motif `ag_en`/`ag_rc`
/// du prototype).
@freezed
sealed class Collection with _$Collection {
  const factory Collection({
    required String id,
    required String familyId,
    required String familyName,
    required String agentName,
    required double amount,
    required CollectionMode mode,
    required DateTime collectedAt,
    required String receiptNumber,
    /// Catégorie d'épargne ciblée par cet encaissement. Null = non spécifiée
    /// (cotisation globale répartie sur tous les objectifs actifs).
    String? targetGoalType,
    @Default([]) List<CollectionAllocation> allocations,
  }) = _Collection;
}

/// Libellé français de la catégorie d'épargne, aligné sur [SavingsGoalType]
/// de l'app Client (`parent_models.dart`).
extension CollectionGoalTypeLabel on Collection {
  String get goalTypeLabel => switch (targetGoalType) {
        'supplies' => 'Fournitures',
        'registration' => 'Scolarité',
        'transport' => 'Déplacement',
        'exam' => 'Examen',
        'canteen' => 'Cantine',
        'uniform' => 'Tenue',
        _ => allocations.isNotEmpty
            ? 'Répartition multi-objectifs'
            : 'Cotisation globale',
      };

  /// Vrai si cet encaissement cible une catégorie précise (pas une répartition
  /// générale sur tous les objectifs actifs).
  bool get hasSpecificGoal => targetGoalType != null;
}
