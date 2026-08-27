import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'key_value_row.dart';

/// Une ligne du récapitulatif affiché sur [SuccessRecapScreen].
class SuccessRecapEntry {
  const SuccessRecapEntry(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}

/// Écran de succès générique avec récapitulatif (motif `.suc`/`.rc`/`.rr` du
/// prototype, réutilisé pour `ad_ok` et pour l'approbation de compte).
///
/// Concrétise le principe charte n°4 : une confirmation visuelle forte après
/// chaque action.
class SuccessRecapScreen extends StatelessWidget {
  const SuccessRecapScreen({
    super.key,
    required this.title,
    required this.message,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.entries = const [],
    this.icon = Icons.celebration,
    this.iconVariant = AppCardVariant.success,
    this.iconColor,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String message;
  final List<SuccessRecapEntry> entries;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final IconData icon;
  final AppCardVariant iconVariant;

  /// Remplace la couleur dérivée de [iconVariant] (ex. bleu info, absent des
  /// variantes de carte) sans avoir à étendre [AppCardVariant] pour un seul
  /// écran.
  final Color? iconColor;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  Color get _iconColor =>
      iconColor ??
      switch (iconVariant) {
        AppCardVariant.danger => AppColors.danger,
        AppCardVariant.warning => AppColors.gold,
        _ => AppColors.green,
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.navy, size: 30),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                children: [
                  for (final entry in entries)
                    KeyValueRow(
                      label: entry.label,
                      value: entry.value,
                      valueColor: entry.valueColor,
                      showDivider: entry != entries.last,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: primaryActionLabel, onPressed: onPrimaryAction),
          if (secondaryActionLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: secondaryActionLabel!,
              onPressed: onSecondaryAction,
              variant: AppButtonVariant.outline,
            ),
          ],
        ],
      ),
    );
  }
}
