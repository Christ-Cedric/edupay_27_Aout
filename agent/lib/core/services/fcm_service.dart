// =============================================================================
// CORE/SERVICES/FCM_SERVICE.DART — Enregistrement du device pour le push FCM
// =============================================================================
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// Enregistrement auprès de `/notifications/device-token` (commun aux 3
/// rôles — voir `notifications.routes.ts`). Best-effort partout : l'absence
/// de push (permission refusée, Firebase indisponible) ne doit jamais
/// empêcher la connexion.
class FcmService {
  FcmService._();

  static StreamSubscription<String>? _refreshSub;

  static String get _platform => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'web',
  };

  /// À appeler juste après une connexion réussie et à la restauration d'une
  /// session existante.
  static Future<void> registerCurrentDevice() async {
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

  static Future<void> _send(String token) => ApiClient.post(
        '/notifications/device-token',
        {'token': token, 'platform': _platform},
      );

  /// À appeler AVANT de purger la session locale (déconnexion) : le retrait
  /// nécessite encore un token d'accès valide.
  static Future<void> unregisterCurrentDevice() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await ApiClient.delete('/notifications/device-token', body: {'token': token});
    } catch (_) {
      // Best-effort : une déconnexion ne doit jamais échouer pour ça.
    }
  }
}
