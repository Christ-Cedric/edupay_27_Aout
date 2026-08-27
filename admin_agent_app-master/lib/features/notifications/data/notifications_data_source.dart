import '../domain/models/notification_entry.dart';

/// Contrat de source de données de l'inbox admin — seam mock ↔ REST.
abstract interface class NotificationsDataSource {
  Future<List<NotificationEntry>> fetchRecent();
  Future<void> markRead(String id);
}
