import '../domain/models/dashboard_summary.dart';

/// Interface d'accès aux données du tableau de bord — seul point à modifier
/// quand le vrai backend arrivera (remplacer [FakeDashboardDataSource] par
/// une source Dio, sans toucher à l'UI/aux providers).
abstract interface class DashboardRepository {
  Future<DashboardSummary> getSummary();
}
