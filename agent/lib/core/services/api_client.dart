// =============================================================================
// CORE/SERVICES/API_CLIENT.DART — Client HTTP centralisé avec auto-refresh
// =============================================================================
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static String get _baseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (customUrl.isNotEmpty) return customUrl;
    return 'https://edupay-27-aout.onrender.com/api/v1';
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Tente de rafraîchir le token et retourne le nouveau access token
  static Future<String?> _tryRefreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return null;
    try {
      final uri = Uri.parse('$_baseUrl/auth/refresh');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        final newAccess = data['access_token'] as String?;
        final newRefresh = data['refresh_token'] as String?;
        if (newAccess != null && newRefresh != null) {
          await TokenStorage.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return newAccess;
        }
      }
    } catch (_) {}
    return null;
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final dynamic decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data')) {
          return decoded;
        }
        return {'data': decoded};
      } else {
        return {'data': decoded};
      }
    }

    // Le backend renvoie { success: false, error: { message: '...' } }
    String message = 'Une erreur est survenue';
    if (decoded is Map) {
      if (decoded.containsKey('error') && decoded['error'] is Map) {
        message = decoded['error']['message'] ?? message;
      } else if (decoded.containsKey('message')) {
        message = decoded['message'].toString();
      }
    }

    throw ApiException(response.statusCode, message);
  }

  /// Exécute une requête avec retry automatique si le token est expiré (401)
  static Future<http.Response> _executeWithRefresh(
    Future<http.Response> Function(Map<String, String> headers) request, {
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    http.Response response = await request(headers);

    // Si token expiré (401), tenter le refresh
    if (response.statusCode == 401 && auth) {
      final newToken = await _tryRefreshToken();
      if (newToken != null) {
        headers['Authorization'] = 'Bearer $newToken';
        response = await request(headers);
      }
    }
    return response;
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _executeWithRefresh(
      (hdrs) => http.get(uri, headers: hdrs),
      auth: auth,
    );
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
    String? idempotencyKey,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final encoded = jsonEncode(body);
    final response = await _executeWithRefresh((hdrs) {
      if (idempotencyKey != null) hdrs['X-Idempotency-Key'] = idempotencyKey;
      return http.post(uri, headers: hdrs, body: encoded);
    }, auth: auth);
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final encoded = jsonEncode(body);
    final response = await _executeWithRefresh(
      (hdrs) => http.patch(uri, headers: hdrs, body: encoded),
    );
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _executeWithRefresh(
      (hdrs) => http.delete(
        uri,
        headers: hdrs,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _parseResponse(response);
  }
}
