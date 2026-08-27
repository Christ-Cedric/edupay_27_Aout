import '../domain/models/finance_summary.dart';

abstract interface class FinanceRepository {
  Future<FinanceSummary> getSummary();
}
