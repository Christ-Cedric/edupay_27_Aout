import '../domain/models/notification_entry.dart';

abstract interface class NotificationsRepository {
  Future<List<NotificationEntry>> getRecent();
  Future<void> markRead(String id);
}
