// =============================================================================
// CORE/PROVIDERS/AGENT_PROVIDER.DART — État global de l'agent
// =============================================================================
import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../models/livraison_model.dart';
import '../models/notification_model.dart';
import '../services/api_client.dart';

class AgentProvider extends ChangeNotifier {
  // ─── Clients ──────────────────────────────────────────────────────────────
  List<ClientModel> _clients = [];
  bool _isLoadingClients = false;

  // ─── Dashboard ────────────────────────────────────────────────────────────
  Map<String, dynamic>? _dashboard;
  bool _isLoadingDashboard = false;

  // ─── Livraisons ───────────────────────────────────────────────────────────
  List<LivraisonModel> _livraisons = [];
  bool _isLoadingLivraisons = false;

  // ─── Notifications (d'une famille précise, écran fiche client) ────────────
  List<NotificationModel> _notifications = [];
  bool _isLoadingNotifications = false;

  // ─── Notifications (inbox personnelle de l'agent) ─────────────────────────
  List<NotificationModel> _myNotifications = [];
  bool _isLoadingMyNotifications = false;

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<ClientModel> get clients => _clients;
  bool get isLoadingClients => _isLoadingClients;

  Map<String, dynamic>? get dashboard => _dashboard;
  bool get isLoadingDashboard => _isLoadingDashboard;

  List<LivraisonModel> get livraisons => _livraisons;
  bool get isLoadingLivraisons => _isLoadingLivraisons;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoadingNotifications => _isLoadingNotifications;

  List<NotificationModel> get myNotifications => _myNotifications;
  bool get isLoadingMyNotifications => _isLoadingMyNotifications;
  int get unreadMyNotificationsCount =>
      _myNotifications.where((n) => !n.isRead).length;

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> loadClients() async {
    _isLoadingClients = true;
    notifyListeners();
    try {
      final response = await ApiClient.get('/agent/me/families');
      final list = response['data'] as List;
      _clients = list.map((c) => ClientModel.fromJson(c)).toList();
    } catch (e) {
      // Ignore silently — UI affichera un état vide
    } finally {
      _isLoadingClients = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    notifyListeners();
    try {
      final response = await ApiClient.get('/agent/me/dashboard');
      _dashboard = response['data'];
    } catch (e) {
      // Ignore
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> loadLivraisons() async {
    _isLoadingLivraisons = true;
    notifyListeners();
    try {
      // S'assurer que les familles sont chargées pour le croisement de données
      if (_clients.isEmpty) await loadClients();

      final response = await ApiClient.get('/agent/me/deliveries');
      final list = response['data'] as List;
      final deliveries = list.map((l) => LivraisonModel.fromJson(l)).toList();

      // Croiser les livraisons avec les familles pour enrichir l'affichage
      for (final delivery in deliveries) {
        if (delivery.childId == null) continue;
        for (final family in _clients) {
          if (family.children == null) continue;
          final child = family.children!.where((c) => c.id == delivery.childId).firstOrNull;
          if (child != null) {
            delivery.clientFullName  = family.fullName;
            delivery.clientCity      = family.city;
            delivery.childFirstName  = child.firstName;
            delivery.childSchool     = child.school;
            break;
          }
        }
      }

      _livraisons = deliveries;
    } catch (e) {
      // Ignore
    } finally {
      _isLoadingLivraisons = false;
      notifyListeners();
    }
  }

  /// Charge les notifications d'un client spécifique
  Future<void> loadNotifications(String clientId) async {
    _isLoadingNotifications = true;
    notifyListeners();
    try {
      final response = await ApiClient.get('/agent/me/families/$clientId/notifications');
      final list = response['data'] as List;
      _notifications = list.map((n) => NotificationModel.fromJson(n)).toList();
    } catch (e) {
      _notifications = [];
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  /// Inbox personnelle de l'agent (`GET /agent/me/notifications`) — distincte
  /// des notifications d'une famille précise ci-dessus.
  Future<void> loadMyNotifications() async {
    _isLoadingMyNotifications = true;
    notifyListeners();
    try {
      final response = await ApiClient.get('/agent/me/notifications');
      final list = response['data'] as List;
      _myNotifications = list.map((n) => NotificationModel.fromJson(n)).toList();
    } catch (e) {
      _myNotifications = [];
    } finally {
      _isLoadingMyNotifications = false;
      notifyListeners();
    }
  }

  /// Marque une notification de l'inbox personnelle comme lue (optimiste).
  Future<void> markMyNotificationRead(String id) async {
    final index = _myNotifications.indexWhere((n) => n.id == id);
    if (index == -1 || _myNotifications[index].isRead) return;
    final n = _myNotifications[index];
    _myNotifications[index] = NotificationModel(
      id: n.id,
      type: n.type,
      title: n.title,
      body: n.body,
      channel: n.channel,
      createdAt: n.createdAt,
      readAt: DateTime.now(),
      sentAt: n.sentAt,
      pushSentAt: n.pushSentAt,
    );
    notifyListeners();
    try {
      await ApiClient.patch('/notifications/$id/read', {});
    } catch (_) {
      // Best-effort : l'état local reste marqué lu même si la sync échoue.
    }
  }

  /// Réinitialise les notifications (quand on change de client)
  void clearNotifications() {
    _notifications = [];
    notifyListeners();
  }
}
