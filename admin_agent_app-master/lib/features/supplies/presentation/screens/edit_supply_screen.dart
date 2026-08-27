import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/supply.dart';
import '../providers/supplies_providers.dart';

/// Édition d'une fourniture du catalogue réutilisable.
class EditSupplyScreen extends ConsumerWidget {
  const EditSupplyScreen({super.key, required this.supplyId});

  final String supplyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplyAsync = ref.watch(supplyDetailProvider(supplyId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Modifier la fourniture', onBack: () => context.pop()),
      body: supplyAsync.when(
        data: (supply) => _EditSupplyBody(supply: supply),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(supplyDetailProvider(supplyId)),
        ),
      ),
    );
  }
}

class _EditSupplyBody extends ConsumerStatefulWidget {
  const _EditSupplyBody({required this.supply});

  final Supply supply;

  @override
  ConsumerState<_EditSupplyBody> createState() => _EditSupplyBodyState();
}

class _EditSupplyBodyState extends ConsumerState<_EditSupplyBody> {
  late final TextEditingController _categoryController;
  late final TextEditingController _labelController;
  late final TextEditingController _unitController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.supply.category);
    _labelController = TextEditingController(text: widget.supply.label);
    _unitController = TextEditingController(text: widget.supply.unit);
    _priceController = TextEditingController(
      text: widget.supply.unitPrice.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _labelController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final category = _categoryController.text.trim();
    final label = _labelController.text.trim();
    final unit = _unitController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (category.isEmpty || label.isEmpty || unit.isEmpty || price == null || price < 0) {
      showAppToast(
        context,
        'Renseignez tous les champs requis',
        type: AppToastType.error,
      );
      return;
    }

    final updated = widget.supply.copyWith(
      category: category,
      label: label,
      unit: unit,
      unitPrice: price,
    );
    await ref.read(supplyEditControllerProvider.notifier).save(updated);
    if (!mounted) return;
    showAppToast(context, 'Fourniture enregistrée');
    context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer cette fourniture ?',
      message:
          '"${widget.supply.label}" sera retirée du catalogue. Les kits qui '
          'l\'utilisent déjà ne sont pas affectés (leurs articles sont '
          'indépendants).',
      confirmLabel: 'Supprimer',
      danger: true,
    );
    if (!confirmed) return;
    if (!mounted) return;

    await ref.read(supplyDeleteControllerProvider.notifier).delete(widget.supply.id);
    if (!mounted) return;

    final state = ref.read(supplyDeleteControllerProvider);
    if (state.hasError) {
      showAppToast(context, '${state.error}', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Fourniture supprimée');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final saving =
        ref.watch(supplyEditControllerProvider).isLoading ||
        ref.watch(supplyDeleteControllerProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ListView(
        children: [
          Text(widget.supply.label, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Catégorie',
            controller: _categoryController,
            enabled: !saving,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Article',
            controller: _labelController,
            enabled: !saving,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Unité',
            controller: _unitController,
            enabled: !saving,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Prix unitaire (FCFA)',
            controller: _priceController,
            keyboardType: TextInputType.number,
            enabled: !saving,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Enregistrer les modifications',
            variant: AppButtonVariant.green,
            loading: ref.watch(supplyEditControllerProvider).isLoading,
            onPressed: saving ? null : _save,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Supprimer cette fourniture',
            variant: AppButtonVariant.danger,
            loading: ref.watch(supplyDeleteControllerProvider).isLoading,
            onPressed: saving ? null : _delete,
          ),
        ],
      ),
    );
  }
}
