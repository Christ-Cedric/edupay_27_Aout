import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/school_level.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_dropdown_field.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_progress_bar.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/initials_avatar.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../kits/domain/models/kit.dart';
import '../../../kits/presentation/providers/kits_providers.dart';
import '../../domain/models/family.dart';
import '../providers/families_providers.dart';

/// Liste des enfants d'une famille, chacun avec son propre kit choisi pour
/// la saison en cours (§7 #2 du contrat : kit par enfant, pas par famille)
/// — accessible depuis la ligne "Enfants" du dossier famille. Un enfant
/// persiste indépendamment des saisons ; il peut donc exister sans kit tant
/// que personne ne lui en a choisi un pour la saison en cours (état normal
/// en début de saison), et son kit doit être choisi/changé chaque saison.
class FamilyChildrenScreen extends ConsumerWidget {
  const FamilyChildrenScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyDetailProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Enfants',
        onBack: () => context.pop(),
        trailing: IconButton(
          icon: const Icon(
            Icons.person_add_alt,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () =>
              context.push('${RoutePaths.adminFamilies}/$familyId/children/new'),
        ),
      ),
      body: familyAsync.when(
        data: (family) => family.children.isEmpty
            ? const EmptyState(
                icon: Icons.child_care_outlined,
                title: 'Aucun enfant enregistré',
                subtitle:
                    'Cette famille n\'a pas encore d\'enfant renseigné — '
                    'l\'objectif reste à 0 tant qu\'aucun n\'est ajouté.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: family.children.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ChildCard(familyId: familyId, familyChild: family.children[index]),
                ),
              ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(familyDetailProvider(familyId)),
        ),
      ),
    );
  }
}

class _ChildCard extends ConsumerWidget {
  const _ChildCard({required this.familyId, required this.familyChild});

  final String familyId;
  final FamilyChild familyChild;

  Future<void> _editChild(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({SchoolLevel? level, String school})>(
      context: context,
      builder: (dialogContext) =>
          _EditChildDialog(familyChild: familyChild),
    );
    if (result == null || !context.mounted) return;

    await ref
        .read(childControllerProvider.notifier)
        .updateChild(
          familyId: familyId,
          childId: familyChild.id,
          level: result.level?.label,
          school: result.school.isEmpty ? null : result.school,
        );
    if (!context.mounted) return;
    if (ref.read(childControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
    }
  }

  Future<void> _chooseKit(BuildContext context, WidgetRef ref) async {
    final kits = await ref.read(kitsListProvider.future);
    if (!context.mounted) return;
    final level = schoolLevelFromLabel(familyChild.level);
    final candidates = kitsForSchoolLevel(kits, level);
    if (candidates.isEmpty) {
      showAppToast(
        context,
        'Aucun kit pour ce niveau — créez-en un dans le catalogue.',
        type: AppToastType.error,
      );
      return;
    }

    final chosen = await showDialog<Kit>(
      context: context,
      builder: (dialogContext) => _ChooseKitDialog(kits: candidates),
    );
    if (chosen == null || !context.mounted) return;

    await ref
        .read(childControllerProvider.notifier)
        .assignKit(familyId: familyId, childId: familyChild.id, kitId: chosen.id);
    if (!context.mounted) return;
    if (ref.read(childControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
    } else {
      showAppToast(context, 'Kit mis à jour !');
    }
  }

  Future<void> _removeChild(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Retirer cet enfant', style: AppTextStyles.bodyStrong),
        content: Text(
          'Retirer ${familyChild.firstName} de cette famille ?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref
        .read(childControllerProvider.notifier)
        .remove(familyId: familyId, childId: familyChild.id);
    if (!context.mounted) return;
    final state = ref.read(childControllerProvider);
    if (state.hasError) {
      final error = state.error;
      showAppToast(
        context,
        error is Exception ? error.toString().replaceFirst('Exception: ', '') : 'Une erreur est survenue',
        type: AppToastType.error,
      );
    } else {
      showAppToast(context, 'Enfant retiré');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = [
      if (familyChild.level.isNotEmpty) familyChild.level,
      if (familyChild.school.isNotEmpty) familyChild.school,
    ].join(' - ');
    final submitting = ref.watch(childControllerProvider).isLoading;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: familyChild.firstName, size: 32),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(familyChild.firstName, style: AppTextStyles.bodyStrong),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                enabled: !submitting,
                onSelected: (value) {
                  if (value == 'edit') _editChild(context, ref);
                  if (value == 'remove') _removeChild(context, ref);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  PopupMenuItem(value: 'remove', child: Text('Retirer')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (familyChild.hasKitThisSeason) ...[
            KeyValueRow(
              label: 'Kit',
              value: ref
                  .watch(kitDetailProvider(familyChild.kitId!))
                  .when(
                    data: (kit) => kit.fullLabel,
                    loading: () => '...',
                    error: (error, stackTrace) => 'Indisponible',
                  ),
            ),
            KeyValueRow(
              label: 'Objectif',
              value: formatCurrency(familyChild.targetAmount ?? 0),
            ),
            KeyValueRow(
              label: 'Solde',
              value: formatCurrency(familyChild.savedAmount ?? 0),
              valueColor: AppColors.gold,
              showDivider: false,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppProgressBar(progress: familyChild.progress),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: submitting ? null : () => _chooseKit(context, ref),
              child: const Text('Changer de kit'),
            ),
          ] else ...[
            const Text(
              'Aucun kit choisi pour cette saison.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Choisir un kit',
              expanded: false,
              onPressed: submitting ? null : () => _chooseKit(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditChildDialog extends StatefulWidget {
  const _EditChildDialog({required this.familyChild});

  final FamilyChild familyChild;

  @override
  State<_EditChildDialog> createState() => _EditChildDialogState();
}

class _EditChildDialogState extends State<_EditChildDialog> {
  late SchoolLevel? _level = schoolLevelFromLabel(widget.familyChild.level);
  late final _schoolController = TextEditingController(text: widget.familyChild.school);

  @override
  void dispose() {
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Modifier l\'enfant', style: AppTextStyles.bodyStrong),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDropdownField<SchoolLevel?>(
            label: 'Niveau scolaire',
            value: _level,
            items: [
              const DropdownMenuItem(child: Text('Choisissez le niveau')),
              ...SchoolLevel.values.map(
                (level) => DropdownMenuItem(value: level, child: Text(level.label)),
              ),
            ],
            onChanged: (value) => setState(() => _level = value),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(label: 'École', controller: _schoolController),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop((
            level: _level,
            school: _schoolController.text.trim(),
          )),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _ChooseKitDialog extends StatelessWidget {
  const _ChooseKitDialog({required this.kits});

  final List<Kit> kits;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Choisir un kit', style: AppTextStyles.bodyStrong),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final kit in kits)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(kit.fullLabel, style: AppTextStyles.body),
              trailing: Text(
                formatCurrency(kit.price),
                style: AppTextStyles.bodyStrong.copyWith(color: AppColors.gold),
              ),
              onTap: () => Navigator.of(context).pop(kit),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
