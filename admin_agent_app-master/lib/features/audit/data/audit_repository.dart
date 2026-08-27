import '../domain/models/audit_log_entry.dart';

abstract interface class AuditRepository {
  Future<List<AuditLogEntry>> getRecent();
}
