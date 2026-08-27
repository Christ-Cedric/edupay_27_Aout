import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/api_routes.dart';

/// Enregistrement du device FCM auprès du backend (`/notifications/device-token`,
/// commun aux 3 rôles — voir `notifications.routes.ts`). Best-effort partout :
/// l'absence de push (permission refusée, Firebase indisponible) ne doit
/// jamais empêcher la connexion ni la navigation dans l'app.
class FcmService {
  FcmService(this._client);

  final ApiClient _client;
  StreamSubscription<String>? _refreshSub;

  String get _platform => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'web',
  };

  /// À appeler juste après une connexion/inscription réussie (et à la
  /// restauration d'une session existante) : demande la permission, récupère
  /// le token FCM et l'enregistre côté serveur.
  Future<void> registerCurrentDevice() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _send(token);

      // Un token peut être renouvelé par le système à tout moment (pas
      // seulement au démarrage) — sans ce listener, l'app finirait par
      // pousser vers un token périmé côté serveur.
      _refreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen(_send);
    } catch (_) {
      // Firebase non configuré/indisponible sur cet appareil : dégrade
      // silencieusement, l'app reste utilisable sans push.
    }
  }

  Future<void> _send(String token) => _client.post(
    ApiRoutes.notificationDeviceToken,
    body: {'token': token, 'platform': _platform},
  );

  /// À appeler avant de purger la session locale (déconnexion) : retire ce
  /// device de la liste d'envoi pour ne plus le pousser une fois déconnecté.
  Future<void> unregisterCurrentDevice() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _client.delete(
        ApiRoutes.notificationDeviceToken,
        body: {'token': token},
      );
    } catch (_) {
      // Best-effort : une déconnexion ne doit jamais échouer pour ça.
    }
  }

  void dispose() {
    _refreshSub?.cancel();
  }
}
