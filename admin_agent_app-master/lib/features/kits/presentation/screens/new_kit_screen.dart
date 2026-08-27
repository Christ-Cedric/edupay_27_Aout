import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/domain/school_level.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_dropdown_field.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../supplies/domain/models/supply.dart';
import '../../../supplies/presentation/providers/supplies_providers.dart';
import '../../domain/models/kit.dart';
import '../providers/kits_providers.dart';
import '../widgets/kit_item_form.dart';

/// Création d'un nouveau kit (motif `ad_ki` du prototype, bouton
/// « + Ajouter un kit »). [initialLevel]/[initialSchoolLevel] pré-remplissent
/// les dropdowns quand on arrive depuis l'écran d'un variant déjà choisi
/// (`KitVariantDetailScreen`) — restent modifiables ensuite.
class NewKitScreen extends ConsumerStatefulWidget {
  const NewKitScreen({super.key, this.initialLevel, this.initialSchoolLevel});

  final KitLevel? initialLevel;
  final SchoolLevel? initialSchoolLevel;

  @override
  ConsumerState<NewKitScreen> createState() => _NewKitScreenState();
}

class _NewKitScreenState extends ConsumerState<NewKitScreen> {
  final List<KitItemFormEntry> _entries = [KitItemFormEntry()];
  late KitLevel _level;
  late SchoolLevel _schoolLevel;

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel ?? KitLevel.basic;
    _schoolLevel = widget.initialSchoolLevel ?? SchoolLevel.values.first;
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final items = _entries
        .map((e) => e.toKitItem())
        .whereType<KitItem>()
        .toList();

    if (items.isEmpty || items.length != _entries.length) {
      showAppToast(
        context,
        'Complétez tous les articles (catégorie, article, quantité, unité, prix)',
        type: AppToastType.error,
      );
      return;
    }

    await ref
        .read(kitCreateControllerProvider.notifier)
        .create(level: _level, schoolLevel: _schoolLevel, items: items);
    if (!mounted) return;

    if (ref.read(kitCreateControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Kit créé !');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(kitCreateControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Nouveau kit', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListView(
          children: [
            const Text('Créer un kit', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Définissez le niveau et les articles inclus — le prix se '
              'calcule automatiquement',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdownField<SchoolLevel>(
              label: 'Niveau scolaire',
              value: _schoolLevel,
              items: SchoolLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.label),
                    ),
                  )
                  .toList(),
              onChanged: submitting
                  ? null
                  : (level) => setState(() => _schoolLevel = level!),
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdownField<KitLevel>(
              label: 'Variant',
              value: _level,
              items: KitLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.label),
                    ),
                  )
                  .toList(),
              onChanged: submitting
                  ? null
                  : (level) => setState(() => _level = level!),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('ARTICLES INCLUS', style: AppTextStyles.fieldLabel),
            const SizedBox(height: AppSpacing.xs),
            Consumer(
              builder: (context, ref, _) {
                final supplies = ref
                    .watch(suppliesListProvider)
                    .maybeWhen(data: (v) => v, orElse: () => const <Supply>[]);
                return KitItemEditorList(
                  entries: _entries,
                  enabled: !submitting,
                  supplies: supplies,
                  onAddEntry: (entry) => setState(() => _entries.add(entry)),
                  onRemove: (i) =>
                      setState(() => _entries.removeAt(i).dispose()),
                  onChanged: () => setState(() {}),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Créer le kit',
              loading: submitting,
              onPressed: submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
