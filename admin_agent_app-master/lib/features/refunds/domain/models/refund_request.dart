import 'package:freezed_annotation/freezed_annotation.dart';

part 'refund_request.freezed.dart';

/// Une demande de remboursement (motif `ad_re` du prototype).
@freezed
sealed class RefundRequest with _$RefundRequest {
  const factory RefundRequest({
    required String id,
    required String reference,
    required String familyName,
    required double amount,
    required String reason,
  }) = _RefundRequest;
}
