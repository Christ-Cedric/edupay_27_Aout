import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/family.dart';
import '../../domain/models/savings_plan.dart';
import '../providers/families_providers.dart';

/// Enregistrement d'un encaissement cash pour une famille (dossier famille
/// → « Enregistrer un encaissement »).
class RecordContributionScreen extends ConsumerWidget {
  const RecordContributionScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyDetailProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Enregistrer un encaissement',
        onBack: () => context.pop(),
      ),
      body: familyAsync.when(
        data: (family) =>
            _RecordContributionForm(familyId: familyId, family: family),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(familyDetailProvider(familyId)),
        ),
      ),
    );
  }
}

class _RecordContributionForm extends ConsumerStatefulWidget {
  const _RecordContributionForm({required this.familyId, required this.family});

  final String familyId;
  final Family family;

  @override
  ConsumerState<_RecordContributionForm> createState() =>
      _RecordContributionFormState();
}

class _RecordContributionFormState
    extends ConsumerState<_RecordContributionForm> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-rempli avec la cotisation périodique du plan choisi par la
    // famille — l'admin encaisse presque toujours ce montant-là ; il reste
    // libre de le corriger pour un versement partiel ou différent. Plafonné
    // au reste à payer pour ne pas pré-remplir une valeur que la validation
    // (montant > reste) rejetterait aussitôt.
    final remaining = widget.family.targetAmount - widget.family.balance;
    if (remaining > 0) {
      final prefill = widget.family.plan.amount > remaining
          ? remaining.round()
          : widget.family.plan.amount;
      _amountController.text = '$prefill';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      showAppToast(context, 'Montant invalide', type: AppToastType.error);
      return;
    }

    await ref
        .read(recordContributionControllerProvider.notifier)
        .record(familyId: widget.familyId, amount: amount);
    if (!mounted) return;

    final state = ref.read(recordContributionControllerProvider);
    if (state.hasError) {
      showAppToast(context, '${state.error}', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Encaissement enregistré !');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting =
        ref.watch(recordContributionControllerProvider).isLoading;
    final remaining = widget.family.targetAmount - widget.family.balance;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ListView(
        children: [
          Text(widget.family.fullName, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                KeyValueRow(
                  label: 'Solde actuel',
                  value: formatCurrency(widget.family.balance),
                  valueColor: AppColors.gold,
                ),
                KeyValueRow(
                  label: 'Objectif',
                  value: formatCurrency(widget.family.targetAmount),
                ),
                KeyValueRow(
                  label: 'Reste à payer',
                  value: formatCurrency(remaining),
                  valueColor: AppColors.green,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Montant encaissé (FCFA)',
            controller: _amountController,
            keyboardType: TextInputType.number,
            enabled: !submitting && remaining > 0,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Enregistrer l\'encaissement',
            variant: AppButtonVariant.green,
            loading: submitting,
            onPressed: submitting || remaining <= 0 ? null : _submit,
          ),
          if (remaining <= 0) ...[
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Cette famille a déjà atteint son objectif d\'épargne.',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}
