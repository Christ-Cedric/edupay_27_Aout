import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radii.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Tuile de KPI (motif `.kpi` du prototype) : un nombre en évidence + un
/// libellé. Utilisée en grille via [KpiGrid] sur les écrans de tableau de
/// bord (Dashboard, Finances, Livraisons, Rapport agent...).
class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.value,
    required this.label,
    this.valueColor = AppColors.gold,
    this.onTap,
  });

  final String value;
  final String label;
  final Color valueColor;

  /// Quand fourni, la tuile devient tappable (ex. renvoyer vers l'écran
  /// détaillé du KPI). `null` par défaut : rendu strictement identique aux
  /// usages existants qui ne le passent pas.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadii.card - 2),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTextStyles.kpiNumber.copyWith(color: valueColor),
              ),
              const SizedBox(height: 2),
              Text(label, style: AppTextStyles.kpiLabel),
            ],
          ),
          // Affordance visuelle : sans elle, rien ne distingue une tuile
          // cliquable d'une tuile purement informative (même fond, même
          // style) — repris du chevron déjà utilisé pour les lignes
          // cliquables ailleurs dans l'app (voir AppNavRow).
          if (onTap != null)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.chevron_right, size: 16, color: AppColors.green),
            ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card - 2),
      child: content,
    );
  }
}

/// Grille 2 colonnes de [KpiTile] (motif `.kg` du prototype).
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.tiles});

  final List<KpiTile> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.7,
      children: tiles,
    );
  }
}
