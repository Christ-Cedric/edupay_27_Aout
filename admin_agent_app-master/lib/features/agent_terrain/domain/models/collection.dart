import 'package:freezed_annotation/freezed_annotation.dart';

import 'collection_mode.dart';

part 'collection.freezed.dart';

/// Un encaissement de cotisation par un agent terrain (motif `ag_en`/`ag_rc`
/// du prototype).
@freezed
sealed class Collection with _$Collection {
  const factory Collection({
    required String id,
    required String familyId,
    required String familyName,
    required String agentName,
    required double amount,
    required CollectionMode mode,
    required DateTime collectedAt,
    required String receiptNumber,
  }) = _Collection;
}
