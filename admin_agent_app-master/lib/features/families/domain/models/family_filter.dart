import 'package:freezed_annotation/freezed_annotation.dart';

import 'family_status.dart';

part 'family_filter.freezed.dart';

/// Critères de filtrage de la liste des familles (motif des puces de
/// filtre `.tag` sur l'écran `ad_fa`).
@freezed
sealed class FamilyFilter with _$FamilyFilter {
  const factory FamilyFilter({
    @Default('') String query,
    FamilyStatus? status,
    String? city,
    String? assignedAgentName,
  }) = _FamilyFilter;
}
