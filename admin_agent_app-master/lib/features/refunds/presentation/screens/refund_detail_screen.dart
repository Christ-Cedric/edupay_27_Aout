import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/refund_detail.dart';
import '../providers/refunds_providers.dart';

final _dateFormat = DateFormat('d MMMM yyyy', 'fr_FR');

/// Dossier détaillé d'une demande de remboursement (motif `ad_re` du
/// prototype) — fonctionne aussi pour une demande déjà traitée.
class RefundDetailScreen extends ConsumerWidget {
  const RefundDetailScreen({super.key, required this.refundId});

  final String refundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refundAsync = ref.watch(refundDetailProvider(refundId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Remboursement', onBack: () => context.pop()),
      body: refundAsync.when(
        data: (refund) => _RefundDetailBody(refund: refund),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(refundDetailProvider(refundId)),
        ),
      ),
    );
  }
}

AppTagVariant _variantFor(RefundStatus status) => switch (status) {
  RefundStatus.approved || RefundStatus.refunded => AppTagVariant.green,
  RefundStatus.rejected => AppTagVariant.danger,
  RefundStatus.requested || RefundStatus.processing => AppTagVariant.gold,
};

class _RefundDetailBody extends ConsumerWidget {
  const _RefundDetailBody({required this.refund});

  final RefundDetail refund;

  bool get _isPending =>
      refund.status == RefundStatus.requested ||
      refund.status == RefundStatus.processing;

  Future<void> _decide(BuildContext context, WidgetRef ref, bool approve) async {
    final controller = ref.read(refundValidationControllerProvider.notifier);
    if (approve) {
      await controller.approve(refund.id);
    } else {
      await controller.reject(refund.id);
    }
    if (!context.mounted) return;

    if (ref.read(refundValidationControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(
      context,
      approve ? 'Remboursement approuvé !' : 'Remboursement refusé',
      type: approve ? AppToastType.success : AppToastType.error,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = ref.watch(refundValidationControllerProvider).isLoading;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(refund.familyName, style: AppTextStyles.h2),
            AppTag(label: refund.status.label, variant: _variantFor(refund.status)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              KeyValueRow(label: 'Référence', value: refund.reference),
              KeyValueRow(
                label: 'Montant',
                value: formatCurrency(refund.amount),
                valueColor: AppColors.gold,
              ),
              KeyValueRow(label: 'Motif', value: refund.reason),
              KeyValueRow(
                label: 'Demandé le',
                value: _dateFormat.format(refund.createdAt),
                showDivider: refund.processedByAdminName != null,
              ),
              if (refund.processedByAdminName != null)
                KeyValueRow(
                  label: 'Traité par',
                  value: refund.processedByAdminName!,
                  showDivider: false,
                ),
            ],
          ),
        ),
        if (_isPending) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Approuver',
                  variant: AppButtonVariant.green,
                  loading: submitting,
                  onPressed:
                      submitting ? null : () => _decide(context, ref, true),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Refuser',
                  variant: AppButtonVariant.danger,
                  onPressed:
                      submitting ? null : () => _decide(context, ref, false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
