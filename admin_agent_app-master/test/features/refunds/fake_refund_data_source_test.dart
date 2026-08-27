import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/refunds/data/fake_refund_data_source.dart';

void main() {
  test('fetchPending renvoie la demande du prototype (écran ad_re)', () async {
    final pending = await FakeRefundDataSource().fetchPending();
    expect(pending, hasLength(1));
    expect(pending.single.familyName, 'Aminata Kabore');
  });

  test('approve retire la demande de la liste en attente', () async {
    final dataSource = FakeRefundDataSource();
    await dataSource.approve('refund-1');
    expect(await dataSource.fetchPending(), isEmpty);
  });

  test('reject retire la demande de la liste en attente', () async {
    final dataSource = FakeRefundDataSource();
    await dataSource.reject('refund-1');
    expect(await dataSource.fetchPending(), isEmpty);
  });

  test('fetchMonthSummary reflète les remboursements approuvés', () async {
    final dataSource = FakeRefundDataSource();

    final before = await dataSource.fetchMonthSummary();
    expect(before.approvedCount, 0);

    await dataSource.approve('refund-1');
    final after = await dataSource.fetchMonthSummary();

    expect(after.approvedCount, 1);
    expect(after.approvedAmount, 24200);
    expect(after.feesRetained, 500);
  });
}
