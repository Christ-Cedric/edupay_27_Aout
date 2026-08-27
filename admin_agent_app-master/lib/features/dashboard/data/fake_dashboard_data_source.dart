import '../domain/models/dashboard_alert.dart';
import '../domain/models/dashboard_summary.dart';
import 'dashboard_data_source.dart';

/// Source de données en mémoire, seedée avec les chiffres du prototype
/// (écran `ad_d`) pour que le dashboard soit visuellement identique au
/// mockup approuvé par le client dès le premier lancement. Mode `mock` du
/// seam [DashboardDataSource].
class FakeDashboardDataSource implements DashboardDataSource {
  @override
  Future<DashboardSummary> fetchSummary() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const DashboardSummary(
      season: 'Saison 2025-2026',
      activeFamilies: 47,
      totalCollected: 1200000,
      collectionRate: 0.89,
      overduePayments: 5,
      activeAgents: 3,
      pendingDeliveries: 12,
      alerts: [
        DashboardAlert(
          title: '5 familles - impayés +14 jours',
          subtitle: 'Action requise - relancer les agents',
          severity: DashboardAlertSeverity.danger,
          kind: DashboardAlertKind.overduePayments,
        ),
        DashboardAlert(
          title: 'Objectif 50 familles - à 94%',
          subtitle: '3 familles de plus pour valider le pilote',
          severity: DashboardAlertSeverity.warning,
          kind: DashboardAlertKind.seasonProgress,
        ),
      ],
    );
  }
}
