import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/export/csv_exporter.dart';
import '../../../../core/export/pdf_exporter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_tag.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../agent_terrain/domain/models/collection.dart';
import '../../../agent_terrain/domain/models/collection_mode.dart';
import '../../../agent_terrain/presentation/providers/agent_terrain_providers.dart';
import '../../../families/domain/models/delivery_status.dart';
import '../../../families/domain/models/family.dart';
import '../../../families/domain/models/family_filter.dart';
import '../../../families/domain/models/family_status.dart';
import '../../../families/domain/models/savings_plan.dart';
import '../../../families/presentation/providers/families_providers.dart';
import '../../../finances/presentation/providers/finance_providers.dart';
import '../../../finances/presentation/screens/financial_overview_screen.dart'
    show buildFinanceSummaryRows, financeSummaryCsvHeaders;
import '../../../kits/domain/models/kit.dart';
import '../../../kits/presentation/providers/kits_providers.dart';

const contributionsCsvHeaders = ['Date', 'Famille', 'Agent', 'Montant', 'Mode', 'Reçu'];

/// Lignes CSV du rapport "cotisations" — fonction pure (pas d'I/O), testable
/// sans mock de plateforme.
List<List<String>> buildContributionsRows(List<Collection> collections) {
  final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
  return [
    for (final c in collections)
      [
        dateFormat.format(c.collectedAt),
        c.familyName,
        c.agentName,
        formatCurrency(c.amount),
        c.mode.label,
        c.receiptNumber,
      ],
  ];
}

const familiesPdfHeaders = [
  'Nom',
  'Ville',
  'Statut',
  'Plan',
  'Solde',
  'Objectif',
  'Enfants',
  'Livraison',
];

/// Lignes PDF du rapport "familles" — fonction pure, testable sans mock de
/// plateforme.
List<List<String>> buildFamiliesRows(List<Family> families) {
  return [
    for (final f in families)
      [
        f.fullName,
        f.city,
        _familyStatusLabel(f.status),
        f.plan.label,
        formatCurrency(f.balance),
        formatCurrency(f.targetAmount),
        '${f.childrenCount}',
        f.deliveryStatus.label,
      ],
  ];
}

const deliveriesPdfHeaders = ['Famille', 'Ville', 'Kits', 'Livraison', 'Agent'];

/// Lignes PDF du rapport "livraisons" — fonction pure, testable sans mock de
/// plateforme. Joint chaque enfant à son kit via `kits` (pas de méthode de
/// repository dédiée à cette jointure).
List<List<String>> buildDeliveriesRows(List<Family> families, List<Kit> kits) {
  final kitById = {for (final k in kits) k.id: k};
  String kitsLabel(List<FamilyChild> children) {
    if (children.isEmpty) return '—';
    return children.map((c) => kitById[c.kitId]?.fullLabel ?? '—').join(', ');
  }

  return [
    for (final f in families)
      [
        f.fullName,
        f.city,
        kitsLabel(f.children),
        f.deliveryStatus.label,
        f.assignedAgentName ?? '—',
      ],
  ];
}

const _reports = [
  (
    '📊',
    'Rapport cotisations',
    'Toutes les cotisations par date',
    'Exporter Excel',
  ),
  ('👥', 'Rapport familles', 'Liste complète avec statuts', 'Exporter PDF'),
  (
    '💰',
    'Rapport financier',
    'Recettes par ville et par plan',
    'Exporter Excel',
  ),
  (
    '🚚',
    'Rapport livraisons',
    'Statuts de toutes les livraisons',
    'Exporter PDF',
  ),
];

String _familyStatusLabel(FamilyStatus status) => switch (status) {
  FamilyStatus.active => 'Actif',
  FamilyStatus.lateOverdue => 'Impayé',
  FamilyStatus.pendingValidation => 'En attente',
  FamilyStatus.rejected => 'Rejeté',
};

/// Rapports et exports (motif `ad_rp` du prototype).
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int? _loadingIndex;

  Future<void> _export(int index) async {
    setState(() => _loadingIndex = index);
    try {
      switch (index) {
        case 0:
          await _exportContributions();
        case 1:
          await _exportFamilies();
        case 2:
          await _exportFinancial();
        case 3:
          await _exportDeliveries();
      }
    } catch (_) {
      if (mounted) {
        showAppToast(
          context,
          'Échec de l\'export.',
          type: AppToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingIndex = null);
    }
  }

  Future<void> _exportContributions() async {
    final collections = await ref
        .read(collectionRepositoryProvider)
        .getAllHistory();
    await exportCsvAndShare(
      fileName: 'rapport_cotisations.csv',
      headers: contributionsCsvHeaders,
      rows: buildContributionsRows(collections),
    );
  }

  Future<void> _exportFamilies() async {
    final families = await ref.read(
      familiesListProvider(const FamilyFilter()).future,
    );
    await exportPdfAndShare(
      fileName: 'rapport_familles.pdf',
      title: 'Rapport familles',
      headers: familiesPdfHeaders,
      rows: buildFamiliesRows(families),
    );
  }

  Future<void> _exportFinancial() async {
    final summary = await ref.read(financeSummaryProvider.future);
    await exportCsvAndShare(
      fileName: 'rapport_financier.csv',
      headers: financeSummaryCsvHeaders,
      rows: buildFinanceSummaryRows(summary),
    );
  }

  Future<void> _exportDeliveries() async {
    final families = await ref.read(
      familiesListProvider(const FamilyFilter()).future,
    );
    final kits = await ref.read(kitsListProvider.future);
    await exportPdfAndShare(
      fileName: 'rapport_livraisons.pdf',
      title: 'Rapport livraisons',
      headers: deliveriesPdfHeaders,
      rows: buildDeliveriesRows(families, kits),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Rapports Exports', onBack: () => context.pop()),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final (index, (icon, title, subtitle, action))
              in _reports.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: _loadingIndex == null ? () => _export(index) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$icon $title', style: AppTextStyles.bodyStrong),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.sm),
                    _loadingIndex == index
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : AppTag(label: action, variant: AppTagVariant.green),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
