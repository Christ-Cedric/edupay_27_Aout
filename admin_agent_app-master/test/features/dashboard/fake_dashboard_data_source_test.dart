import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/dashboard/data/fake_dashboard_data_source.dart';
import 'package:edupay_admin/features/dashboard/domain/models/dashboard_alert.dart';

void main() {
  test('fetchSummary renvoie les chiffres du prototype (écran ad_d)', () async {
    final summary = await FakeDashboardDataSource().fetchSummary();

    expect(summary.activeFamilies, 47);
    expect(summary.totalCollected, 1200000);
    expect(summary.collectionRate, 0.89);
    expect(summary.overduePayments, 5);
    expect(summary.activeAgents, 3);
    expect(summary.pendingDeliveries, 12);
    expect(summary.alerts, hasLength(2));
    expect(summary.alerts.first.severity, DashboardAlertSeverity.danger);
  });
}
