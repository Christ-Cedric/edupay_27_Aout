import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_tag.dart';
import '../../../../core/theme/widgets/initials_avatar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/agent.dart';
import '../providers/agents_providers.dart';

/// Liste des agents terrain (motif `ad_ag` du prototype).
class AgentsListScreen extends ConsumerWidget {
  const AgentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentsListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Agents terrain',
        onBack: () => context.pop(),
        trailing: IconButton(
          icon: const Icon(
            Icons.person_add_alt,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.push('/admin/settings/agents/new'),
        ),
      ),
      body: agentsAsync.when(
        data: (agents) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (agents.isEmpty)
              const EmptyState(
                icon: Icons.groups_outlined,
                title: 'Aucun agent',
                subtitle: 'Ajoutez votre premier agent terrain',
              ),
            for (final agent in agents)
              InkWell(
                onTap: () =>
                    context.push('/admin/settings/agents/${agent.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      InitialsAvatar(name: agent.fullName, size: 32),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(agent.fullName, style: AppTextStyles.bodyStrong),
                            Text(
                              '${agent.zone} - ${agent.clientCount} clients',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppTag(
                            label: agent.status.label,
                            variant: agent.status == AgentStatus.active
                                ? AppTagVariant.green
                                : AppTagVariant.danger,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatCompactCurrency(agent.commission),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: '+ Ajouter un agent',
              onPressed: () => context.push('/admin/settings/agents/new'),
            ),
          ],
        ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(agentsListProvider)),
      ),
    );
  }
}
