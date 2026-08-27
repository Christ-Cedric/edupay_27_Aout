import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radii.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Variantes reprises du prototype (`.btn.by/.bg/.bo/.br`).
enum AppButtonVariant { gold, green, outline, danger }

/// Bouton pilule standard de l'app.
///
/// Hauteur minimale forcée à [AppSpacing.minTapTarget] (charte graphique,
/// principe non négociable n°1) même si le libellé est court.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.gold,
    this.icon,
    this.expanded = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expanded;
  final bool loading;

  (Color, Color, Color?) get _colors => switch (variant) {
    AppButtonVariant.gold => (AppColors.gold, AppColors.navy, null),
    AppButtonVariant.green => (AppColors.green, AppColors.navy, null),
    AppButtonVariant.outline => (
      Colors.transparent,
      Colors.white,
      AppColors.inputBorder,
    ),
    AppButtonVariant.danger => (
      const Color(0x26E53935),
      AppColors.danger,
      const Color(0x4DE53935),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = _colors;
    final disabled = onPressed == null || loading;

    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.button.copyWith(color: foreground),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final button = Opacity(
      opacity: disabled && !loading ? 0.4 : 1,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: border != null ? BorderSide(color: border) : BorderSide.none,
        ),
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTapTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
