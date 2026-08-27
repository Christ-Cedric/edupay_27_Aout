import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/fcm_providers.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/auth_data_source.dart';
import '../../data/auth_repository.dart';
import '../../data/auth_repository_impl.dart';
import '../../data/fake_auth_data_source.dart';
import '../../data/rest_auth_data_source.dart';
import '../../domain/models/session.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) => SecureStorageService();

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@Riverpod(keepAlive: true)
AuthDataSource authDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeAuthDataSource();
  }
  return RestAuthDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authDataSourceProvider),
    ref.watch(secureStorageServiceProvider),
    ref.watch(tokenStoreProvider),
  );
}

/// État de session global de l'app — piloté par [AuthRepository], consommé
/// par le routeur pour le gating d'authentification.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<Session?> build() async {
    final session = await ref.watch(authRepositoryProvider).restoreSession();
    if (session != null) {
      unawaited(ref.read(fcmServiceProvider).registerCurrentDevice());
    }
    return session;
  }

  Future<void> login({required String phone, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .login(phone: phone, password: password),
    );
    if (state.hasValue && state.value != null) {
      unawaited(ref.read(fcmServiceProvider).registerCurrentDevice());
    }
  }

  Future<void> logout() async {
    // Avant de révoquer la session : le retrait nécessite encore un token
    // valide pour s'authentifier auprès de `/notifications/device-token`.
    await ref.read(fcmServiceProvider).unregisterCurrentDevice();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  /// Modifie les identifiants du compte connecté (écran "Mon compte").
  Future<void> updateCredentials({
    required String newPhone,
    String? newPassword,
  }) async {
    final currentPhone = state.value?.phone;
    if (currentPhone == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .updateCredentials(
            currentPhone: currentPhone,
            newPhone: newPhone,
            newPassword: newPassword,
          ),
    );
  }
}
