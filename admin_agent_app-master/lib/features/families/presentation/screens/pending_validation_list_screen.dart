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
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/family.dart';
import '../../domain/models/savings_plan.dart';
import '../providers/families_providers.dart';

/// File d'attente des comptes auto-inscrits par les clients, en attente
/// d'approbation admin — règle métier confirmée par le client, absente du
/// prototype (voir mémo de validation du plan). Reprend le motif
/// liste + actions en ligne de l'écran `ad_re` (remboursements).
class PendingValidationListScreen extends ConsumerWidget {
  const PendingValidationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingValidationListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Comptes en attente',
        onBack: () => context.pop(),
      ),
      body: pendingAsync.when(
        data: (families) => families.isEmpty
            ? const EmptyState(
                icon: Icons.verified_user_outlined,
                title: 'Aucun compte en attente',
                subtitle: 'Les nouvelles inscriptions apparaîtront ici',
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Tout confirmer (${families.length})',
                        variant: AppButtonVariant.green,
                        loading: ref
                            .watch(validationControllerProvider)
                            .isLoading,
                        onPressed:
                            ref.watch(validationControllerProvider).isLoading
                            ? null
                            : () => _confirmAll(context, ref, families),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: families.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _PendingFamilyCard(family: families[index]),
                      ),
                    ),
                  ),
                ],
              ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(pendingValidationListProvider),
        ),
      ),
    );
  }

  Future<void> _confirmAll(
    BuildContext context,
    WidgetRef ref,
    List<Family> families,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Confirmer tous les comptes',
          style: AppTextStyles.bodyStrong,
        ),
        content: Text(
          'Confirmer les ${families.length} compte(s) en attente ? Cette action les active tous.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(validationControllerProvider.notifier)
        .approveAll(families.map((family) => family.id));
    if (context.mounted && !ref.read(validationControllerProvider).hasError) {
      showAppToast(context, '${families.length} compte(s) confirmé(s)');
    }
  }
}

class _PendingFamilyCard extends ConsumerWidget {
  const _PendingFamilyCard({required this.family});

  final Family family;

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validating = ref.watch(validationControllerProvider).isLoading;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(family.fullName, style: AppTextStyles.bodyStrong),
          const SizedBox(height: 2),
          Text(
            '${family.phone} - ${family.plan.labelWithAmount}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 2),
          Text(
            'Inscrit le ${_formatDate(family.registeredAt)}',
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
                  onPressed: validating ? null : () => _approve(context, ref),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Rejeter',
                  variant: AppButtonVariant.danger,
                  onPressed: validating ? null : () => _reject(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    await ref.read(validationControllerProvider.notifier).approve(family.id);
    if (context.mounted) {
      showAppToast(context, '${family.fullName} approuvé(e)');
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reason = await _askReason(context);
    if (reason == null || reason.trim().isEmpty) return;
    await ref
        .read(validationControllerProvider.notifier)
        .reject(family.id, reason.trim());
    if (context.mounted) {
      showAppToast(
        context,
        '${family.fullName} rejeté(e)',
        type: AppToastType.error,
      );
    }
  }

  Future<String?> _askReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Motif du rejet', style: AppTextStyles.bodyStrong),
        content: TextField(
          controller: controller,
          style: AppTextStyles.body,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Expliquez pourquoi...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
