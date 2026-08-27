import 'package:freezed_annotation/freezed_annotation.dart';

import 'dashboard_alert.dart';

part 'dashboard_summary.freezed.dart';

/// Résumé affiché sur le tableau de bord Admin (motif `ad_d` du prototype) :
/// KPI de la saison en cours + alertes.
@freezed
sealed class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required String season,
    required int activeFamilies,
    required double totalCollected,

    /// Entre 0 et 1, ex. 0.89 pour "89%".
    required double collectionRate,
    required int overduePayments,
    required int activeAgents,
    required int pendingDeliveries,
    required List<DashboardAlert> alerts,
  }) = _DashboardSummary;
}
