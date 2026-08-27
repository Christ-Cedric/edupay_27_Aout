import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// Enregistrement auprès de `/notifications/device-token` (commun aux 3
/// rôles — voir `notifications.routes.ts`). Best-effort partout : l'absence
/// de push (permission refusée, Firebase indisponible) ne doit jamais
/// empêcher la connexion.
class FcmService {
  FcmService(this._client);

  final ApiClient _client;
  StreamSubscription<String>? _refreshSub;

  String get _platform => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'web',
  };

  /// À appeler juste après une connexion réussie et à la restauration d'une
  /// session existante.
  Future<void> registerCurrentDevice() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _send(token);

      _refreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen(_send);
    } catch (_) {
      // Firebase non configuré/indisponible sur cet appareil : dégrade
      // silencieusement, l'app reste utilisable sans push.
    }
  }

  Future<void> _send(String token) =>
      _client.post('/notifications/device-token', body: {
        'token': token,
        'platform': _platform,
      });

  /// À appeler AVANT de purger la session locale (déconnexion) : le retrait
  /// nécessite encore un token d'accès valide.
  Future<void> unregisterCurrentDevice() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _client.delete('/notifications/device-token', body: {'token': token});
    } catch (_) {
      // Best-effort : une déconnexion ne doit jamais échouer pour ça.
    }
  }
}
