import '../../../core/network/api_client.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/dashboard_alert.dart';
import '../domain/models/dashboard_summary.dart';
import 'dashboard_data_source.dart';

/// Implémentation backend du seam [DashboardDataSource] (endpoint
/// `/admin/dashboard`, contrat partagé §5.4).
class RestDashboardDataSource implements DashboardDataSource {
  const RestDashboardDataSource(this._client);

  final ApiClient _client;

  @override
  Future<DashboardSummary> fetchSummary() async {
    final json = await _client.get(ApiRoutes.adminDashboard);
    return DashboardSummary(
      season: json['season'] as String,
      activeFamilies: json['active_families'] as int,
      totalCollected: (json['total_collected'] as num).toDouble(),
      collectionRate: (json['collection_rate'] as num).toDouble(),
      overduePayments: json['overdue_payments'] as int,
      activeAgents: json['active_agents'] as int,
      pendingDeliveries: json['pending_deliveries'] as int,
      alerts: (json['alerts'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (a) => DashboardAlert(
              title: a['title'] as String,
              subtitle: a['subtitle'] as String,
              severity: DashboardAlertSeverity.values.byName(a['severity'] as String),
              kind: _kindFromCode(a['code'] as String?),
            ),
          )
          .toList(),
    );
  }

  DashboardAlertKind _kindFromCode(String? code) => switch (code) {
    'pending_validation' => DashboardAlertKind.pendingValidation,
    'overdue_payments' => DashboardAlertKind.overduePayments,
    'pending_deliveries' => DashboardAlertKind.pendingDeliveries,
    'season_progress' => DashboardAlertKind.seasonProgress,
    _ => DashboardAlertKind.other,
  };
}
