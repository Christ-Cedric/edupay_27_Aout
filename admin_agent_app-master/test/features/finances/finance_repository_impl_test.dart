import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/families/data/fake_family_data_source.dart';
import 'package:edupay_admin/features/families/data/family_repository_impl.dart';
import 'package:edupay_admin/features/finances/data/finance_repository_impl.dart';

void main() {
  test(
    'getSummary calcule le bilan à partir des soldes réels des familles',
    () async {
      final repository = FinanceRepositoryImpl(
        FamilyRepositoryImpl(FakeFamilyDataSource()),
      );

      final summary = await repository.getSummary();

      expect(summary.totalCollected, 59300);
      expect(summary.activeFamilies, 3);
      expect(
        summary.byCity.fold<double>(0, (sum, c) => sum + c.amount),
        summary.totalCollected,
      );
      expect(
        summary.byPlan.fold<double>(0, (sum, p) => sum + p.amount),
        summary.totalCollected,
      );
    },
  );
}
