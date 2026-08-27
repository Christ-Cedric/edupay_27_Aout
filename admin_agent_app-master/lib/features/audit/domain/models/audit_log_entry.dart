import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_entry.freezed.dart';

/// Une entrée du journal d'audit (traçabilité des actions sensibles :
/// suspension d'agent, validation de famille, création de kit...).
@freezed
sealed class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    required String id,
    required String actorId,
    String? actorName,
    required String action,
    required String entity,
    String? entityId,
    Object? before,
    Object? after,
    required DateTime createdAt,
  }) = _AuditLogEntry;
}
