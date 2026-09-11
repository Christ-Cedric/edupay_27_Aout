import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/contract/contract_document.dart';
import '../../../../core/contract/contract_pdf_exporter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/family.dart';
import '../../domain/models/savings_plan.dart';
import '../providers/families_providers.dart';
import '../widgets/family_status_tag.dart';

/// Écran complet du contrat d'engagement client côté Admin.
/// Reproduit fidèlement la structure, les clauses, les sections et le rendu
/// du contrat de l'application Client (Scolarité, Fournitures, Déplacement).
class FamilyContractScreen extends ConsumerWidget {
  const FamilyContractScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyDetailProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: "Contrat d'engagement",
        onBack: () => context.pop(),
        trailing: familyAsync.maybeWhen(
          data: (family) {
            final document = buildContractDocumentFromFamily(family: family);
            return IconButton(
              icon: const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.green,
              ),
              tooltip: 'Exporter en PDF',
              onPressed: () => exportContractPdf(document),
            );
          },
          orElse: () => null,
        ),
      ),
      body: familyAsync.when(
        data: (family) => _FamilyContractView(family: family),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(familyDetailProvider(familyId)),
        ),
      ),
    );
  }
}

class _FamilyContractView extends StatelessWidget {
  const _FamilyContractView({required this.family});

  final Family family;

  @override
  Widget build(BuildContext context) {
    final document = buildContractDocumentFromFamily(family: family);
    final remaining =
        (family.targetAmount - family.balance).clamp(0, family.targetAmount);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // En-tête Client
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(family.fullName, style: AppTextStyles.h2),
                  const SizedBox(height: 2),
                  Text(
                    'Contrat n° ${document.contractNumber}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            FamilyStatusTag(status: family.status),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Détail des enfants et catégories (Scolarité, Fournitures, Déplacement)
        if (family.children.isNotEmpty) ...[
          const Text(
            'ENFANTS & CATÉGORIES D\'ÉPARGNE',
            style: AppTextStyles.sectionLabel,
          ),
          const SizedBox(height: AppSpacing.xs),
          ...family.children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ChildContractCard(child: child),
              )),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Récapitulatif financier
        AppCard(
          child: Column(
            children: [
              KeyValueRow(
                label: 'Plan de cotisation',
                value: family.plan.labelWithAmount,
              ),
              KeyValueRow(
                label: 'Objectif total',
                value: formatCurrency(family.targetAmount),
              ),
              KeyValueRow(
                label: 'Solde collecté',
                value: formatCurrency(family.balance),
                valueColor: AppColors.gold,
              ),
              KeyValueRow(
                label: 'Reste à cotiser',
                value: formatCurrency(remaining),
                valueColor: AppColors.green,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Bouton d'exportation PDF rapide
        AppButton(
          label: 'Télécharger / Partager le contrat PDF',
          icon: Icons.picture_as_pdf_outlined,
          variant: AppButtonVariant.outline,
          onPressed: () => exportContractPdf(document),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Sections complètes du contrat (Texte officiel et articles)
        const Text(
          'CLAUSES & CONDITIONS GÉNÉRALES',
          style: AppTextStyles.sectionLabel,
        ),
        const SizedBox(height: AppSpacing.xs),
        ...document.sections.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ContractSectionCard(section: section),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _ChildContractCard extends StatelessWidget {
  const _ChildContractCard({required this.child});

  final FamilyChild child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    child.firstName.isNotEmpty
                        ? child.firstName.substring(0, 1).toUpperCase()
                        : 'E',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.firstName,
                      style: AppTextStyles.bodyStrong,
                    ),
                    Text(
                      '${child.school.isNotEmpty ? child.school : "École non précisée"} — Classe : ${child.level.isNotEmpty ? child.level : "N/A"}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrency(child.totalCost),
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (child.kitPrice > 0)
                _CategoryTag(
                  label: 'Fournitures : ${formatCurrency(child.kitPrice)}',
                  color: AppColors.info,
                ),
              if ((child.tuitionAmount ?? 0) > 0)
                _CategoryTag(
                  label:
                      'Scolarité : ${formatCurrency(child.tuitionAmount ?? 0)}',
                  color: AppColors.green,
                ),
              if ((child.transportAmount ?? 0) > 0)
                _CategoryTag(
                  label:
                      '${child.transportType ?? "Déplacement"} : ${formatCurrency(child.transportAmount ?? 0)}',
                  color: AppColors.gold,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContractSectionCard extends StatelessWidget {
  const _ContractSectionCard({required this.section});

  final ContractSection section;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final paragraph in section.paragraphs) ...[
            Text(
              paragraph,
              style: AppTextStyles.bodySecondary.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            if (paragraph != section.paragraphs.last)
              const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
