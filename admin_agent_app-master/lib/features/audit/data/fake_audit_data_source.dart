import '../domain/models/audit_log_entry.dart';
import 'audit_data_source.dart';

/// Source de données en mémoire, seedée avec quelques entrées d'exemple.
/// Mode `mock` du seam [AuditDataSource].
class FakeAuditDataSource implements AuditDataSource {
  @override
  Future<List<AuditLogEntry>> fetchRecent() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AuditLogEntry(
        id: 'audit-1',
        actorId: 'admin-1',
        actorName: 'DERRA Bassirou',
        action: 'agent.created',
        entity: 'user',
        entityId: 'agent-1',
        after: const {'fullName': 'Konate Ali', 'zone': 'Koudougou'},
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AuditLogEntry(
        id: 'audit-2',
        actorId: 'admin-1',
        actorName: 'DERRA Bassirou',
        action: 'client.approved',
        entity: 'user',
        entityId: 'fam-5',
        before: const {'status': 'pendingValidation'},
        after: const {'status': 'active'},
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
