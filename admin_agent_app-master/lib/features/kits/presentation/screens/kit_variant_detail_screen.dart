import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/school_level.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_dropdown_field.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/theme/widgets/tap_target.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/kit.dart';
import '../providers/kits_providers.dart';

/// Détail d'un variant de kit (Basique/Essentiel/Premium) — on choisit la
/// classe pour voir le kit correspondant, plutôt que de tout afficher à
/// plat (28 classes × 3 variants ne tient pas sur un seul écran lisible).
class KitVariantDetailScreen extends ConsumerStatefulWidget {
  const KitVariantDetailScreen({super.key, required this.level});

  final KitLevel level;

  @override
  ConsumerState<KitVariantDetailScreen> createState() => _KitVariantDetailScreenState();
}

class _KitVariantDetailScreenState extends ConsumerState<KitVariantDetailScreen> {
  SchoolLevel _selectedClass = SchoolLevel.values.first;

  @override
  Widget build(BuildContext context) {
    final kitsAsync = ref.watch(kitsListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: widget.level.label, onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDropdownField<SchoolLevel>(
              label: 'Classe',
              value: _selectedClass,
              items: SchoolLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.label),
                    ),
                  )
                  .toList(),
              onChanged: (level) => setState(() => _selectedClass = level!),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: kitsAsync.when(
                data: (kits) {
                  final kit = kits
                      .where(
                        (k) =>
                            k.level == widget.level && k.schoolLevel == _selectedClass,
                      )
                      .cast<Kit?>()
                      .firstWhere((_) => true, orElse: () => null);

                  if (kit == null) {
                    return Center(
                      child: EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Aucun kit pour cette classe',
                        subtitle: '${widget.level.label} - ${_selectedClass.label}',
                        actionLabel: '+ Créer ce kit',
                        onAction: () => context.push(
                          '/admin/settings/kits/new',
                          extra: (level: widget.level, schoolLevel: _selectedClass),
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      AppCard(
                        child: Column(
                          children: [
                            KeyValueRow(
                              label: 'Prix total',
                              value: formatCurrency(kit.price),
                              valueColor: AppColors.gold,
                            ),
                            KeyValueRow(
                              label: 'Articles',
                              value: '${kit.items.length} articles',
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text('ARTICLES INCLUS', style: AppTextStyles.sectionLabel),
                      const SizedBox(height: AppSpacing.sm),
                      for (final item in kit.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.label} (${item.category})',
                                    style: AppTextStyles.body,
                                  ),
                                ),
                                Text(
                                  '${item.quantity} ${item.unit} · ${formatCurrency(item.lineTotal)}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TapTarget(
                          onTap: () => context.push(
                            '/admin/settings/kits/${kit.id}/edit',
                          ),
                          child: Text(
                            'Modifier ✎',
                            style: AppTextStyles.tag.copyWith(color: AppColors.gold),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LoadingScreen(),
                error: (error, stackTrace) =>
                    ErrorScreen(onRetry: () => ref.invalidate(kitsListProvider)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
