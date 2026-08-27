import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/refund_detail.dart';
import '../domain/models/refund_failure.dart';
import '../domain/models/refund_month_summary.dart';
import '../domain/models/refund_request.dart';
import 'refund_data_source.dart';

RefundRequest _parseRefund(Map<String, dynamic> json) {
  return RefundRequest(
    id: json['id'] as String,
    reference: json['reference'] as String,
    familyName: json['family_name'] as String,
    amount: (json['amount'] as num).toDouble(),
    reason: json['reason'] as String,
  );
}

RefundDetail _parseDetail(Map<String, dynamic> json) {
  return RefundDetail(
    id: json['id'] as String,
    reference: json['reference'] as String,
    familyName: json['family_name'] as String,
    amount: (json['amount'] as num).toDouble(),
    reason: json['reason'] as String,
    status: RefundStatus.values.byName(json['status'] as String),
    processedByAdminName: json['processed_by_admin_name'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

RefundMonthSummary _parseMonthSummary(Map<String, dynamic> json) {
  return RefundMonthSummary(
    approvedCount: json['approved_count'] as int,
    approvedAmount: (json['approved_amount'] as num).toDouble(),
    feesRetained: (json['fees_retained'] as num).toDouble(),
  );
}

/// Implémentation backend du seam [RefundDataSource] (endpoint
/// `/admin/refunds`, contrat partagé §5.4). Le serveur renvoie en une seule
/// réponse `{ pending, month_summary }` ; l'interface app exposant deux
/// méthodes distinctes, chacune ré-interroge l'endpoint (écran peu
/// fréquenté, coût négligeable face à la simplicité de ne pas mettre en
/// cache manuellement).
class RestRefundDataSource implements RefundDataSource {
  const RestRefundDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<RefundRequest>> fetchPending() async {
    final json = await _client.get(ApiRoutes.adminRefunds);
    return (json['pending'] as List).cast<Map<String, dynamic>>().map(_parseRefund).toList();
  }

  @override
  Future<RefundDetail> fetchById(String id) async {
    try {
      final json = await _client.get(ApiRoutes.adminRefund(id));
      return _parseDetail(json);
    } on ApiException catch (e) {
      if (e.statusCode == 404) throw RefundFailure(e.message);
      rethrow;
    }
  }

  @override
  Future<void> approve(String id) async {
    await _client.post(ApiRoutes.adminApproveRefund(id));
  }

  @override
  Future<void> reject(String id) async {
    await _client.post(ApiRoutes.adminRejectRefund(id));
  }

  @override
  Future<RefundMonthSummary> fetchMonthSummary() async {
    final json = await _client.get(ApiRoutes.adminRefunds);
    return _parseMonthSummary(json['month_summary'] as Map<String, dynamic>);
  }
}
