import '../storage/secure_storage_service.dart';

/// Conserve les jetons de session (schéma `access` + `refresh` du contrat
/// partagé, §2.2) en mémoire, avec persistance chiffrée via
/// [SecureStorageService] pour survivre à un redémarrage de l'app.
///
/// `registrationToken` n'est pas utilisé côté Admin/Agent (pas d'auto-
/// inscription OTP — voir contrat §2.1) mais reste exposé pour partager le
/// même contrat de transport que l'app Client.
class TokenStore {
  TokenStore(this._storage);

  final SecureStorageService _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  String? _access;
  String? _refresh;

  String? get accessToken => _access;
  String? get refreshToken => _refresh;
  String? registrationToken;

  /// Recharge les jetons persistés au démarrage (avant toute requête).
  Future<void> restore() async {
    _access = await _storage.read(_accessKey);
    _refresh = await _storage.read(_refreshKey);
  }

  Future<void> setSession({
    required String access,
    required String refresh,
  }) async {
    _access = access;
    _refresh = refresh;
    await _storage.write(_accessKey, access);
    await _storage.write(_refreshKey, refresh);
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    registrationToken = null;
    await _storage.delete(_accessKey);
    await _storage.delete(_refreshKey);
  }
}
