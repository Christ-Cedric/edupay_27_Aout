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
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/season.dart';
import '../providers/seasons_providers.dart';

final _dateFormat = DateFormat('d MMM yyyy', 'fr_FR');

/// Historique des saisons, création et changement de saison courante (motif
/// `AgentsListScreen`/`NewAgentScreen`, appliqué aux saisons — le backend
/// exposait déjà lister/créer/définir courante, seul l'écran manquait).
class SeasonsListScreen extends ConsumerWidget {
  const SeasonsListScreen({super.key});

  Future<void> _confirmSetCurrent(
    BuildContext context,
    WidgetRef ref,
    Season season,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Changer de saison', style: AppTextStyles.bodyStrong),
        content: Text(
          'Définir "${season.label}" comme saison courante ? '
          'La saison actuellement courante sera démarquée.',
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
    if (confirmed != true || !context.mounted) return;

    await ref.read(seasonSwitchControllerProvider.notifier).setCurrent(season.id);
    if (!context.mounted) return;
    if (ref.read(seasonSwitchControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(context, '"${season.label}" est désormais la saison courante');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsListProvider);
    final switching = ref.watch(seasonSwitchControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Gestion des saisons',
        onBack: () => context.pop(),
        trailing: IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.push('/admin/settings/seasons/new'),
        ),
      ),
      body: seasonsAsync.when(
        data: (seasons) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (seasons.isEmpty)
              const EmptyState(
                icon: Icons.calendar_month_outlined,
                title: 'Aucune saison',
                subtitle: 'Créez la première saison scolaire',
              ),
            for (final season in seasons)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: season.isCurrent || switching
                      ? null
                      : () => _confirmSetCurrent(context, ref, season),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(season.label, style: AppTextStyles.bodyStrong),
                          if (season.isCurrent)
                            const AppTag(
                              label: 'Courante',
                              variant: AppTagVariant.green,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_dateFormat.format(season.launchDate)} — '
                        '${_dateFormat.format(season.deliveryDeadline)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: '+ Créer une saison',
              onPressed: () => context.push('/admin/settings/seasons/new'),
            ),
          ],
        ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(seasonsListProvider)),
      ),
    );
  }
}
