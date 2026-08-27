import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../app/network/api_client.dart';
import '../../../../app/network/api_exception.dart';
import '../../../../app/network/token_store.dart';
import '../../domain/auth_session.dart';

/// Implémentation réseau de [AuthSession] contre le backend EduPay (§5.2).
class HttpAuthSession implements AuthSession {
  HttpAuthSession({
    required this.baseUrl,
    required this.tokens,
    required this.api,
    Duration? timeout,
    http.Client? client,
  }) : _timeout = timeout ?? const Duration(seconds: 20),
       _client = client ?? http.Client();

  final String baseUrl;
  final TokenStore tokens;

  /// Client authentifié (Bearer access + rotation refresh) pour les endpoints
  /// protégés (changement de mot de passe, gestion des sessions).
  final ApiClient api;

  final Duration _timeout;
  final http.Client _client;

  @override
  Future<void> requestOtp(String phone) async {
    // Réponse 200 uniforme ; en dev le code est loggé côté serveur.
    await _post('/auth/otp/request', {'phone': phone});
  }

  @override
  Future<void> requestPasswordReset(String phone) async {
    await _post('/auth/password/forgot', {'phone': phone});
  }

  @override
  Future<void> verifyOtp({required String phone, required String code}) async {
    final data = await _post('/auth/otp/verify', {
      'phone': phone,
      'code': code,
    });
    final regToken = data['registration_token'] as String?;
    final resetToken = data['reset_token'] as String?;
    if (regToken == null && resetToken == null) {
      throw const ApiException(
        statusCode: 500,
        code: 'NO_TOKEN_RECEIVED',
        message: 'Réponse OTP invalide',
      );
    }
    tokens.registrationToken = regToken;
    tokens.resetToken = resetToken;
  }

  @override
  Future<String> register({
    required String fullName,
    required String city,
    required String district,
    required String password,
  }) async {
    final registrationToken = tokens.registrationToken;
    if (registrationToken == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'MISSING_REGISTRATION_TOKEN',
        message: 'Vérifiez d’abord votre numéro par OTP',
      );
    }
    final data = await _post('/auth/register', {
      'full_name': fullName,
      'city': city,
      'district': district,
      'password': password,
    }, bearer: registrationToken);
    return _storeSession(data);
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    final token = tokens.resetToken;
    if (token == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'MISSING_RESET_TOKEN',
        message: 'Vérifiez d’abord votre numéro par OTP',
      );
    }
    final data = await _post('/auth/password/reset', {
      'password': newPassword,
    }, bearer: token);
    // Le reset émet une nouvelle session : elle doit être conservée pour que
    // le compte agent puisse charger ses enfants et ses cotisations.
    await _storeSession(data);
    tokens.resetToken = null;
  }

  @override
  Future<String> login({
    required String phone,
    required String password,
  }) async {
    final data = await _post('/auth/login', {
      'phone': phone,
      'password': password,
    });
    return _storeSession(data);
  }

  @override
  Future<bool> restoreSession() => tokens.restore();

  @override
  void setSessionExpiredListener(void Function() listener) {
    tokens.onSessionExpired = listener;
  }

  @override
  Future<void> signOut() async {
    // Révoque la session côté monolithe avant de purger le stockage local.
    // Une erreur réseau ne doit jamais empêcher l'utilisateur de se
    // déconnecter de son appareil.
    final refresh = tokens.refreshToken;
    if (refresh != null) {
      try {
        await _post('/auth/logout', {'refresh_token': refresh});
      } catch (_) {}
    }
    await tokens.clear();
  }

  @override
  Future<void> changePassword({
    required String current,
    required String next,
  }) async {
    final data = await api.post(
      '/auth/password/change',
      body: {'current_password': current, 'new_password': next},
    );
    // Le backend révoque toutes les sessions et renvoie de NOUVEAUX tokens :
    // on les adopte pour que cet appareil reste connecté.
    await _storeSession(data);
  }

  @override
  Future<List<ActiveSession>> listSessions() async {
    final data = await api.get('/auth/sessions');
    final list = data['data'] as List<dynamic>? ?? const [];
    final sessions = <ActiveSession>[];
    for (var i = 0; i < list.length; i++) {
      final entry = list[i] as Map<String, dynamic>;
      sessions.add(
        ActiveSession(
          id: entry['id'] as String,
          device: entry['device'] as String?,
          ip: entry['ip'] as String?,
          lastUsedAt: _parseDate(entry['last_used_at']),
          createdAt: _parseDate(entry['created_at']),
          // La session en tête (triée par last_used_at desc côté backend) est
          // celle de l'appareil courant.
          isCurrent: i == 0,
        ),
      );
    }
    return sessions;
  }

  @override
  Future<void> revokeSession(String id) => api.delete('/auth/sessions/$id');

  @override
  Future<void> revokeAllSessions() async {
    await api.delete('/auth/sessions');
    // Cet appareil est aussi révoqué : on purge la session locale.
    await tokens.clear();
  }

  DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  Future<String> _storeSession(Map<String, dynamic> data) async {
    await tokens.setSession(
      access: data['access_token'] as String,
      refresh: data['refresh_token'] as String,
    );
    final user = data['user'] as Map<String, dynamic>?;
    return user?['status'] as String? ?? 'active';
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? bearer,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {
            'Content-Type': 'application/json',
            if (bearer != null) 'Authorization': 'Bearer $bearer',
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    final decoded = response.bodyBytes.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : const {};
    }

    final error = decoded is Map<String, dynamic> ? decoded['error'] : null;
    if (error is Map<String, dynamic>) {
      throw ApiException(
        statusCode: response.statusCode,
        code: error['code'] as String? ?? 'ERROR',
        message: error['message'] as String? ?? 'Erreur serveur',
        details: error['details'] as List<dynamic>? ?? const [],
      );
    }
    throw ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_${response.statusCode}',
      message: 'Erreur réseau (${response.statusCode})',
    );
  }
}
