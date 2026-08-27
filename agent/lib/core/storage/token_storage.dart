// =============================================================================
// CORE/STORAGE/TOKEN_STORAGE.DART — Gestion sécurisée des tokens JWT
// =============================================================================
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // `encryptedSharedPreferences` : sur certains appareils/versions Android, la
  // clé Keystore par défaut peut être invalidée après une mise à jour de
  // l'app ou un redémarrage, ce qui fait échouer silencieusement la lecture
  // des tokens et déconnecte l'utilisateur sans raison apparente (même
  // correctif déjà appliqué côté app Client, voir `edupay/token_store.dart`).
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey = 'edupay_access_token';
  static const _refreshKey = 'edupay_refresh_token';
  static const _userKey = 'edupay_user';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  static Future<void> saveUser(String userJson) =>
      _storage.write(key: _userKey, value: userJson);

  static Future<String?> getUser() => _storage.read(key: _userKey);

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
