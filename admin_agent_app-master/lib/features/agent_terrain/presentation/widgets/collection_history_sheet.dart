import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/collection_mode.dart';
import '../providers/agent_terrain_providers.dart';

/// Bottom sheet d'historique des cotisations d'une famille (motif `ag_fi`
/// du prototype) — utilisée à la fois par la fiche client Agent et par le
/// dossier famille Admin.
void showCollectionHistorySheet(BuildContext context, String familyId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final historyAsync = ref.watch(
            familyCollectionHistoryProvider(familyId),
          );
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: historyAsync.when(
              data: (history) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historique des transactions',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final entry in history)
                    KeyValueRow(
                      label: '${entry.receiptNumber} - ${entry.mode.label}',
                      value: formatCurrency(entry.amount),
                      valueColor: AppColors.green,
                      showDivider: entry != history.last,
                    ),
                  if (history.isEmpty)
                    const Text(
                      'Aucune transaction pour le moment.',
                      style: AppTextStyles.bodySecondary,
                    ),
                ],
              ),
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => const Text(
                'Impossible de charger l\'historique.',
                style: AppTextStyles.errorText,
              ),
            ),
          );
        },
      );
    },
  );
}
