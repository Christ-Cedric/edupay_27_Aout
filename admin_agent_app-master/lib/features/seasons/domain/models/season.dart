import 'package:freezed_annotation/freezed_annotation.dart';

part 'season.freezed.dart';

/// Une saison scolaire (motif `ad_pa` du prototype, section « Saison en
/// cours »). Une seule saison est `isCurrent` à la fois (contrainte serveur).
@freezed
sealed class Season with _$Season {
  const factory Season({
    required String id,
    required String label,
    required DateTime launchDate,
    required DateTime deliveryDeadline,
    required bool enrollmentOpen,
    required int refundFee,
    required bool isCurrent,
  }) = _Season;
}
