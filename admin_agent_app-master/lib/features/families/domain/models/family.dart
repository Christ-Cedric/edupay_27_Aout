import 'package:freezed_annotation/freezed_annotation.dart';

import 'delivery_status.dart';
import 'family_status.dart';
import 'savings_plan.dart';

part 'family.freezed.dart';

/// Un enfant d'une famille, avec son propre kit (§7 #2 du contrat : kit par
/// enfant, pas par famille — le plan et l'objectif restent au niveau du
/// foyer, l'objectif étant la somme des kits de chaque enfant).
///
/// `level`/`school` sont des chaînes libres (pas d'enum côté backend, motif
/// `Child.level`/`Child.school`) — vides si non renseignées. Un enfant
/// persiste indépendamment des saisons ; `kitId`/`targetAmount`/`savedAmount`
/// sont nuls tant qu'aucun kit n'a été choisi pour la saison en cours (état
/// normal en début de saison, avant le passage par `assignKit`).
@freezed
sealed class FamilyChild with _$FamilyChild {
  const factory FamilyChild({
    required String id,
    required String firstName,
    required String level,
    required String school,
    String? kitId,
    double? targetAmount,
    double? savedAmount,
    // Objectif scolarité (frais de scolarité) — null si non renseigné.
    double? tuitionAmount,
    double? tuitionSavedAmount,
    // Objectif transport — null si non renseigné.
    double? transportAmount,
    double? transportSavedAmount,
    String? transportType,
  }) = _FamilyChild;
}

extension FamilyChildProgress on FamilyChild {
  bool get hasKitThisSeason => kitId != null;

  double get kitPrice => targetAmount ?? 0;

  double get totalCost =>
      (targetAmount ?? 0) + (tuitionAmount ?? 0) + (transportAmount ?? 0);

  double get progress {
    final target = targetAmount;
    final saved = savedAmount;
    if (target == null || saved == null || target == 0) return 0;
    return (saved / target).clamp(0, 1);
  }
}

/// Une famille inscrite (motif `ad_fa`/`ad_do` du prototype).
@freezed
sealed class Family with _$Family {
  const factory Family({
    required String id,
    required String fullName,
    required String phone,
    required String city,
    required SavingsPlan plan,
    required double balance,
    required double targetAmount,
    required List<FamilyChild> children,
    required FamilyStatus status,
    required DeliveryStatus deliveryStatus,
    required DateTime registeredAt,
    String? assignedAgentName,
    String? rejectionReason,
    String? district,
    String? familyCode,
  }) = _Family;
}

extension FamilyProgress on Family {
  double get progress =>
      targetAmount == 0 ? 0 : (balance / targetAmount).clamp(0, 1);

  int get childrenCount => children.length;
}
