import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radii.dart';
import '../app_spacing.dart';

/// Variantes de teinte reprises du prototype (`.card`, `.card.g/.y/.r/.dk`).
enum AppCardVariant { neutral, success, warning, danger, solidGreen }

/// Carte standard de l'app — toute mise en carte doit passer par ce widget
/// plutôt que par un [Container] ad hoc, pour rester visuellement cohérente.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.neutral,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  (Color, Color) get _colors => switch (variant) {
    AppCardVariant.neutral => (AppColors.surface, AppColors.surfaceBorder),
    AppCardVariant.success => (
      const Color(0x1200C853),
      const Color(0x3300C853),
    ),
    AppCardVariant.warning => (
      const Color(0x0DFFD600),
      const Color(0x33FFD600),
    ),
    AppCardVariant.danger => (const Color(0x12E53935), const Color(0x33E53935)),
    AppCardVariant.solidGreen => (
      const Color(0xFF1B7340),
      const Color(0xFF145530),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (background, border) = _colors;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: border),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: content,
      ),
    );
  }
}
