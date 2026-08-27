import '../domain/models/notification_entry.dart';
import 'notifications_data_source.dart';

/// Source de données en mémoire, seedée avec quelques entrées d'exemple.
/// Mode `mock` du seam [NotificationsDataSource].
class FakeNotificationsDataSource implements NotificationsDataSource {
  final List<NotificationEntry> _entries = [
    NotificationEntry(
      id: 'notif-1',
      type: 'new_registration',
      title: 'Nouvelle inscription',
      body: 'Konaté Aïcha vient de créer un compte et attend une validation.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationEntry(
      id: 'notif-2',
      type: 'delivery_issue',
      title: 'Incident livraison signalé',
      body: 'Traoré Moussa a signalé un problème sur une livraison.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      readAt: DateTime.now().subtract(const Duration(hours: 20)),
    ),
  ];

  @override
  Future<List<NotificationEntry>> fetchRecent() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_entries);
  }

  @override
  Future<void> markRead(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1 || _entries[index].isRead) return;
    _entries[index] = _entries[index].markedRead(DateTime.now());
  }
}
