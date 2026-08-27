import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_progress_bar.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../families/domain/models/family_filter.dart';
import '../../../families/presentation/providers/families_providers.dart';
import '../../domain/models/kit.dart';
import '../providers/kits_providers.dart';

const _kitColors = [AppColors.textSecondary, AppColors.gold, AppColors.green];

/// Statistiques des kits (motif `ad_st` du prototype) — répartition réelle
/// des familles par kit assigné.
class KitStatsScreen extends ConsumerWidget {
  const KitStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitsAsync = ref.watch(kitsListProvider);
    final familiesAsync = ref.watch(familiesListProvider(const FamilyFilter()));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Stats Kits', onBack: () => context.pop()),
      body: kitsAsync.when(
        data: (kits) => familiesAsync.when(
          data: (families) {
            // Un kit est assigné par enfant (§7 #2 du contrat), pas par
            // famille — la répartition et le panier moyen se comptent donc
            // sur l'ensemble des enfants, pas sur le nombre de familles.
            final allChildren = families.expand((f) => f.children).toList();
            final totalChildren = allChildren.length;
            final countByKit = <String, int>{
              for (final kit in kits)
                kit.id: allChildren.where((c) => c.kitId == kit.id).length,
            };
            final totalOrdersValue = kits.fold<double>(
              0,
              (sum, kit) => sum + (countByKit[kit.id] ?? 0) * kit.price,
            );
            final averageBasket = totalChildren == 0
                ? 0.0
                : totalOrdersValue / totalChildren;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const Text(
                  'RÉPARTITION DES KITS',
                  style: AppTextStyles.sectionLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (var i = 0; i < kits.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _KitBreakdownCard(
                      kit: kits[i],
                      count: countByKit[kits[i].id] ?? 0,
                      totalChildren: totalChildren,
                      color: _kitColors[i % _kitColors.length],
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'IMPACT PANIER MOYEN',
                  style: AppTextStyles.sectionLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Column(
                    children: [
                      KeyValueRow(
                        label: 'Panier moyen pondéré',
                        value: formatCurrency(averageBasket),
                        valueColor: AppColors.gold,
                      ),
                      KeyValueRow(
                        label: 'Total commandes estimé',
                        value: formatCurrency(totalOrdersValue),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingScreen(),
          error: (error, stackTrace) =>
              ErrorScreen(onRetry: () => ref.invalidate(familiesListProvider)),
        ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(kitsListProvider)),
      ),
    );
  }
}

class _KitBreakdownCard extends StatelessWidget {
  const _KitBreakdownCard({
    required this.kit,
    required this.count,
    required this.totalChildren,
    required this.color,
  });

  final Kit kit;
  final int count;
  final int totalChildren;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = totalChildren == 0 ? 0 : (count / totalChildren * 100);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(kit.fullLabel, style: AppTextStyles.bodySecondary),
              Text(
                '$count enfant(s) (${percent.round()}%)',
                style: AppTextStyles.bodyStrong.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppProgressBar(progress: percent / 100, color: color),
        ],
      ),
    );
  }
}
