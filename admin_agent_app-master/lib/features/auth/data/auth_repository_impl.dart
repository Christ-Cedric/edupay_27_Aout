import 'dart:convert';

import '../../../core/network/token_store.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/models/auth_failure.dart';
import '../domain/models/session.dart';
import '../domain/models/user_role.dart';
import 'auth_data_source.dart';
import 'auth_repository.dart';

const _sessionStorageKey = 'session';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._secureStorage, this._tokens);

  final AuthDataSource _dataSource;
  final SecureStorageService _secureStorage;
  final TokenStore _tokens;

  @override
  Future<Session> login({
    required String phone,
    required String password,
  }) async {
    final record = await _dataSource.checkCredentials(
      phone: phone,
      password: password,
    );
    // Séparation des apps décidée par le client : les comptes agent utilisent
    // exclusivement l'app Agent dédiée, jamais celle-ci (voir suppression du
    // module « Agent terrain » ci-après) — filet de sécurité au même endroit
    // que le rejet des comptes `client` côté REST.
    if (record.role != UserRole.admin) {
      throw const AuthFailure(
        'Ce compte agent doit se connecter depuis l’application Agent dédiée.',
      );
    }
    return _applyRecord(record);
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout(_tokens.refreshToken ?? '');
    await _tokens.clear();
    await _secureStorage.delete(_sessionStorageKey);
  }

  @override
  Future<Session?> restoreSession() async {
    // Recharge les jetons persistés AVANT toute requête HTTP (sinon les
    // premiers appels partiraient sans `Authorization`, forçant un aller-
    // retour de refresh évitable — voire un échec si le refresh a expiré).
    await _tokens.restore();
    final raw = await _secureStorage.read(_sessionStorageKey);
    if (raw == null) return null;
    return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

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
    return _applyRecord(record);
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

  /// Persiste les jetons (transport HTTP) et la session (affichage UI) à
  /// partir d'un [AuthRecord] fraîchement émis (login ou MAJ identifiants).
  Future<Session> _applyRecord(AuthRecord record) async {
    await _tokens.setSession(
      access: record.accessToken,
      refresh: record.refreshToken,
    );
    final session = Session(
      userId: record.userId,
      displayName: record.displayName,
      phone: record.phone,
      role: record.role,
      token: record.accessToken,
    );
    await _secureStorage.write(_sessionStorageKey, jsonEncode(session.toJson()));
    return session;
  }
}
