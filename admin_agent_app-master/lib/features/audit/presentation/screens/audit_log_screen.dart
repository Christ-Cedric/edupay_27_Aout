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
import '../providers/audit_providers.dart';

final _dateTimeFormat = DateFormat('d MMM yyyy, HH:mm', 'fr_FR');

/// Journal d'audit — traçabilité des actions sensibles (suspension d'agent,
/// validation de famille, création de kit...). Lecture seule.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Journal d\'audit', onBack: () => context.pop()),
      body: logsAsync.when(
        data: (logs) => logs.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Aucune action enregistrée',
                subtitle: 'Les actions sensibles apparaîtront ici',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final entry = logs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(entry.action, style: AppTextStyles.bodyStrong),
                        subtitle: Text(
                          '${entry.actorName ?? entry.actorId} · '
                          '${_dateTimeFormat.format(entry.createdAt)}',
                          style: AppTextStyles.caption,
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Text(
                                'Entité : ${entry.entity}'
                                '${entry.entityId != null ? ' (${entry.entityId})' : ''}\n'
                                'Avant : ${entry.before ?? '—'}\n'
                                'Après : ${entry.after ?? '—'}',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(auditLogsListProvider)),
      ),
    );
  }
}
