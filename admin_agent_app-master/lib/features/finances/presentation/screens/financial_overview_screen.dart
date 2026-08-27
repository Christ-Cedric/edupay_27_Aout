import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/theme/widgets/nav_row.dart';
import '../../../../core/theme/widgets/tap_target.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../core/export/csv_exporter.dart';
import '../../../families/domain/models/savings_plan.dart';
import '../../../seasons/presentation/providers/seasons_providers.dart';
import '../../domain/models/finance_summary.dart';
import '../providers/finance_providers.dart';

/// Lignes CSV du bilan financier — réutilisée telle quelle par le rapport
/// "financier" de l'écran Rapports & exports (même donnée, pas de notion de
/// marge/projection disponible ailleurs dans l'app).
List<List<String>> buildFinanceSummaryRows(FinanceSummary summary) {
  return [
    ['Résumé', 'Total collecté', '${summary.activeFamilies}', formatCurrency(summary.totalCollected)],
    for (final city in summary.byCity)
      ['Par ville', city.city, '${city.familyCount}', formatCurrency(city.amount)],
    for (final plan in summary.byPlan)
      ['Par plan', plan.plan.label, '${plan.familyCount}', formatCurrency(plan.amount)],
  ];
}

const financeSummaryCsvHeaders = ['Section', 'Libellé', 'Familles', 'Montant'];

/// Bilan financier de la saison (motif `ad_fi` du prototype).
class FinancialOverviewScreen extends ConsumerWidget {
  const FinancialOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financeSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: const AppHeader(title: 'Finances'),
      body: summaryAsync.when(
        data: (summary) => _FinancialOverviewBody(summary: summary),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(financeSummaryProvider)),
      ),
    );
  }
}

class _FinancialOverviewBody extends ConsumerStatefulWidget {
  const _FinancialOverviewBody({required this.summary});

  final FinanceSummary summary;

  @override
  ConsumerState<_FinancialOverviewBody> createState() =>
      _FinancialOverviewBodyState();
}

class _FinancialOverviewBodyState
    extends ConsumerState<_FinancialOverviewBody> {
  /// Nombre de villes affichées avant de proposer "Voir plus" — le
  /// prototype n'en montre que 2 sur son jeu de données figé, mais une
  /// vraie saison peut couvrir bien plus de villes.
  static const _collapsedCityCount = 3;
  bool _showAllCities = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    // Dégradation gracieuse si la saison ne charge pas : le bilan financier
    // reste utilisable, seul le suffixe "SAISON X" disparaît (même motif
    // que le libellé de saison dans kits_catalog_screen.dart).
    final seasonLabel = ref
        .watch(currentSeasonProvider)
        .maybeWhen(data: (season) => season.label, orElse: () => null);
    final hiddenCities = summary.byCity.length - _collapsedCityCount;
    final visibleCities = _showAllCities || hiddenCities <= 0
        ? summary.byCity
        : summary.byCity.take(_collapsedCityCount).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                seasonLabel == null
                    ? 'TOTAL COLLECTÉ'
                    : 'TOTAL COLLECTÉ - SAISON $seasonLabel',
                style: AppTextStyles.sectionLabel,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                formatCurrency(summary.totalCollected),
                style: AppTextStyles.kpiNumber,
              ),
              const SizedBox(height: 2),
              Text(
                '${summary.activeFamilies} familles actives',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('PAR VILLE', style: AppTextStyles.sectionLabel),
        const SizedBox(height: AppSpacing.sm),
        for (final city in visibleCities)
          KeyValueRow(
            label: '${city.city} (${city.familyCount} fam.)',
            // Montant exact (pas compact) : ces lignes servent à vérifier
            // qu'elles totalisent bien le montant global au-dessus.
            value: formatCurrency(city.amount),
            valueColor: AppColors.gold,
            showDivider: city != visibleCities.last,
          ),
        if (hiddenCities > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TapTarget(
              onTap: () => setState(() => _showAllCities = !_showAllCities),
              child: Text(
                _showAllCities ? 'Voir moins' : 'Voir plus ($hiddenCities)',
                style: AppTextStyles.tag.copyWith(color: AppColors.gold),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        const Text('PAR PLAN', style: AppTextStyles.sectionLabel),
        const SizedBox(height: AppSpacing.sm),
        for (final plan in summary.byPlan)
          KeyValueRow(
            label: '${plan.plan.label} (${plan.familyCount} fam.)',
            value: formatCurrency(plan.amount),
            showDivider: plan != summary.byPlan.last,
          ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Exporter le rapport Excel',
          onPressed: () async {
            try {
              await exportCsvAndShare(
                fileName: 'bilan_finances.csv',
                headers: financeSummaryCsvHeaders,
                rows: buildFinanceSummaryRows(summary),
              );
            } catch (_) {
              if (context.mounted) {
                showAppToast(
                  context,
                  'Échec de l\'export.',
                  type: AppToastType.error,
                );
              }
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('AUTRES SECTIONS', style: AppTextStyles.sectionLabel),
        const SizedBox(height: AppSpacing.sm),
        AppNavRow(
          label: 'Rapports & exports',
          onTap: () => context.push('/admin/finances/reports'),
        ),
        AppNavRow(
          label: 'Remboursements',
          onTap: () => context.push('/admin/finances/refunds'),
        ),
        AppNavRow(
          label: 'Suivi livraisons',
          onTap: () => context.push('/admin/finances/deliveries'),
        ),
      ],
    );
  }
}
