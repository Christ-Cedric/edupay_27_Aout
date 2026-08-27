import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// En-tête standard (motif `.hdr` du prototype) avec bouton retour optionnel
/// et un slot d'action à droite (ex. "Filtrer", "+").
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.backgroundColor = AppColors.navy,
    this.foregroundColor = AppColors.textPrimary,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.minTapTarget);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      // La couleur remplit toute la zone (y compris sous la barre de statut,
      // comme un AppBar Material standard) ; SafeArea repousse le contenu
      // interactif en dessous pour qu'il ne soit jamais masqué par elle.
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: AppSpacing.minTapTarget,
                  child: onBack != null
                      ? IconButton(
                          onPressed: onBack,
                          icon: Icon(Icons.arrow_back, color: foregroundColor),
                        )
                      : null,
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headerTitle.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.minTapTarget, child: trailing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
