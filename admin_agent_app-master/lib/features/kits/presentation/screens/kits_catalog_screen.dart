import 'dart:convert';

import 'package:file_picker/file_picker.dart';
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
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/confirm_dialog.dart';
import '../../../../core/theme/widgets/tap_target.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../seasons/presentation/providers/seasons_providers.dart';
import '../../domain/models/kit.dart';
import '../providers/kits_providers.dart';

/// Catalogue de kits (motif `ad_ki` du prototype).
class KitsCatalogScreen extends ConsumerWidget {
  const KitsCatalogScreen({super.key});

  Future<void> _importCatalog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Importer un catalogue Excel ?',
      message:
          'Les kits existants pour les mêmes classes et variants seront '
          'remplacés par le contenu du fichier. Cette action est '
          'irréversible.',
      confirmLabel: 'Importer',
      danger: true,
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();

    if (!context.mounted) return;
    await ref
        .read(kitImportControllerProvider.notifier)
        .import(base64Encode(bytes));
    if (!context.mounted) return;

    final state = ref.read(kitImportControllerProvider);
    if (state.hasError) {
      showAppToast(context, 'Import échoué : ${state.error}', type: AppToastType.error);
      return;
    }
    final result = state.value;
    if (result == null) return;

    if (result.warnings.isEmpty) {
      showAppToast(
        context,
        'Catalogue importé : ${result.created} créés, ${result.updated} mis à jour.',
      );
      return;
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Import terminé', style: AppTextStyles.bodyStrong),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.created} kits créés, ${result.updated} mis à jour.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('AVERTISSEMENTS', style: AppTextStyles.fieldLabel),
              const SizedBox(height: AppSpacing.xs),
              for (final warning in result.warnings)
                Text('• $warning', style: AppTextStyles.caption),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitsAsync = ref.watch(kitsListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Catalogue Kits',
        onBack: () => context.pop(),
        trailing: IconButton(
          icon: const Icon(
            Icons.bar_chart,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.push('/admin/settings/kits/stats'),
        ),
      ),
      body: kitsAsync.when(
        data: (kits) {
          // 3 variants (Basique/Essentiel/Premium) en haut — la classe se
          // choisit à l'intérieur de chacun (28 classes × 3 variants ne
          // tient pas sur un seul écran groupé par classe).
          final countByLevel = <KitLevel, int>{
            for (final level in KitLevel.values)
              level: kits.where((k) => k.level == level).length,
          };

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (kits.isEmpty)
                const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Aucun kit au catalogue',
                  subtitle: 'Importez un catalogue ou créez un kit pour commencer',
                ),
              for (final level in KitLevel.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: TapTarget(
                    onTap: () => context.push(
                      '/admin/settings/kits/variant/${level.name}',
                    ),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(level.label, style: AppTextStyles.bodyStrong),
                                Text(
                                  '${countByLevel[level]} classe(s) catalogée(s)',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'DATE LIMITE RENTRÉE',
                style: AppTextStyles.sectionLabel,
              ),
              const SizedBox(height: AppSpacing.sm),
              Consumer(
                builder: (context, ref, _) {
                  final seasonAsync = ref.watch(currentSeasonProvider);
                  return AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          seasonAsync.maybeWhen(
                            data: (season) => DateFormat(
                              'd MMMM yyyy',
                              'fr_FR',
                            ).format(season.deliveryDeadline),
                            orElse: () => '—',
                          ),
                          style: AppTextStyles.body,
                        ),
                        TapTarget(
                          // La saison est modifiable depuis Paramètres — pas de
                          // second formulaire dupliqué ici. `pop()` (pas
                          // `push()`) : Paramètres est déjà sous cet écran
                          // dans la pile, inutile d'en empiler une 2ᵉ instance.
                          onTap: () => context.pop(),
                          child: Text(
                            'Modifier ✎',
                            style: AppTextStyles.tag.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Gérer les fournitures',
                variant: AppButtonVariant.outline,
                onPressed: () => context.push('/admin/settings/kits/supplies'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Consumer(
                builder: (context, ref, _) {
                  final importing = ref.watch(
                    kitImportControllerProvider.select((s) => s.isLoading),
                  );
                  return AppButton(
                    label: 'Importer un catalogue Excel',
                    variant: AppButtonVariant.outline,
                    loading: importing,
                    onPressed: importing
                        ? null
                        : () => _importCatalog(context, ref),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(kitsListProvider)),
      ),
    );
  }
}
