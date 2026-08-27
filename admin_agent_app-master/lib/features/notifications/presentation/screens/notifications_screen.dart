import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/notification_entry.dart';
import '../providers/notifications_providers.dart';

final _dateTimeFormat = DateFormat('d MMM yyyy, HH:mm', 'fr_FR');

/// Émoji selon le type réel de notification (voir
/// `notifications.service.ts::NotificationType`).
String _iconForType(String type) => switch (type) {
  'new_registration' => '👋',
  'family_assigned_to_agent' || 'agent_assigned' => '🧑‍💼',
  'delivery_issue' => '⚠️',
  'delivery_confirmed' => '📦',
  'contribution_received' || 'goal_completed' => '🎉',
  'contribution_failed' => '⚠️',
  'refund_processed' => '💰',
  'account_approved' => '✅',
  'account_rejected' => '⛔',
  'family_archived' => '📁',
  _ => '🔔',
};

/// Inbox in-app de l'admin (`GET /admin/notifications`) — assignations,
/// nouvelles inscriptions, incidents...
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    Future<void> markRead(NotificationEntry entry) async {
      if (entry.isRead) return;
      await ref.read(notificationsRepositoryProvider).markRead(entry.id);
      ref.invalidate(notificationsListProvider);
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Notifications', onBack: () => context.pop()),
      body: notificationsAsync.when(
        data: (entries) => entries.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'Aucune notification',
                subtitle: 'Les assignations et alertes apparaîtront ici',
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(notificationsListProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        variant: entry.isRead ? AppCardVariant.neutral : AppCardVariant.success,
                        onTap: () => markRead(entry),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_iconForType(entry.type), style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(entry.title, style: AppTextStyles.bodyStrong),
                                      ),
                                      if (!entry.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(entry.body, style: AppTextStyles.caption),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dateTimeFormat.format(entry.createdAt),
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(notificationsListProvider)),
      ),
    );
  }
}
