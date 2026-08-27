import 'package:edupay_admin/features/auth/data/auth_repository.dart';
import 'package:edupay_admin/features/auth/data/fake_auth_data_source.dart';
import 'package:edupay_admin/features/auth/domain/models/session.dart';
import 'package:edupay_admin/features/auth/domain/models/user_role.dart';

/// [AuthRepository] de test : mêmes règles de connexion que
/// [FakeAuthDataSource] (utilisé par le vrai `AuthRepositoryImpl`), mais la
/// session "persistée" vit en mémoire plutôt que dans `flutter_secure_storage`
/// — dont le canal de plateforme n'est pas disponible en environnement de
/// test et bloque indéfiniment (voir plan, stratégie de tests : substituer
/// les repositories par des fakes via `ProviderScope.overrides`).
class FakeSessionAuthRepository implements AuthRepository {
  final _dataSource = FakeAuthDataSource();
  Session? _stored;

  @override
  Future<Session> login({
    required String phone,
    required String password,
  }) async {
    final record = await _dataSource.checkCredentials(
      phone: phone,
      password: password,
    );
    final session = Session(
      userId: record.userId,
      displayName: record.displayName,
      phone: record.phone,
      role: record.role,
      token: record.accessToken,
    );
    _stored = session;
    return session;
  }

  @override
  Future<void> logout() async => _stored = null;

  @override
  Future<Session?> restoreSession() async => _stored;

  @override
  Future<Session> updateCredentials({
    required String currentPhone,
    required String newPhone,
    String? newPassword,
  }) async {
    final record = await _dataSource.updateCredentials(
      currentPhone: currentPhone,
      newPhone: newPhone,
      newPassword: newPassword,
    );
    final session = Session(
      userId: record.userId,
      displayName: record.displayName,
      phone: record.phone,
      role: record.role,
      token: record.accessToken,
    );
    _stored = session;
    return session;
  }

  @override
  Future<void> registerAccount({
    required String phone,
    required String displayName,
    required String password,
    required UserRole role,
  }) {
    return _dataSource.register(
      phone: phone,
      displayName: displayName,
      password: password,
      role: role,
    );
  }
}
