import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_tag.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../providers/refunds_providers.dart';

/// Remboursements (motif `ad_re` du prototype).
class RefundsScreen extends ConsumerWidget {
  const RefundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRefundsProvider);
    final monthSummaryAsync = ref.watch(refundMonthSummaryProvider);
    final validating = ref.watch(refundValidationControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Remboursements', onBack: () => context.pop()),
      body: pendingAsync.when(
        data: (refunds) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'EN ATTENTE (${refunds.length})',
              style: AppTextStyles.sectionLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (refunds.isEmpty)
              const EmptyState(
                icon: Icons.check_circle_outline,
                title: 'Aucune demande en attente',
                subtitle: 'Les nouvelles demandes apparaîtront ici',
              )
            else
              for (final refund in refunds)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => context.push(
                            '${RoutePaths.adminFinances}/refunds/${refund.id}',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  refund.familyName,
                                  style: AppTextStyles.bodyStrong,
                                ),
                              ),
                              const AppTag(
                                label: 'En attente',
                                variant: AppTagVariant.gold,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${refund.reference} - ${formatCurrency(refund.amount)} - ${refund.reason}',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Approuver',
                                variant: AppButtonVariant.green,
                                loading: validating,
                                onPressed: validating
                                    ? null
                                    : () async {
                                        await ref
                                            .read(
                                              refundValidationControllerProvider
                                                  .notifier,
                                            )
                                            .approve(refund.id);
                                        if (context.mounted) {
                                          showAppToast(
                                            context,
                                            'Remboursement approuvé !',
                                          );
                                          context.go(RoutePaths.adminDashboard);
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: 'Refuser',
                                variant: AppButtonVariant.danger,
                                onPressed: validating
                                    ? null
                                    : () async {
                                        await ref
                                            .read(
                                              refundValidationControllerProvider
                                                  .notifier,
                                            )
                                            .reject(refund.id);
                                        if (context.mounted) {
                                          showAppToast(
                                            context,
                                            'Remboursement refusé',
                                            type: AppToastType.error,
                                          );
                                          context.go(RoutePaths.adminDashboard);
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: AppSpacing.md),
            const Text('TRAITÉS CE MOIS', style: AppTextStyles.sectionLabel),
            const SizedBox(height: AppSpacing.sm),
            monthSummaryAsync.when(
              data: (summary) => AppCard(
                child: Column(
                  children: [
                    KeyValueRow(
                      label: 'Approuvés',
                      value: '${summary.approvedCount}',
                      valueColor: AppColors.green,
                    ),
                    KeyValueRow(
                      label: 'Montant remboursé',
                      value: formatCurrency(summary.approvedAmount),
                    ),
                    KeyValueRow(
                      label: 'Frais retenus',
                      value: formatCurrency(summary.feesRetained),
                      valueColor: AppColors.gold,
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => const Text(
                'Impossible de charger le bilan.',
                style: AppTextStyles.errorText,
              ),
            ),
          ],
        ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(pendingRefundsProvider)),
      ),
    );
  }
}
