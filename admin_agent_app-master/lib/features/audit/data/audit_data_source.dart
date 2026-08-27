import '../domain/models/audit_log_entry.dart';

/// Contrat de source de données du journal d'audit — seam mock ↔ REST.
/// Lecture seule : aucune action n'écrit jamais dans le journal côté app.
abstract interface class AuditDataSource {
  Future<List<AuditLogEntry>> fetchRecent();
}
