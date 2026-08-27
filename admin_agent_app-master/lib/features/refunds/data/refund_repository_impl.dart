import '../domain/models/refund_detail.dart';
import '../domain/models/refund_month_summary.dart';
import '../domain/models/refund_request.dart';
import 'refund_data_source.dart';
import 'refund_repository.dart';

class RefundRepositoryImpl implements RefundRepository {
  RefundRepositoryImpl(this._dataSource);

  final RefundDataSource _dataSource;

  @override
  Future<List<RefundRequest>> getPendingRefunds() => _dataSource.fetchPending();

  @override
  Future<RefundDetail> getRefundById(String id) => _dataSource.fetchById(id);

  @override
  Future<void> approveRefund(String id) => _dataSource.approve(id);

  @override
  Future<void> rejectRefund(String id) => _dataSource.reject(id);

  @override
  Future<RefundMonthSummary> getMonthSummary() =>
      _dataSource.fetchMonthSummary();
}
