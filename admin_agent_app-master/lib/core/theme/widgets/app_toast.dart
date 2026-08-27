import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radii.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Type de retour affiché par [showAppToast] (motif `.tos` du prototype).
enum AppToastType { success, error }

/// Confirmation visuelle forte après une action (charte graphique, principe
/// non négociable n°4) — à utiliser après chaque mutation (approuver,
/// encaisser, envoyer un SMS de relance...).
void showAppToast(
  BuildContext context,
  String message, {
  AppToastType type = AppToastType.success,
}) {
  final color = type == AppToastType.success
      ? AppColors.green
      : AppColors.danger;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: color.withValues(alpha: .4)),
        ),
        content: Row(
          children: [
            Icon(
              type == AppToastType.success ? Icons.check_circle : Icons.error,
              color: color,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message, style: AppTextStyles.body)),
          ],
        ),
      ),
    );
}
