import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_environment.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'api_client.dart';
import 'dio_api_client.dart';
import 'token_store.dart';

part 'network_providers.g.dart';

/// Environnement courant — exposé en provider pour que chaque repository
/// puisse décider mock vs REST (composition root distribué).
@Riverpod(keepAlive: true)
AppEnvironment appEnvironment(Ref ref) => AppEnvironmentConfig.current;

/// `true` tant qu'on tourne sur les données [FakeDataSource].
@Riverpod(keepAlive: true)
bool usesMockData(Ref ref) =>
    ref.watch(appEnvironmentProvider) == AppEnvironment.mock;

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) =>
    TokenStore(ref.watch(secureStorageServiceProvider));

/// Transport HTTP partagé. En mode mock il n'est jamais construit (aucun
/// `RestDataSource` ne le lit), donc l'app démarre sans backend.
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => DioApiClient(
  baseUrl: AppEnvironmentConfig.resolvedApiBaseUrl,
  tokens: ref.watch(tokenStoreProvider),
  timeout: const Duration(seconds: AppEnvironmentConfig.requestTimeoutSeconds),
);
