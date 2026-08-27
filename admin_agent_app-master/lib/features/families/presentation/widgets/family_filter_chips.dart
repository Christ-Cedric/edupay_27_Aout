import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/widgets/app_tag.dart';
import '../../domain/models/family_status.dart';

class FamilyFilterChips extends StatelessWidget {
  const FamilyFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onPendingTap,
  });

  final FamilyStatus? selected;
  final ValueChanged<FamilyStatus?> onSelected;
  final VoidCallback onPendingTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        _Chip(
          label: 'Toutes',
          variant: AppTagVariant.green,
          selected: selected == null,
          onTap: () => onSelected(null),
        ),
        _Chip(
          label: 'Actives',
          variant: AppTagVariant.green,
          selected: selected == FamilyStatus.active,
          onTap: () => onSelected(FamilyStatus.active),
        ),
        _Chip(
          label: 'Inactives',
          variant: AppTagVariant.neutral,
          selected: selected == FamilyStatus.rejected,
          onTap: () => onSelected(FamilyStatus.rejected),
        ),
        _Chip(
          label: 'Impayées',
          variant: AppTagVariant.danger,
          selected: selected == FamilyStatus.lateOverdue,
          onTap: () => onSelected(FamilyStatus.lateOverdue),
        ),
        _Chip(
          label: 'En attente',
          variant: AppTagVariant.gold,
          selected: selected == FamilyStatus.pendingValidation,
          onTap: onPendingTap,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AppTagVariant variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.tag),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        child: Center(
          child: Opacity(
            opacity: selected ? 1 : .5,
            child: AppTag(label: label, variant: variant),
          ),
        ),
      ),
    );
  }
}
