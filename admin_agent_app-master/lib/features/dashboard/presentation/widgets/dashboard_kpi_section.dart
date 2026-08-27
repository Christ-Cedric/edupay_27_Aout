import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/widgets/kpi_tile.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/dashboard_summary.dart';

/// Grille de KPI du dashboard (motif `.kg` du prototype, en deux groupes).
class DashboardKpiSection extends StatelessWidget {
  const DashboardKpiSection({
    super.key,
    required this.summary,
    this.onFamiliesTap,
    this.onFinancesTap,
    this.onOverdueTap,
    this.onAgentsTap,
    this.onDeliveriesTap,
  });

  final DashboardSummary summary;

  /// Navigation vers la liste des familles — l'écran conteneur décide de la
  /// route, ce widget de présentation ne connaît pas le routeur.
  final VoidCallback? onFamiliesTap;

  /// Navigation vers le bilan financier (tuiles Total collecté / Taux cotisation).
  final VoidCallback? onFinancesTap;

  /// Navigation vers les alertes impayés.
  final VoidCallback? onOverdueTap;

  /// Navigation vers la liste des agents.
  final VoidCallback? onAgentsTap;

  /// Navigation vers le suivi des livraisons.
  final VoidCallback? onDeliveriesTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KpiGrid(
          tiles: [
            KpiTile(
              value: '${summary.activeFamilies}',
              label: 'Familles actives',
              onTap: onFamiliesTap,
            ),
            KpiTile(
              value: formatCompactCurrency(summary.totalCollected),
              label: 'Total collecté',
              valueColor: AppColors.green,
              onTap: onFinancesTap,
            ),
            KpiTile(
              value: '${(summary.collectionRate * 100).round()}%',
              label: 'Taux cotisation',
              onTap: onFinancesTap,
            ),
            KpiTile(
              value: '${summary.overduePayments}',
              label: 'Impayés',
              valueColor: AppColors.danger,
              onTap: onOverdueTap,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        KpiGrid(
          tiles: [
            KpiTile(
              value: '${summary.activeAgents}',
              label: 'Agents actifs',
              onTap: onAgentsTap,
            ),
            KpiTile(
              value: '${summary.pendingDeliveries}',
              label: 'Livraisons à faire',
              valueColor: AppColors.info,
              onTap: onDeliveriesTap,
            ),
          ],
        ),
      ],
    );
  }
}
