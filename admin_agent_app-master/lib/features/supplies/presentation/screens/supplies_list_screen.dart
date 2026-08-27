import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/tap_target.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/supply.dart';
import '../providers/supplies_providers.dart';

/// Catalogue de fournitures réutilisable — l'admin le gère une fois, puis
/// pioche dedans pour composer un kit (bouton "+ Ajouter un article" dans
/// l'éditeur de kit).
class SuppliesListScreen extends ConsumerWidget {
  const SuppliesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliesAsync = ref.watch(suppliesListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Fournitures', onBack: () => context.pop()),
      body: suppliesAsync.when(
        data: (supplies) {
          final byCategory = <String, List<Supply>>{};
          for (final supply in supplies) {
            (byCategory[supply.category] ??= []).add(supply);
          }
          final sortedCategories = byCategory.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (supplies.isEmpty)
                const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Aucune fourniture',
                  subtitle: 'Ajoutez-en une pour commencer',
                ),
              for (final category in sortedCategories) ...[
                Text(category, style: AppTextStyles.sectionLabel),
                const SizedBox(height: AppSpacing.sm),
                for (final supply in byCategory[category]!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(supply.label, style: AppTextStyles.bodyStrong),
                                Text(
                                  '${formatCurrency(supply.unitPrice)} / ${supply.unit}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          TapTarget(
                            onTap: () => context.push(
                              '/admin/settings/kits/supplies/${supply.id}/edit',
                            ),
                            child: Text(
                              'Modifier ✎',
                              style: AppTextStyles.tag.copyWith(color: AppColors.gold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: '+ Ajouter une fourniture',
                variant: AppButtonVariant.green,
                onPressed: () => context.push('/admin/settings/kits/supplies/new'),
              ),
            ],
          );
        },
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(suppliesListProvider)),
      ),
    );
  }
}
