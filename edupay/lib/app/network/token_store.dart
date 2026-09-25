import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Détenteur des jetons de session, persistés via le trousseau sécurisé du
/// système (Keychain iOS / Keystore Android) afin qu'un compte reste connecté
/// tant que l'utilisateur ne se déconnecte pas explicitement.
///
/// Seul le refresh token est persisté : l'access token est de courte durée et
/// se régénère automatiquement au premier appel API après redémarrage (voir
/// `HttpApiClient._refresh`).
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // `encryptedSharedPreferences` : stockage plus résistant sur
            // Android (certains appareils/versions invalident sinon la clé
            // Keystore par défaut après une mise à jour de l'app ou un
            // redémarrage, ce qui fait échouer silencieusement la lecture
            // du refresh token et renvoie l'utilisateur à l'écran de
            // connexion alors qu'il était déjà connecté).
            aOptions: AndroidOptions(),
          );

  static const _accessKey = 'edupay_access_token';
  static const _refreshKey = 'edupay_refresh_token';
  // Borne un appel plateforme qui ne répondrait jamais (pas de handler natif
  // enregistré), pour ne pas geler indéfiniment le démarrage de l'app.
  static const _storageTimeout = Duration(seconds: 3);

  final FlutterSecureStorage _storage;

  String? accessToken;
  String? refreshToken;

  /// Jeton court (scope SIGNUP) obtenu après vérification de l'OTP, consommé
  /// par l'étape d'inscription (`/auth/register`). Jamais persisté.
  String? registrationToken;

  /// Jeton court (scope PASSWORD_RESET) obtenu après vérification de l'OTP,
  /// consommé par l'étape de réinitialisation (`/auth/password/reset`). Jamais persisté.
  String? resetToken;

  /// Déclenché quand la session est invalidée hors d'une déconnexion
  /// explicite (refresh token rejeté par le backend), pour que l'UI
  /// redirige l'utilisateur vers l'écran de connexion.
  void Function()? onSessionExpired;

  bool get isAuthenticated => accessToken != null || refreshToken != null;

  /// Recharge les jetons persistés au démarrage de l'app. Retourne
  /// `true` si une session existait déjà (l'utilisateur reste connecté).
  Future<bool> restore() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _accessKey).timeout(_storageTimeout),
        _storage.read(key: _refreshKey).timeout(_storageTimeout),
      ]);
      accessToken = results[0];
      refreshToken = results[1];
    } catch (_) {
      try {
        refreshToken = await _storage
            .read(key: _refreshKey)
            .timeout(_storageTimeout);
      } catch (_) {
        refreshToken = null;
      }
    }
    return refreshToken != null || accessToken != null;
  }

  Future<void> setSession({
    required String access,
    required String refresh,
  }) async {
    accessToken = access;
    refreshToken = refresh;
    registrationToken = null;
    try {
      await Future.wait([
        _storage.write(key: _accessKey, value: access).timeout(_storageTimeout),
        _storage.write(key: _refreshKey, value: refresh).timeout(_storageTimeout),
      ]);
    } catch (_) {
      // La session courante reste utilisable en mémoire ; elle ne survivra
      // simplement pas à un redémarrage si l'écriture échoue.
    }
  }

  /// [expired] : `true` quand l'appelant est le mécanisme de refresh après un
  /// rejet backend (session expirée), par opposition à une déconnexion
  /// volontaire de l'utilisateur — cela déclenche [onSessionExpired].
  Future<void> clear({bool expired = false}) async {
    accessToken = null;
    refreshToken = null;
    registrationToken = null;
    resetToken = null;
    try {
      await Future.wait([
        _storage.delete(key: _accessKey).timeout(_storageTimeout),
        _storage.delete(key: _refreshKey).timeout(_storageTimeout),
      ]);
    } catch (_) {
      // Rien à faire de plus : l'état en mémoire est déjà purgé.
    }
    if (expired) onSessionExpired?.call();
  }
}
