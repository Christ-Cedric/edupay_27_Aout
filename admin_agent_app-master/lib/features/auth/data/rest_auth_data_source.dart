import '../../../core/network/api_client.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/auth_failure.dart';
import '../domain/models/user_role.dart';
import 'auth_data_source.dart';

UserRole _roleFromApi(String role) => switch (role) {
  'admin' => UserRole.admin,
  'agent' => UserRole.agent,
  // 'client' ne devrait jamais se connecter à l'app Admin/Agent — filet de
  // sécurité plutôt qu'un crash de cast.
  _ => throw const AuthFailure('Ce compte n’a pas accès à l’application Admin.'),
};

AuthRecord _recordFromSession(Map<String, dynamic> json) {
  final user = json['user'] as Map<String, dynamic>;
  return AuthRecord(
    userId: user['id'] as String,
    displayName: user['full_name'] as String,
    phone: user['phone'] as String,
    role: _roleFromApi(user['role'] as String),
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
  );
}

/// Implémentation backend du seam [AuthDataSource] (endpoints `/auth/*`,
/// contrat partagé §2). Pas d'OTP côté Admin/Agent : `login` = numéro +
/// mot de passe (l'admin est seedé, les agents sont créés par l'admin).
class RestAuthDataSource implements AuthDataSource {
  const RestAuthDataSource(this._client);

  final ApiClient _client;

  @override
  Future<AuthRecord> checkCredentials({
    required String phone,
    required String password,
  }) async {
    final json = await _client.post(
      ApiRoutes.login,
      body: {'phone': phone, 'password': password},
    );
    return _recordFromSession(json);
  }

  @override
  Future<void> register({
    required String phone,
    required String displayName,
    required String password,
    required UserRole role,
  }) async {
    // No-op côté REST : `POST /admin/agents` (voir [RestAgentDataSource])
    // provisionne déjà le compte de connexion de l'agent en une seule
    // transaction serveur. Cet appel séparé n'existe que pour le mode mock,
    // où `FakeAgentDataSource` et `FakeAuthDataSource` sont deux magasins
    // indépendants à seeder chacun.
  }

  @override
  Future<AuthRecord> updateCredentials({
    required String currentPhone,
    required String newPhone,
    String? newPassword,
  }) async {
    final json = await _client.patch(
      ApiRoutes.me,
      body: {
        'new_phone': newPhone,
        'new_password': ?newPassword,
      },
    );
    return _recordFromSession(json);
  }

  @override
  Future<void> logout(String refreshToken) async {
    if (refreshToken.isEmpty) return;
    await _client.post(ApiRoutes.logout, body: {'refresh_token': refreshToken});
  }
}
