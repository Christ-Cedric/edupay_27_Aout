import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Écran de chargement global plein écran (motif `g_ld` du prototype).
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.message = 'Chargement...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.navy,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}
