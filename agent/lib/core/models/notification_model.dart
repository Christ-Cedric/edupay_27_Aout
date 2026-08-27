// =============================================================================
// CORE/MODELS/NOTIFICATION_MODEL.DART — Modèle de notification client
// =============================================================================

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String channel;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? sentAt;
  final DateTime? pushSentAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.channel,
    required this.createdAt,
    this.readAt,
    this.sentAt,
    this.pushSentAt,
  });

  bool get isRead => readAt != null;

  /// Envoyée avec succès sur au moins un canal externe (WhatsApp ou push) —
  /// la persistance in-app, elle, réussit toujours (voir
  /// `notifications.service.ts::notify`).
  bool get isSent => sentAt != null || pushSentAt != null;

  /// Émoji selon le type réel de notification (voir
  /// `notifications.service.ts::NotificationType`).
  String get icon => switch (type) {
    'contribution_received' || 'goal_completed' => '🎉',
    'contribution_failed' => '⚠️',
    'delivery_confirmed' => '📦',
    'delivery_issue' => '⚠️',
    'late_reminder' => '⏰',
    'account_approved' => '✅',
    'account_rejected' => '⛔',
    'agent_assigned' || 'family_assigned_to_agent' => '🧑‍💼',
    'refund_processed' => '💰',
    'family_archived' => '📁',
    'new_registration' => '👋',
    _ => '🔔',
  };

  /// Titre déjà rédigé côté backend (français, prêt à l'affichage).
  String get shortLabel => title;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());
    return NotificationModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification',
      body: json['body'] as String? ?? '',
      channel: json['channel'] as String? ?? 'whatsapp',
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      readAt: parseDate(json['read_at']),
      sentAt: parseDate(json['sent_at']),
      pushSentAt: parseDate(json['push_sent_at']),
    );
  }
}
