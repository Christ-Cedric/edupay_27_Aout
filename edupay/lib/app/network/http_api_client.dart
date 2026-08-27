import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// Transport HTTP réel vers le backend EduPay.
///
/// - préfixe les chemins avec [baseUrl] ;
/// - attache `Authorization: Bearer <access_token>` quand disponible ;
/// - traduit le format d'erreur §8.4 en [ApiException] ;
/// - tente une rotation du refresh token sur 401, puis rejoue la requête une fois.
class HttpApiClient implements ApiClient {
  HttpApiClient({
    required this.baseUrl,
    required this.tokens,
    Duration? timeout,
    http.Client? client,
  }) : _timeout = timeout ?? const Duration(seconds: 20),
       _client = client ?? http.Client();

  final String baseUrl;
  final TokenStore tokens;
  final Duration _timeout;
  final http.Client _client;

  @override
  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) => _send('POST', path, body: body);

  @override
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) =>
      _send('PUT', path, body: body);

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) => _send('PATCH', path, body: body);

  @override
  Future<void> delete(String path, {Map<String, dynamic>? body}) =>
      _send('DELETE', path, body: body);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool allowRefresh = true,
  }) async {
    final response = await _dispatch(method, path, body);

    // Session expirée : on tente une rotation puis on rejoue une seule fois.
    if (response.statusCode == 401 &&
        allowRefresh &&
        tokens.refreshToken != null) {
      if (await _refresh()) {
        return _send(method, path, body: body, allowRefresh: false);
      }
    }

    return _parse(response);
  }

  Future<http.Response> _dispatch(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (tokens.accessToken != null)
        'Authorization': 'Bearer ${tokens.accessToken}',
    };
    final payload = body == null ? null : jsonEncode(body);

    final request = switch (method) {
      'GET' => _client.get(uri, headers: headers),
      'POST' => _client.post(uri, headers: headers, body: payload),
      'PUT' => _client.put(uri, headers: headers, body: payload),
      'PATCH' => _client.patch(uri, headers: headers, body: payload),
      'DELETE' => _client.delete(uri, headers: headers, body: payload),
      _ => throw ArgumentError('Méthode non supportée: $method'),
    };
    return request.timeout(_timeout);
  }

  Map<String, dynamic> _parse(http.Response response) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final decoded = _decode(response);

    if (isSuccess) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
      return const {};
    }

    // Format d'erreur unifié §8.4.
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

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<bool> _refresh() async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': tokens.refreshToken}),
          )
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await tokens.clear(expired: true);
        return false;
      }
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      await tokens.setSession(
        access: data['access_token'] as String,
        refresh: data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      await tokens.clear(expired: true);
      return false;
    }
  }
}
