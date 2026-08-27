import 'package:freezed_annotation/freezed_annotation.dart';

part 'refund_month_summary.freezed.dart';

/// Bilan des remboursements traités ce mois (motif `ad_re` du prototype,
/// section "Traités ce mois").
@freezed
sealed class RefundMonthSummary with _$RefundMonthSummary {
  const factory RefundMonthSummary({
    required int approvedCount,
    required double approvedAmount,
    required double feesRetained,
  }) = _RefundMonthSummary;
}
