import '../domain/models/user_role.dart';

/// Identité de compte renvoyée par la source d'authentification (indépendante
/// de l'implémentation mock/REST). Porte les jetons (contrat §2.2 : `access`
/// court + `refresh` long) — c'est la source qui les émet (générés localement
/// en mock, renvoyés par le serveur en REST).
class AuthRecord {
  const AuthRecord({
    required this.userId,
    required this.displayName,
    required this.phone,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  final String userId;
  final String displayName;
  final String phone;
  final UserRole role;
  final String accessToken;
  final String refreshToken;
}

/// Contrat de source d'authentification — seam mock ↔ REST.
abstract interface class AuthDataSource {
  Future<AuthRecord> checkCredentials({
    required String phone,
    required String password,
  });

  Future<void> register({
    required String phone,
    required String displayName,
    required String password,
    required UserRole role,
  });

  Future<AuthRecord> updateCredentials({
    required String currentPhone,
    required String newPhone,
    String? newPassword,
  });

  /// Révoque la session côté serveur (no-op en mock).
  Future<void> logout(String refreshToken);
}
