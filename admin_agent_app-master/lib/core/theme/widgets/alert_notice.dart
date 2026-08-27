import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radii.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Variantes reprises du prototype (`.nt`, `.nt.w/.r/.b`).
enum AlertNoticeVariant { neutral, warning, danger, info }

/// Notice d'alerte à bordure gauche colorée (motif `.nt` du prototype) —
/// utilisée pour les alertes du Dashboard, notifications, rappels.
class AlertNotice extends StatelessWidget {
  const AlertNotice({
    super.key,
    required this.title,
    required this.subtitle,
    this.variant = AlertNoticeVariant.neutral,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final AlertNoticeVariant variant;
  final VoidCallback? onTap;

  Color get _borderColor => switch (variant) {
    AlertNoticeVariant.neutral => AppColors.green,
    AlertNoticeVariant.warning => AppColors.gold,
    AlertNoticeVariant.danger => AppColors.danger,
    AlertNoticeVariant.info => AppColors.info,
  };

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.card - 3);

    // Un `Border(left: ...)` combiné à un `borderRadius` non nul n'est pas
    // peint correctement par BoxDecoration (le trait de gauche se détache
    // du coin arrondi au lieu d'y rester accolé) — la barre colorée est donc
    // un simple bloc dans un Row plutôt qu'un `border`, seule façon fiable
    // de reproduire le `border-left` du CSS source sous Flutter. Le fond
    // est porté par [Material] lui-même (plutôt qu'un Container/ColoredBox
    // enfant) pour que l'effet d'encre du [InkWell] reste visible au tap
    // au lieu d'être masqué par un fond opaque par-dessus.
    final row = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 3, color: _borderColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyStrong),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          // Même affordance que KpiTile : sans elle, rien ne distingue une
          // carte cliquable d'une simple notice informative.
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: Icon(Icons.chevron_right, size: 18, color: AppColors.green),
              ),
            ),
        ],
      ),
    );

    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? row : InkWell(onTap: onTap, child: row),
    );
  }
}
