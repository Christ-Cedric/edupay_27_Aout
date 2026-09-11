import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/collection.dart';
import '../../domain/models/collection_mode.dart';
import '../providers/agent_terrain_providers.dart';

/// Couleur associée à chaque catégorie d'épargne.
Color _goalTypeColor(String? type) => switch (type) {
      'registration' => AppColors.green, // vert — Scolarité
      'supplies' => AppColors.info, // bleu — Fournitures
      'transport' => AppColors.gold, // or/jaune — Déplacement
      _ => AppColors.gold,
    };

String _goalTypeName(String? type) => switch (type) {
      'registration' => 'Scolarité',
      'supplies' => 'Fournitures',
      'transport' => 'Déplacement',
      'exam' => 'Examen',
      'canteen' => 'Cantine',
      'uniform' => 'Tenue',
      _ => 'Cotisation',
    };

/// Bottom sheet d'historique des cotisations d'une famille (motif `ag_fi`
/// du prototype) — utilisée à la fois par la fiche client Agent et par le
/// dossier famille Admin.
void showCollectionHistorySheet(BuildContext context, String familyId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Consumer(
          builder: (context, ref, _) {
            final historyAsync =
                ref.watch(familyCollectionHistoryProvider(familyId));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Historique des cotisations',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  historyAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Center(
                            child: Text(
                              'Aucune cotisation enregistrée pour cette famille.',
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: items
                            .map((item) => _CollectionRow(entry: item))
                            .toList(),
                      );
                    },
                    loading: () => const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, s) => const Text(
                      "Impossible de charger l'historique.",
                      style: AppTextStyles.errorText,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({required this.entry});

  final Collection entry;

  @override
  Widget build(BuildContext context) {
    // Si la cotisation a un targetGoalType unique ou précis
    final primaryGoalType = entry.targetGoalType ??
        (entry.allocations.isNotEmpty ? entry.allocations.first.goalType : null);
    final goalColor = _goalTypeColor(primaryGoalType);
    final dateStr = DateFormat('d MMM yyyy', 'fr_FR').format(entry.collectedAt);

    final hasMultipleAllocations = entry.allocations.length > 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre latérale colorée
          Container(
            width: 4,
            height: hasMultipleAllocations ? 68 : 48,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: goalColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge principal de catégorie (Scolarité / Fournitures / Déplacement)
                    if (!hasMultipleAllocations)
                      _CategoryBadge(
                        label: _goalTypeName(primaryGoalType),
                        color: goalColor,
                      )
                    else
                      const _CategoryBadge(
                        label: 'Répartition multi-objectifs',
                        color: AppColors.gold,
                      ),
                    Text(
                      formatCurrency(entry.amount),
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                // Si la cotisation a été ventilée sur plusieurs objectifs (ex. Scolarité + Transport + Fournitures)
                if (hasMultipleAllocations) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.allocations.map((alloc) {
                      final c = _goalTypeColor(alloc.goalType);
                      final label = _goalTypeName(alloc.goalType);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: c.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '$label : ${formatCurrency(alloc.amount)}',
                          style: TextStyle(
                            color: c,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${entry.receiptNumber} · ${entry.mode.label} · $dateStr',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
