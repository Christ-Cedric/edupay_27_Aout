import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_exception.dart';
import 'api_routes.dart';
import 'token_store.dart';

/// Transport HTTP réel vers le backend EduPay, basé sur Dio.
///
/// Responsabilités (contrat partagé §1–2) :
/// - préfixe les chemins avec la base versionnée ;
/// - attache `Authorization: Bearer <access_token>` quand disponible ;
/// - traduit le format d'erreur unifié §1.1 en [ApiException] ;
/// - sur 401, tente une rotation du refresh token puis rejoue la requête
///   une seule fois.
class DioApiClient implements ApiClient {
  DioApiClient({
    required String baseUrl,
    required this.tokens,
    required Duration timeout,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: timeout,
               receiveTimeout: timeout,
               // On gère nous-mêmes les statuts d'erreur (mapping §1.1).
               validateStatus: (_) => true,
               headers: {'Content-Type': 'application/json'},
             ),
           );

  final Dio _dio;
  final TokenStore tokens;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send('GET', path, query: query);

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
    Map<String, dynamic>? query,
    bool allowRefresh = true,
  }) async {
    final response = await _dispatchSafely(method, path, body, query);

    if (response.statusCode == 401 &&
        allowRefresh &&
        tokens.refreshToken != null) {
      if (await _refresh()) {
        return _send(
          method,
          path,
          body: body,
          query: query,
          allowRefresh: false,
        );
      }
    }

    return _parse(response);
  }

  /// Converts transport failures into an app-level error instead of letting
  /// the login screen mistake a network outage for invalid credentials.
  Future<Response<dynamic>> _dispatchSafely(
    String method,
    String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  ) async {
    try {
      return await _dispatch(method, path, body, query);
    } on DioException catch (error) {
      throw ApiException(
        statusCode: 0,
        code: 'NETWORK_UNREACHABLE',
        message:
            'Impossible de joindre le serveur EduPay. Vérifiez le Wi-Fi, '
            'l’adresse API et que le backend est démarré.',
        details: [if (error.message != null) error.message],
      );
    }
  }

  Future<Response<dynamic>> _dispatch(
    String method,
    String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  ) {
    final options = Options(
      method: method,
      headers: {
        if (tokens.accessToken != null)
          'Authorization': 'Bearer ${tokens.accessToken}',
      },
    );
    return _dio.request<dynamic>(
      path,
      data: body,
      queryParameters: query,
      options: options,
    );
  }

  Map<String, dynamic> _parse(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status >= 200 && status < 300) {
      if (data is Map<String, dynamic>) return data;
      if (data is List) return {'data': data};
      return const {};
    }

    // Format d'erreur unifié §1.1.
    final error = data is Map<String, dynamic> ? data['error'] : null;
    if (error is Map<String, dynamic>) {
      throw ApiException(
        statusCode: status,
        code: error['code'] as String? ?? 'SERVER_ERROR',
        message: error['message'] as String? ?? 'Erreur serveur',
        details: error['details'] as List<dynamic>? ?? const [],
      );
    }
    throw ApiException(
      statusCode: status,
      code: 'HTTP_$status',
      message: 'Erreur réseau ($status)',
    );
  }

  Future<bool> _refresh() async {
    try {
      final response = await _dio.post<dynamic>(
        ApiRoutes.refresh,
        data: {'refresh_token': tokens.refreshToken},
      );
      final status = response.statusCode ?? 0;
      final data = response.data;
      if (status < 200 || status >= 300 || data is! Map<String, dynamic>) {
        await tokens.clear();
        return false;
      }
      await tokens.setSession(
        access: data['access_token'] as String,
        refresh: data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      await tokens.clear();
      return false;
    }
  }
}
