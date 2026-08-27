import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radii.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Variantes reprises du prototype (`.tag.g/.y/.r/.b/.w`).
enum AppTagVariant { gold, green, danger, info, neutral }

/// Badge de statut compact — utilisé pour tous les statuts affichés dans
/// l'app (famille, livraison, remboursement, compte en attente...).
///
/// Purement visuel : pour un badge cliquable (ex. filtre), l'envelopper
/// dans un [InkWell] avec une zone tactile d'au moins 48×48 px plutôt que
/// d'agrandir ce widget lui-même.
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.variant = AppTagVariant.neutral,
  });

  final String label;
  final AppTagVariant variant;

  (Color, Color) get _colors => switch (variant) {
    AppTagVariant.gold => (const Color(0x26FFD600), AppColors.gold),
    AppTagVariant.green => (const Color(0x2600C853), AppColors.green),
    AppTagVariant.danger => (const Color(0x26E53935), AppColors.danger),
    AppTagVariant.info => (const Color(0x265DA5FF), AppColors.info),
    AppTagVariant.neutral => (const Color(0x1AFFFFFF), AppColors.textTertiary),
  };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Text(label, style: AppTextStyles.tag.copyWith(color: foreground)),
    );
  }
}
