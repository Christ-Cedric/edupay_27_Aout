/// Notification in-app réelle (`GET /admin/notifications`) — titre/corps déjà
/// rédigés côté backend (français, prêts à l'affichage). `type` sert
/// uniquement à choisir une icône côté client (voir
/// `notifications.service.ts::NotificationType`).
class NotificationEntry {
  const NotificationEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  NotificationEntry markedRead(DateTime at) => NotificationEntry(
    id: id,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    readAt: at,
  );
}
