/// Environnement d'exécution de l'app — pilote le choix mock ↔ backend réel.
///
/// Sans `--dart-define`, l'app démarre par défaut sur le backend local de développement
/// (`http://192.168.11.124:3000/api/v1`).
enum AppEnvironment { mock, development, staging, production }

/// Configuration résolue à la compilation via `String.fromEnvironment`.
abstract final class AppEnvironmentConfig {
  AppEnvironmentConfig._();

  static const _rawEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://edupay-27-aout.onrender.com',
  );

  static const apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  static const requestTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 20,
  );

  static AppEnvironment get current => switch (_rawEnvironment) {
    'mock' => AppEnvironment.mock,
    'staging' => AppEnvironment.staging,
    'production' => AppEnvironment.production,
    _ => AppEnvironment.development,
  };

  /// `true` seulement si explicitement demandé en mode mock.
  static bool get usesMockData => current == AppEnvironment.mock;

  /// URL de base du backend, préfixe de version inclus (`/api/v1`).
  static String get resolvedApiBaseUrl {
    final baseUrl = _apiBaseUrl.isNotEmpty ? _apiBaseUrl : 'https://edupay-27-aout.onrender.com';
    final root = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(root);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_BASE_URL doit être une URL HTTP(S) valide.');
    }
    final versionSuffix = '/api/$apiVersion';
    return root.endsWith(versionSuffix) ? root : '$root$versionSuffix';
  }
}
