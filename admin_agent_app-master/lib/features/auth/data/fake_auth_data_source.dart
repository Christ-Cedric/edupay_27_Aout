import 'dart:math';

import '../domain/models/auth_failure.dart';
import '../domain/models/user_role.dart';
import 'auth_data_source.dart';

/// Source de données d'authentification en mémoire — mode `mock` du seam
/// [AuthDataSource].
///
/// Seedée avec le compte admin par défaut, disponible dès le premier
/// lancement de l'app (fondateur EduP@y, écran `contact` du prototype).
/// Ce compte n'existe pas dans le prototype (qui ne modélise pas
/// l'authentification Admin/Agent) — mot de passe volontairement simple,
/// à changer via l'écran "Mon compte" avant mise en production.
class FakeAuthDataSource implements AuthDataSource {
  final Map<String, ({String password, AuthRecord record})> _accounts = {
    '+22676691911': (
      password: 'admin123',
      record: AuthRecord(
        userId: 'admin-1',
        displayName: 'DERRA Bassirou',
        phone: '+22676691911',
        role: UserRole.admin,
        accessToken: _randomToken(),
        refreshToken: _randomToken(),
      ),
    ),
  };

  String _normalize(String phone) => phone.replaceAll(RegExp(r'\s+'), '');

  static String _randomToken() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }

  /// Crée un compte de connexion (ex. agent terrain créé par l'admin) avec
  /// le mot de passe défini par l'admin lors de la création.
  @override
  Future<void> register({
    required String phone,
    required String displayName,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final normalized = _normalize(phone);
    if (_accounts.containsKey(normalized)) {
      throw const AuthFailure('Ce numéro de téléphone est déjà utilisé.');
    }
    _accounts[normalized] = (
      password: password,
      record: AuthRecord(
        userId: 'user-${_accounts.length + 1}',
        displayName: displayName,
        phone: normalized,
        role: role,
        accessToken: _randomToken(),
        refreshToken: _randomToken(),
      ),
    );
  }

  @override
  Future<AuthRecord> checkCredentials({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final account = _accounts[_normalize(phone)];
    if (account == null || account.password != password) {
      throw const AuthFailure('Numéro ou mot de passe incorrect.');
    }
    return account.record;
  }

  /// Met à jour le téléphone et/ou le mot de passe du compte courant.
  /// [currentPhone] identifie le compte à modifier ; [newPhone] devient sa
  /// nouvelle clé de connexion (peut être inchangé).
  @override
  Future<AuthRecord> updateCredentials({
    required String currentPhone,
    required String newPhone,
    String? newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final normalizedCurrent = _normalize(currentPhone);
    final normalizedNew = _normalize(newPhone);
    final existing = _accounts[normalizedCurrent];
    if (existing == null) {
      throw const AuthFailure('Compte introuvable.');
    }

    final updatedRecord = AuthRecord(
      userId: existing.record.userId,
      displayName: existing.record.displayName,
      phone: normalizedNew,
      role: existing.record.role,
      accessToken: _randomToken(),
      refreshToken: _randomToken(),
    );

    _accounts.remove(normalizedCurrent);
    _accounts[normalizedNew] = (
      password: newPassword ?? existing.password,
      record: updatedRecord,
    );
    return updatedRecord;
  }

  @override
  Future<void> logout(String refreshToken) async {}
}
