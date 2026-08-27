import '../../features/parent/data/repositories/rest_parent_repository.dart';
import '../../features/parent/data/services/http_auth_session.dart';
import '../../features/parent/data/services/parent_api_service.dart';
import '../../features/parent/domain/auth_session.dart';
import '../../features/parent/domain/parent_repository.dart';
import '../network/http_api_client.dart';
import '../network/token_store.dart';
import '../services/fcm_service.dart';
import 'app_environment.dart';

/// Services applicatifs résolus au démarrage (data + auth), partageant le même
/// [TokenStore] afin que la session ouverte à la connexion serve les appels data.
class AppServices {
  const AppServices({
    required this.parentRepository,
    required this.authSession,
    required this.fcmService,
  });

  final ParentRepository parentRepository;
  final AuthSession authSession;
  final FcmService fcmService;
}

/// Composition root : construit les services REST branchés sur le backend
/// EduPay (voir [AppEnvironmentConfig.resolvedApiBaseUrl]).
class AppDependencies {
  const AppDependencies._();

  static AppServices create() {
    final tokens = TokenStore();
    final baseUrl = AppEnvironmentConfig.resolvedApiBaseUrl;
    final timeout = Duration(
      seconds: AppEnvironmentConfig.requestTimeoutSeconds,
    );
    final client = HttpApiClient(
      baseUrl: baseUrl,
      tokens: tokens,
      timeout: timeout,
    );

    return AppServices(
      parentRepository: RestParentRepository(ParentApiService(client)),
      authSession: HttpAuthSession(
        baseUrl: baseUrl,
        tokens: tokens,
        api: client,
        timeout: timeout,
      ),
      fcmService: FcmService(client),
    );
  }
}
