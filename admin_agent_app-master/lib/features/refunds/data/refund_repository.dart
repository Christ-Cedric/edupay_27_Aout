import '../domain/models/refund_detail.dart';
import '../domain/models/refund_month_summary.dart';
import '../domain/models/refund_request.dart';

abstract interface class RefundRepository {
  Future<List<RefundRequest>> getPendingRefunds();

  Future<RefundDetail> getRefundById(String id);

  Future<void> approveRefund(String id);

  Future<void> rejectRefund(String id);

  Future<RefundMonthSummary> getMonthSummary();
}
