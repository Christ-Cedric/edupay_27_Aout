import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Ligne de navigation vers un sous-écran (motif utilisé pour les hubs
/// Paramètres/Finances qui rattachent des écrans sans lien direct dans le
/// prototype — voir mémo d'audit du plan).
class AppNavRow extends StatelessWidget {
  const AppNavRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyStrong),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}
