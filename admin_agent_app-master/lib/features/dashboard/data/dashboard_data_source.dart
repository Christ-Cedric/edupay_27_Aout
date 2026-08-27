import '../domain/models/dashboard_summary.dart';

/// Contrat de source de données du tableau de bord — seam mock ↔ REST.
/// Le [DashboardRepository] dépend de cette interface, le choix se fait au
/// composition root (provider) selon `AppEnvironment`.
abstract interface class DashboardDataSource {
  Future<DashboardSummary> fetchSummary();
}
