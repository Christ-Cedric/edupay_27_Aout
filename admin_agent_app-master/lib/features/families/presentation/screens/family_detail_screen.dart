import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/alert_notice.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/initials_avatar.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../agent_terrain/presentation/widgets/collection_history_sheet.dart';
import '../../domain/models/delivery_status.dart';
import '../../domain/models/family.dart';
import '../../domain/models/family_status.dart';
import '../../domain/models/savings_plan.dart';
import '../providers/families_providers.dart';
import '../widgets/family_status_tag.dart';

/// Dossier détaillé d'une famille (motif `ad_do` du prototype).
class FamilyDetailScreen extends ConsumerWidget {
  const FamilyDetailScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyDetailProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Dossier famille', onBack: () => context.pop()),
      body: familyAsync.when(
        data: (family) => _FamilyDetailBody(family: family),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(familyDetailProvider(familyId)),
        ),
      ),
    );
  }
}

class _FamilyDetailBody extends ConsumerWidget {
  const _FamilyDetailBody({required this.family});

  final Family family;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            InitialsAvatar(name: family.fullName, size: 40),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(family.fullName, style: AppTextStyles.h2),
                  Text(
                    [
                      family.phone,
                      if (family.assignedAgentName != null)
                        'Agent : ${family.assignedAgentName}',
                    ].join(' - '),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FamilyStatusTag(status: family.status),
          ],
        ),
        if (family.status == FamilyStatus.rejected &&
            (family.rejectionReason?.isNotEmpty ?? false)) ...[
          const SizedBox(height: AppSpacing.sm),
          AlertNotice(
            title: 'Compte rejeté',
            subtitle: family.rejectionReason!,
            variant: AlertNoticeVariant.danger,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              KeyValueRow(
                label: 'Ville',
                value: family.city.isEmpty ? 'Non renseignée' : family.city,
              ),
              if (family.district != null && family.district!.isNotEmpty)
                KeyValueRow(label: 'Quartier', value: family.district!),
              KeyValueRow(label: 'Plan', value: family.plan.labelWithAmount),
              KeyValueRow(
                label: 'Solde',
                value: formatCurrency(family.balance),
                valueColor: AppColors.gold,
              ),
              KeyValueRow(
                label: 'Objectif',
                value: formatCurrency(family.targetAmount),
              ),
              KeyValueRow(
                label: 'Enfants',
                value: '${family.childrenCount}',
                onTap: () => context.push(
                  '${RoutePaths.adminFamilies}/${family.id}/children',
                ),
              ),
              KeyValueRow(
                label: 'Livraison',
                value: family.deliveryStatus.label,
                valueColor: family.deliveryStatus == DeliveryStatus.delivered
                    ? AppColors.green
                    : null,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ActionRow(
          label: 'Voir le contrat',
          onTap: () =>
              context.push('${RoutePaths.adminFamilies}/${family.id}/contract'),
        ),
        _ActionRow(
          label: 'Historique cotisations',
          onTap: () => showCollectionHistorySheet(context, family.id),
        ),
        _ActionRow(
          label: 'Enregistrer un encaissement',
          enabled: family.status == FamilyStatus.active,
          disabledMessage: family.status == FamilyStatus.pendingValidation
              ? 'Ce compte est en attente de validation — approuvez-le avant d\'encaisser.'
              : 'Ce compte n\'est pas actif — impossible d\'encaisser.',
          onTap: () => context.push(
            '${RoutePaths.adminFamilies}/${family.id}/record-contribution',
          ),
        ),
        _ActionRow(
          label: 'Signaler un incident',
          color: AppColors.danger,
          onTap: () => _reportIncident(context, ref),
        ),
      ],
    );
  }

  Future<void> _reportIncident(BuildContext context, WidgetRef ref) async {
    final note = await _askIncidentNote(context);
    if (note == null || note.trim().isEmpty) return;

    await ref.read(familyRepositoryProvider).reportIncident(family.id, note.trim());
    if (context.mounted) {
      showAppToast(context, 'Incident signalé', type: AppToastType.error);
    }
  }

  Future<String?> _askIncidentNote(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Signaler un incident',
          style: AppTextStyles.bodyStrong,
        ),
        content: TextField(
          controller: controller,
          style: AppTextStyles.body,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Décrivez ce qui se passe...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.onTap,
    this.color,
    this.enabled = true,
    this.disabledMessage,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  /// Quand `false`, la ligne reste visible et tappable (jamais masquée
  /// silencieusement) mais affiche [disabledMessage] au lieu de naviguer —
  /// plus clair pour l'admin qu'un contrôle simplement grisé sans explication.
  final bool enabled;
  final String? disabledMessage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? onTap
          : () {
              if (disabledMessage != null) {
                showAppToast(context, disabledMessage!, type: AppToastType.error);
              }
            },
      child: Opacity(
        opacity: enabled ? 1 : .4,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodySecondary),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: color ?? AppColors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
