import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/school_level.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_dropdown_field.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../providers/families_providers.dart';

/// Ajout d'un enfant à une famille existante — jamais de kit ici (choix
/// séparé, par saison, depuis le dossier « Enfants »). Un enfant sans kit
/// pour la saison en cours est un état normal, pas une erreur.
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  SchoolLevel? _level;

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      showAppToast(context, 'Renseignez le prénom', type: AppToastType.error);
      return;
    }

    await ref
        .read(childControllerProvider.notifier)
        .add(
          familyId: widget.familyId,
          firstName: _nameController.text.trim(),
          level: _level?.label,
          school: _schoolController.text.trim().isEmpty
              ? null
              : _schoolController.text.trim(),
        );
    if (!mounted) return;

    if (ref.read(childControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Enfant ajouté !');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(childControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Ajouter un enfant', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListView(
          children: [
            const Text('Nouvel enfant', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Le kit se choisit séparément, une fois l\'enfant ajouté.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Prénom',
              controller: _nameController,
              hintText: 'Fatoumata',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdownField<SchoolLevel?>(
              label: 'Niveau scolaire',
              value: _level,
              items: [
                const DropdownMenuItem(child: Text('Choisissez le niveau')),
                ...SchoolLevel.values.map(
                  (level) =>
                      DropdownMenuItem(value: level, child: Text(level.label)),
                ),
              ],
              onChanged: submitting
                  ? null
                  : (value) => setState(() => _level = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'École (optionnel)',
              controller: _schoolController,
              hintText: 'École Centre - Koudougou',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Ajouter cet enfant',
              loading: submitting,
              onPressed: submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
