enum AppEnvironment { development, staging, production }

/// Compile with `--dart-define=APP_ENV=production` and
/// `--dart-define=API_BASE_URL=https://api.example.com` pour cibler un autre
/// backend. Sans rien préciser, l'app parle au backend local de développement.
class AppEnvironmentConfig {
  const AppEnvironmentConfig._();

  static const _rawEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
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
    'staging' => AppEnvironment.staging,
    'production' => AppEnvironment.production,
    _ => AppEnvironment.development,
  };

  /// URL de base du backend. Si `API_BASE_URL` n'est pas fourni en développement,
  /// on retombe sur `http://localhost:3000` (émulateur Android : utiliser
  /// `--dart-define=API_BASE_URL=http://10.0.2.2:3000`).
  static String get resolvedApiBaseUrl {
    if (apiBaseUrl.isNotEmpty) return apiBaseUrl;
    // Le monolithe expose toutes ses routes sous /api/v1.
    return 'https://edupay-27-aout.onrender.com/api/v1';
  }
}
