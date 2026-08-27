import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_tag.dart';
import '../../../../core/theme/widgets/kpi_tile.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../families/domain/models/delivery_status.dart';
import '../../../families/domain/models/family_filter.dart';
import '../../../families/presentation/providers/families_providers.dart';

/// Suivi des livraisons (motif `ad_li` du prototype) — vue Admin sur toutes
/// les agences, à partir du vrai `Family.deliveryStatus`.
class DeliveriesScreen extends ConsumerWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familiesAsync = ref.watch(familiesListProvider(const FamilyFilter()));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Suivi livraisons', onBack: () => context.pop()),
      body: familiesAsync.when(
        data: (families) {
          final pending = families
              .where((f) => f.deliveryStatus == DeliveryStatus.pending)
              .length;
          final inProgress = families
              .where((f) => f.deliveryStatus == DeliveryStatus.inProgress)
              .length;
          final delivered = families
              .where((f) => f.deliveryStatus == DeliveryStatus.delivered)
              .length;
          final planning = families
              .where((f) => f.deliveryStatus != DeliveryStatus.delivered)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              KpiGrid(
                tiles: [
                  KpiTile(
                    value: '$pending',
                    label: 'À livrer',
                    valueColor: AppColors.danger,
                  ),
                  KpiTile(value: '$inProgress', label: 'En cours'),
                  KpiTile(
                    value: '$delivered',
                    label: 'Livrées',
                    valueColor: AppColors.green,
                  ),
                  KpiTile(value: '${families.length}', label: 'Total'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('PLANNING', style: AppTextStyles.sectionLabel),
              const SizedBox(height: AppSpacing.sm),
              if (planning.isEmpty)
                const EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'Aucune livraison en attente',
                  subtitle: 'Tous les kits ont été livrés',
                )
              else
                for (final family in planning)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.surfaceBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                family.fullName,
                                style: AppTextStyles.bodyStrong,
                              ),
                              Text(
                                'Agent : ${family.assignedAgentName ?? '-'}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        AppTag(
                          label: family.deliveryStatus.label,
                          variant:
                              family.deliveryStatus == DeliveryStatus.inProgress
                              ? AppTagVariant.gold
                              : AppTagVariant.neutral,
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
    );
  }
}
