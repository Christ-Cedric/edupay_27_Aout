import 'package:flutter/material.dart';

import '../../../../core/theme/widgets/app_tag.dart';
import '../../domain/models/family_status.dart';

/// Badge de statut d'une famille — centralise le mapping statut → couleur
/// pour rester cohérent partout où une famille est affichée.
class FamilyStatusTag extends StatelessWidget {
  const FamilyStatusTag({super.key, required this.status});

  final FamilyStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, variant) = switch (status) {
      FamilyStatus.active => ('Actif', AppTagVariant.green),
      FamilyStatus.lateOverdue => ('Impayé', AppTagVariant.danger),
      FamilyStatus.pendingValidation => ('En attente', AppTagVariant.gold),
      FamilyStatus.rejected => ('Rejeté', AppTagVariant.neutral),
    };
    return AppTag(label: label, variant: variant);
  }
}
