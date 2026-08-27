import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Barre de progression fine (motif `.pb`/`.pf` du prototype), utilisée
/// pour les objectifs d'épargne et les statistiques de kits.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.color = AppColors.green,
  });

  /// Progression entre 0 et 1.
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: 6,
        backgroundColor: AppColors.surfaceBorder,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
