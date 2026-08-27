import '../domain/models/dashboard_summary.dart';
import 'dashboard_data_source.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dataSource);

  final DashboardDataSource _dataSource;

  @override
  Future<DashboardSummary> getSummary() => _dataSource.fetchSummary();
}
