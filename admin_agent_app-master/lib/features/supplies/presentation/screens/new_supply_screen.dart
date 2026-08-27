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
import '../providers/supplies_providers.dart';

/// Création d'une nouvelle fourniture (catalogue réutilisable, indépendant
/// des kits — on y pioche pour composer un kit, cf. `KitItemEditorList`).
class NewSupplyScreen extends ConsumerStatefulWidget {
  const NewSupplyScreen({super.key});

  @override
  ConsumerState<NewSupplyScreen> createState() => _NewSupplyScreenState();
}

class _NewSupplyScreenState extends ConsumerState<NewSupplyScreen> {
  final _categoryController = TextEditingController();
  final _labelController = TextEditingController();
  final _unitController = TextEditingController(text: 'unité');
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    _labelController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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

    await ref
        .read(supplyCreateControllerProvider.notifier)
        .create(category: category, label: label, unit: unit, unitPrice: price);
    if (!mounted) return;

    if (ref.read(supplyCreateControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Fourniture créée');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(supplyCreateControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Nouvelle fourniture', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListView(
          children: [
            const Text('Ajouter une fourniture', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Disponible ensuite dans la liste au moment de composer un kit.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Catégorie',
              controller: _categoryController,
              hintText: 'Cahiers & Écriture',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Article',
              controller: _labelController,
              hintText: 'Cahier 192 pages',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Unité',
              controller: _unitController,
              hintText: 'unité, boîte, lot...',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Prix unitaire (FCFA)',
              controller: _priceController,
              keyboardType: TextInputType.number,
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Créer la fourniture',
              loading: submitting,
              onPressed: submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
