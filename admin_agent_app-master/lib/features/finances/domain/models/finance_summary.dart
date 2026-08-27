import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../families/domain/models/savings_plan.dart';

part 'finance_summary.freezed.dart';

@freezed
sealed class CityBreakdown with _$CityBreakdown {
  const factory CityBreakdown({
    required String city,
    required int familyCount,
    required double amount,
  }) = _CityBreakdown;
}

@freezed
sealed class PlanBreakdown with _$PlanBreakdown {
  const factory PlanBreakdown({
    required SavingsPlan plan,
    required int familyCount,
    required double amount,
  }) = _PlanBreakdown;
}

/// Bilan financier de la saison (motif `ad_fi` du prototype).
@freezed
sealed class FinanceSummary with _$FinanceSummary {
  const factory FinanceSummary({
    required double totalCollected,
    required int activeFamilies,
    required List<CityBreakdown> byCity,
    required List<PlanBreakdown> byPlan,
  }) = _FinanceSummary;
}
