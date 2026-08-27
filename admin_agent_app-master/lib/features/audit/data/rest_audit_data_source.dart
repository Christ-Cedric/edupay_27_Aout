import '../../../core/network/api_client.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/audit_log_entry.dart';
import 'audit_data_source.dart';

AuditLogEntry _parseEntry(Map<String, dynamic> json) {
  return AuditLogEntry(
    id: json['id'] as String,
    actorId: json['actor_id'] as String,
    actorName: json['actor_name'] as String?,
    action: json['action'] as String,
    entity: json['entity'] as String,
    entityId: json['entity_id'] as String?,
    before: json['before'],
    after: json['after'],
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

/// Implémentation backend du seam [AuditDataSource] (endpoint
/// `/admin/audit-logs`, paginé côté serveur — première page suffit pour cet
/// écran de consultation simple).
class RestAuditDataSource implements AuditDataSource {
  const RestAuditDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<AuditLogEntry>> fetchRecent() async {
    final json = await _client.get(ApiRoutes.adminAuditLogs);
    return (json['data'] as List).cast<Map<String, dynamic>>().map(_parseEntry).toList();
  }
}
