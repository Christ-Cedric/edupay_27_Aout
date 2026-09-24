import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/dashboard_alert.dart';
import '../../domain/models/dashboard_summary.dart';

const _supportWhatsAppNumber = '22656095425';

/// Vue Desktop/Web complète du tableau de bord Administrateur EduP@y.
///
/// Propose une disposition multi-colonnes riche, analytique et optimisée
/// pour les écrans larges (ordinateurs de bureau et tablettes horizontales).
class AdminDesktopDashboardView extends StatelessWidget {
  const AdminDesktopDashboardView({
    super.key,
    required this.summary,
    required this.lastUpdated,
    required this.onRefresh,
  });

  final DashboardSummary summary;
  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  Future<void> _contactSupport() async {
    final url = Uri.parse('https://wa.me/$_supportWhatsAppNumber');
    try {
      await launchUrl(url);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BANNIÈRE D'ACCUEIL & EN-TÊTE ANALYTIQUE
          _buildHeroHeader(context),

          const SizedBox(height: AppSpacing.xl),

          // 2. GRILLE DE 4 KPIS MAJEURS
          _buildKpiGrid(context),

          const SizedBox(height: AppSpacing.lg),

          // 3. BANDEAU DES OPÉRATIONS EN COURS
          _buildOperationsBar(context),

          const SizedBox(height: AppSpacing.xl),

          // 4. DISPOSITION ASYMÉTRIQUE À 2 COLONNES (65% / 35%)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COLONNE GAUCHE (65%) : Traitement des alertes + État logistique
              Expanded(
                flex: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlertsCard(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildKitsProgressCard(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFinancialSummaryCard(context),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.xl),

              // COLONNE DROITE (35%) : Raccourcis + Top agents + Support
              Expanded(
                flex: 35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickAccessHub(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTopAgentsCard(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSupportAndSystemCard(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 1. Bannière d'Accueil & Actions Rapides
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withValues(alpha: 0.8),
            AppColors.navy.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.tag),
                            border: Border.all(
                              color: AppColors.green.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                summary.season.isEmpty
                                    ? 'Saison Active'
                                    : 'Saison ${summary.season}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (lastUpdated != null) ...[
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Synchronisé à ${DateFormat.Hms().format(lastUpdated!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Tableau de Bord — Supervision Centrale',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Supervision en temps réel de la collecte scolaire, du réseau terrain et des livraisons de kits.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton Actualiser
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Actualiser'),
                onPressed: onRefresh,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: AppSpacing.lg),

          // 4 Boutons d'Action Rapide majeurs
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _ActionButton(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Inscrire une Famille',
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.navy,
                onTap: () => context.go('/admin/families/enroll'),
              ),
              _ActionButton(
                icon: Icons.payments_rounded,
                label: 'Enregistrer une Cotisation',
                backgroundColor: AppColors.surfaceSubtle,
                foregroundColor: AppColors.textPrimary,
                borderColor: AppColors.surfaceBorder,
                onTap: () => context.go('/admin/families'),
              ),
              _ActionButton(
                icon: Icons.person_add_rounded,
                label: 'Recruter un Agent',
                backgroundColor: AppColors.surfaceSubtle,
                foregroundColor: AppColors.textPrimary,
                borderColor: AppColors.surfaceBorder,
                onTap: () => context.go('/admin/settings/agents/new'),
              ),
              _ActionButton(
                icon: Icons.bar_chart_rounded,
                label: 'Rapports & Statistiques',
                backgroundColor: AppColors.surfaceSubtle,
                foregroundColor: AppColors.textPrimary,
                borderColor: AppColors.surfaceBorder,
                onTap: () => context.go('/admin/finances/reports'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Grille de 4 KPIs Majeurs
  Widget _buildKpiGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          children: [
            _DesktopKpiCard(
              title: 'Familles Actives',
              value: '${summary.activeFamilies}',
              subtitle: 'Dossiers scolaires engagés',
              icon: Icons.groups_rounded,
              accentColor: AppColors.info,
              onTap: () => context.go('/admin/families'),
            ),
            _DesktopKpiCard(
              title: 'Volume Collecté',
              value: formatCompactCurrency(summary.totalCollected),
              subtitle: 'Épargne cumulée sécurisée',
              icon: Icons.account_balance_wallet_rounded,
              accentColor: AppColors.green,
              onTap: () => context.go('/admin/finances'),
            ),
            _DesktopKpiCard(
              title: 'Taux de Recouvrement',
              value: '${(summary.collectionRate * 100).round()}%',
              subtitle: 'Avancement des quotas',
              icon: Icons.trending_up_rounded,
              accentColor: AppColors.gold,
              progressValue: summary.collectionRate,
              onTap: () => context.go('/admin/finances'),
            ),
            _DesktopKpiCard(
              title: 'Retards Critiques',
              value: '${summary.overduePayments}',
              subtitle: '≥ 3 échéances impayées',
              icon: Icons.warning_amber_rounded,
              accentColor: AppColors.danger,
              onTap: () => context.go('/admin/dashboard/alerts'),
            ),
          ],
        );
      },
    );
  }

  /// 3. Bandeau des Opérations en Cours
  Widget _buildOperationsBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OperationStatusItem(
              icon: Icons.badge_rounded,
              label: 'Agents Actifs',
              count: '${summary.activeAgents}',
              color: AppColors.green,
              onTap: () => context.go('/admin/settings/agents'),
            ),
          ),
          const VerticalDivider(color: AppColors.surfaceBorder),
          Expanded(
            child: _OperationStatusItem(
              icon: Icons.local_shipping_rounded,
              label: 'Livraisons à faire',
              count: '${summary.pendingDeliveries}',
              color: AppColors.info,
              onTap: () => context.go('/admin/finances/deliveries'),
            ),
          ),
          const VerticalDivider(color: AppColors.surfaceBorder),
          Expanded(
            child: _OperationStatusItem(
              icon: Icons.pending_actions_rounded,
              label: 'Validations en attente',
              count: 'À traiter',
              color: AppColors.gold,
              onTap: () => context.go('/admin/families/pending'),
            ),
          ),
          const VerticalDivider(color: AppColors.surfaceBorder),
          Expanded(
            child: _OperationStatusItem(
              icon: Icons.replay_rounded,
              label: 'Remboursements',
              count: 'Suivi',
              color: AppColors.textSecondary,
              onTap: () => context.go('/admin/finances/refunds'),
            ),
          ),
        ],
      ),
    );
  }

  /// 4A. Carte Alertes Prioritaires
  Widget _buildAlertsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alertes Prioritaires & Suivi de Risque',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Dossiers nécessitant une intervention immédiate',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go('/admin/dashboard/alerts'),
                child: const Text('Voir toutes les alertes'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: AppSpacing.md),

          if (summary.alerts.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'Aucune alerte critique en cours',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tous les indicateurs sont au vert pour la saison actuelle.',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
            )
          else
            ...summary.alerts.map((alert) => _buildAlertItem(context, alert)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, DashboardAlert alert) {
    final isCritical = alert.severity == DashboardAlertSeverity.danger;
    final color = isCritical ? AppColors.danger : AppColors.gold;

    String actionLabel = 'Examiner';
    VoidCallback? onAction;

    switch (alert.kind) {
      case DashboardAlertKind.pendingValidation:
        actionLabel = 'Valider dossiers';
        onAction = () => context.go('/admin/families/pending');
      case DashboardAlertKind.overduePayments:
        actionLabel = 'Relancer impayés';
        onAction = () => context.go('/admin/dashboard/alerts');
      case DashboardAlertKind.pendingDeliveries:
        actionLabel = 'Organiser livraisons';
        onAction = () => context.go('/admin/finances/deliveries');
      case DashboardAlertKind.seasonProgress:
        actionLabel = 'Gérer saison';
        onAction = () => context.go('/admin/settings');
      case DashboardAlertKind.other:
        onAction = () => context.go('/admin/dashboard/alerts');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (alert.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    alert.subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withValues(alpha: 0.2),
              foregroundColor: color,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.tag),
              ),
            ),
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// 4B. Carte Répartition Logistique des Kits
  Widget _buildKitsProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kits Scolaires & Fournitures',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Progression de la distribution par cycle scolaire',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => context.go('/admin/settings/kits'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                child: const Text('Catalogue complet'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCycleRow('Primaire (CP1 - CM2)', 0.72, '72% financé'),
          const SizedBox(height: AppSpacing.md),
          _buildCycleRow('Collège (6e - 3e)', 0.58, '58% financé'),
          const SizedBox(height: AppSpacing.md),
          _buildCycleRow('Lycée (2nde - Tle)', 0.44, '44% financé'),
        ],
      ),
    );
  }

  Widget _buildCycleRow(String label, double progress, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              status,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.navy,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// 4C. Carte Synthèse Financière
  Widget _buildFinancialSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supervision Financière & Trésorerie',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Collecte cash des agents et versements bancaires',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.navy,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Bilan complet'),
                onPressed: () => context.go('/admin/finances'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 5. Hub d'Accès Rapide aux Modules
  Widget _buildQuickAccessHub(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modules & Raccourcis Directs',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Accès rapide à l’ensemble des fonctionnalités',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.1,
            children: const [
              _QuickModuleTile(
                icon: Icons.groups_rounded,
                label: 'Familles',
                route: '/admin/families',
              ),
              _QuickModuleTile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Finances',
                route: '/admin/finances',
              ),
              _QuickModuleTile(
                icon: Icons.badge_rounded,
                label: 'Agents',
                route: '/admin/settings/agents',
              ),
              _QuickModuleTile(
                icon: Icons.inventory_2_rounded,
                label: 'Kits',
                route: '/admin/settings/kits',
              ),
              _QuickModuleTile(
                icon: Icons.local_shipping_rounded,
                label: 'Livraisons',
                route: '/admin/finances/deliveries',
              ),
              _QuickModuleTile(
                icon: Icons.history_rounded,
                label: 'Audit Logs',
                route: '/admin/settings/audit-logs',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 6. Carte Top Collecteurs Terrain (Agents)
  Widget _buildTopAgentsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Équipe de Terrain Active',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/admin/settings/agents'),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const _AgentPerformanceRow(
            rank: '1',
            name: 'Kaboré Moussa',
            area: 'Ouagadougou — Secteur 15',
            status: 'Actif',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _AgentPerformanceRow(
            rank: '2',
            name: 'Ouédraogo Fatou',
            area: 'Bobo-Dioulasso — Centre',
            status: 'Actif',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _AgentPerformanceRow(
            rank: '3',
            name: 'Sawadogo Paul',
            area: 'Koudougou — Secteur 2',
            status: 'Actif',
          ),
        ],
      ),
    );
  }

  /// 7. Support & État Plateforme
  Widget _buildSupportAndSystemCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assistance & Plateforme',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Serveur Render & Base PostgreSQL connectés',
                    style: TextStyle(fontSize: 11.5, color: AppColors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceSubtle,
              foregroundColor: AppColors.green,
              side: BorderSide(color: AppColors.green.withValues(alpha: 0.4)),
              elevation: 0,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text(
              'Support WhatsApp Administrateur',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            onPressed: _contactSupport,
          ),
        ],
      ),
    );
  }
}

class _DesktopKpiCard extends StatelessWidget {
  const _DesktopKpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.progressValue,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final double? progressValue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.tag),
                  ),
                  child: Icon(icon, color: accentColor, size: 16),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: accentColor,
              ),
            ),
            if (progressValue != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 4,
                  backgroundColor: AppColors.navy,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              )
            else
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        side: borderColor != null ? BorderSide(color: borderColor!) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
      onPressed: onTap,
    );
  }
}

class _OperationStatusItem extends StatelessWidget {
  const _OperationStatusItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              count,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickModuleTile extends StatelessWidget {
  const _QuickModuleTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentPerformanceRow extends StatelessWidget {
  const _AgentPerformanceRow({
    required this.rank,
    required this.name,
    required this.area,
    required this.status,
  });

  final String rank;
  final String name;
  final String area;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              rank,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  area,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
