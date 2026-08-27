import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Fine enveloppe autour de [FlutterSecureStorage] — tout code applicatif
/// passe par ce service plutôt que d'instancier `FlutterSecureStorage`
/// directement, pour garder un seul point de configuration.
class SecureStorageService {
  // Pas besoin d'options Android explicites ici : `flutter_secure_storage`
  // 10.x (voir pubspec) migre automatiquement vers des chiffrements
  // personnalisés côté Android — le souci historique de clé Keystore
  // invalidée (qui déconnectait silencieusement l'utilisateur, corrigé
  // manuellement côté app Client sur une version plus ancienne du package,
  // voir `edupay/token_store.dart`) est déjà géré en interne sur cette version.
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);
}
