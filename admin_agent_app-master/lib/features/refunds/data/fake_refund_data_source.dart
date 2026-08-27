import '../domain/models/refund_detail.dart';
import '../domain/models/refund_failure.dart';
import '../domain/models/refund_month_summary.dart';
import '../domain/models/refund_request.dart';
import 'refund_data_source.dart';

/// Frais retenus par remboursement traité (motif `ad_pa` du prototype,
/// section "Frais remboursement").
const _feePerRefund = 500.0;

/// Source de données en mémoire, seedée avec la demande du prototype
/// (écran `ad_re`). Mode `mock` du seam [RefundDataSource].
class FakeRefundDataSource implements RefundDataSource {
  final List<RefundRequest> _pending = [
    const RefundRequest(
      id: 'refund-1',
      reference: 'RMB-2026-0012',
      familyName: 'Aminata Kabore',
      amount: 24200,
      reason: 'Difficultés financières',
    ),
  ];

  /// Décisions passées, conservées pour le dossier détail (historique).
  final List<RefundDetail> _processed = [];

  int _approvedCount = 0;
  double _approvedAmount = 0;

  @override
  Future<List<RefundRequest>> fetchPending() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_pending);
  }

  @override
  Future<RefundDetail> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final processed = _processed.where((r) => r.id == id).firstOrNull;
    if (processed != null) return processed;

    final pending = _pending.where((r) => r.id == id).firstOrNull;
    if (pending == null) throw RefundFailure('Remboursement introuvable : $id');
    return RefundDetail(
      id: pending.id,
      reference: pending.reference,
      familyName: pending.familyName,
      amount: pending.amount,
      reason: pending.reason,
      status: RefundStatus.requested,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> approve(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final refund = _pending.firstWhere((r) => r.id == id);
    _approvedCount += 1;
    _approvedAmount += refund.amount;
    _pending.removeWhere((r) => r.id == id);
    _processed.add(
      RefundDetail(
        id: refund.id,
        reference: refund.reference,
        familyName: refund.familyName,
        amount: refund.amount,
        reason: refund.reason,
        status: RefundStatus.approved,
        processedByAdminName: 'DERRA Bassirou',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> reject(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final refund = _pending.firstWhere((r) => r.id == id);
    _pending.removeWhere((r) => r.id == id);
    _processed.add(
      RefundDetail(
        id: refund.id,
        reference: refund.reference,
        familyName: refund.familyName,
        amount: refund.amount,
        reason: refund.reason,
        status: RefundStatus.rejected,
        processedByAdminName: 'DERRA Bassirou',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<RefundMonthSummary> fetchMonthSummary() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return RefundMonthSummary(
      approvedCount: _approvedCount,
      approvedAmount: _approvedAmount,
      feesRetained: _approvedCount * _feePerRefund,
    );
  }
}
