/// Configuration réseau de l'app agent, résolue à la compilation.
abstract final class AppEnvironmentConfig {
  AppEnvironmentConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.68:3000',
  );

  static String get resolvedApiBaseUrl => '$apiBaseUrl/api/v1';
}
