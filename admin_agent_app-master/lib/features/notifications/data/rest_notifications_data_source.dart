import '../../../core/network/api_client.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/notification_entry.dart';
import 'notifications_data_source.dart';

NotificationEntry _parseEntry(Map<String, dynamic> json) {
  return NotificationEntry(
    id: json['id'] as String,
    type: json['type'] as String? ?? '',
    title: json['title'] as String? ?? 'Notification',
    body: json['body'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
    readAt: (json['read_at'] as String?) != null
        ? DateTime.tryParse(json['read_at'] as String)
        : null,
  );
}

/// Implémentation backend du seam [NotificationsDataSource] (endpoint
/// `/admin/notifications`).
class RestNotificationsDataSource implements NotificationsDataSource {
  const RestNotificationsDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<NotificationEntry>> fetchRecent() async {
    final json = await _client.get(ApiRoutes.adminNotifications);
    return (json['data'] as List).cast<Map<String, dynamic>>().map(_parseEntry).toList();
  }

  @override
  Future<void> markRead(String id) async {
    await _client.patch(ApiRoutes.notificationRead(id));
  }
}
