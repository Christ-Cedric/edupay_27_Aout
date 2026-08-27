import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_tag.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/confirm_dialog.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/agent.dart';
import '../providers/agents_providers.dart';

/// Dossier détaillé d'un agent — suspendre/réactiver son compte.
class AgentDetailScreen extends ConsumerWidget {
  const AgentDetailScreen({super.key, required this.agentId});

  final String agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentDetailProvider(agentId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Dossier agent', onBack: () => context.pop()),
      body: agentAsync.when(
        data: (agent) => _AgentDetailBody(agent: agent),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(agentDetailProvider(agentId)),
        ),
      ),
    );
  }
}

class _AgentDetailBody extends ConsumerWidget {
  const _AgentDetailBody({required this.agent});

  final Agent agent;

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    final suspending = agent.status == AgentStatus.active;
    final confirmed = await showConfirmDialog(
      context,
      title: suspending ? 'Suspendre cet agent ?' : 'Réactiver cet agent ?',
      message: suspending
          ? '${agent.fullName} perdra immédiatement l\'accès à son compte.'
          : '${agent.fullName} retrouvera l\'accès à son compte.',
      confirmLabel: suspending ? 'Suspendre' : 'Réactiver',
      danger: suspending,
    );
    if (!confirmed) return;

    final controller = ref.read(agentStatusControllerProvider.notifier);
    if (suspending) {
      await controller.suspend(agent.id);
    } else {
      await controller.reactivate(agent.id);
    }
    if (!context.mounted) return;

    if (ref.read(agentStatusControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(
      context,
      suspending ? 'Agent suspendu' : 'Agent réactivé',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = ref.watch(agentStatusControllerProvider).isLoading;
    final isActive = agent.status == AgentStatus.active;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(agent.fullName, style: AppTextStyles.h2),
            AppTag(
              label: agent.status.label,
              variant: isActive ? AppTagVariant.green : AppTagVariant.danger,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              KeyValueRow(label: 'Téléphone', value: agent.phone),
              KeyValueRow(label: 'Zone', value: agent.zone),
              KeyValueRow(label: 'Contrat', value: agent.contractType.label),
              KeyValueRow(
                label: 'Clients rattachés',
                value: '${agent.clientCount}',
              ),
              KeyValueRow(
                label: 'Commission',
                value: formatCurrency(agent.commission),
                valueColor: AppColors.gold,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: isActive ? 'Suspendre cet agent' : 'Réactiver cet agent',
          variant: isActive ? AppButtonVariant.danger : AppButtonVariant.green,
          loading: submitting,
          onPressed: submitting ? null : () => _toggleStatus(context, ref),
        ),
      ],
    );
  }
}
