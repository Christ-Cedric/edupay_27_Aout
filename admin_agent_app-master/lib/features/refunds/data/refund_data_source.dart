import '../domain/models/refund_detail.dart';
import '../domain/models/refund_month_summary.dart';
import '../domain/models/refund_request.dart';

/// Contrat de source de données des remboursements — seam mock ↔ REST.
abstract interface class RefundDataSource {
  Future<List<RefundRequest>> fetchPending();

  Future<RefundDetail> fetchById(String id);

  Future<void> approve(String id);

  Future<void> reject(String id);

  Future<RefundMonthSummary> fetchMonthSummary();
}
