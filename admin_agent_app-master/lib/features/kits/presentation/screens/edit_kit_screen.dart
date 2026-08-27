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
import '../../../../core/theme/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../supplies/domain/models/supply.dart';
import '../../../supplies/presentation/providers/supplies_providers.dart';
import '../../domain/models/kit.dart';
import '../providers/kits_providers.dart';
import '../widgets/kit_item_form.dart';

/// Édition d'un kit (motif `ad_ek` du prototype) — prix + liste d'articles
/// éditable dynamiquement.
class EditKitScreen extends ConsumerWidget {
  const EditKitScreen({super.key, required this.kitId});

  final String kitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitAsync = ref.watch(kitDetailProvider(kitId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Modifier le kit', onBack: () => context.pop()),
      body: kitAsync.when(
        data: (kit) => _EditKitBody(kit: kit),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(kitDetailProvider(kitId)),
        ),
      ),
    );
  }
}

class _EditKitBody extends ConsumerStatefulWidget {
  const _EditKitBody({required this.kit});

  final Kit kit;

  @override
  ConsumerState<_EditKitBody> createState() => _EditKitBodyState();
}

class _EditKitBodyState extends ConsumerState<_EditKitBody> {
  late List<KitItemFormEntry> _entries;
  late SchoolLevel _schoolLevel;

  @override
  void initState() {
    super.initState();
    _entries = widget.kit.items
        .map((item) => KitItemFormEntry(item: item))
        .toList();
    if (_entries.isEmpty) _entries.add(KitItemFormEntry());
    _schoolLevel = widget.kit.schoolLevel;
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
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
    final updated = widget.kit.copyWith(
      schoolLevel: _schoolLevel,
      items: items,
    );
    await ref.read(kitEditControllerProvider.notifier).save(updated);
    if (!mounted) return;

    if (ref.read(kitEditControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Kit enregistré avec succès !');
    context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer ce kit ?',
      message:
          'Cette action est irréversible. Le kit "${widget.kit.fullLabel}" '
          'sera définitivement supprimé du catalogue.',
      confirmLabel: 'Supprimer',
      danger: true,
    );
    if (!confirmed) return;
    if (!mounted) return;

    await ref.read(kitDeleteControllerProvider.notifier).delete(widget.kit.id);
    if (!mounted) return;

    final state = ref.read(kitDeleteControllerProvider);
    if (state.hasError) {
      showAppToast(context, '${state.error}', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Kit supprimé');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final saving =
        ref.watch(kitEditControllerProvider).isLoading ||
        ref.watch(kitDeleteControllerProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ListView(
        children: [
          Text(widget.kit.fullLabel, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.lg),
          AppDropdownField<SchoolLevel>(
            label: 'Niveau scolaire',
            value: _schoolLevel,
            items: SchoolLevel.values
                .map(
                  (level) =>
                      DropdownMenuItem(value: level, child: Text(level.label)),
                )
                .toList(),
            onChanged: saving
                ? null
                : (level) => setState(() => _schoolLevel = level!),
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
                enabled: !saving,
                supplies: supplies,
                onAddEntry: (entry) => setState(() => _entries.add(entry)),
                onRemove: (i) => setState(() => _entries.removeAt(i).dispose()),
                onChanged: () => setState(() {}),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Enregistrer les modifications',
            variant: AppButtonVariant.green,
            loading: saving,
            onPressed: saving ? null : _save,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Supprimer ce kit',
            variant: AppButtonVariant.danger,
            loading: ref.watch(kitDeleteControllerProvider).isLoading,
            onPressed: saving ? null : _delete,
          ),
        ],
      ),
    );
  }
}
