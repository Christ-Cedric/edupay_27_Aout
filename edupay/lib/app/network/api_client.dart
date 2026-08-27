abstract interface class ApiClient {
  Future<Map<String, dynamic>> get(String path);
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body});
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body});
  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body});
  Future<void> delete(String path, {Map<String, dynamic>? body});
}

/// Transport seam for the future HTTP package/client. It deliberately makes no
/// request until a concrete transport is registered in the composition root.
class UnconfiguredApiClient implements ApiClient {
  const UnconfiguredApiClient();

  Never _unconfigured() => throw UnsupportedError(
    'REST transport is not configured. Provide an ApiClient at application startup.',
  );

  @override
  Future<void> delete(String path, {Map<String, dynamic>? body}) async =>
      _unconfigured();

  @override
  Future<Map<String, dynamic>> get(String path) async => _unconfigured();

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async => _unconfigured();

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async => _unconfigured();

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async => _unconfigured();
}
