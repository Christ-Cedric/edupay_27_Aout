import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/dashboard_data_source.dart';
import '../../data/dashboard_repository.dart';
import '../../data/dashboard_repository_impl.dart';
import '../../data/fake_dashboard_data_source.dart';
import '../../data/rest_dashboard_data_source.dart';
import '../../domain/models/dashboard_summary.dart';

part 'dashboard_providers.g.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@riverpod
DashboardDataSource dashboardDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeDashboardDataSource();
  }
  return RestDashboardDataSource(ref.watch(apiClientProvider));
}

@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardDataSourceProvider));
}

@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) {
  return ref.watch(dashboardRepositoryProvider).getSummary();
}
