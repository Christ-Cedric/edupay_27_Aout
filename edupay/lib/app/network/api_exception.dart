/// Erreur métier/HTTP renvoyée par le backend au format §8.4 :
/// `{ "success": false, "error": { "code", "message", "details" } }`.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const [],
  });

  final int statusCode;
  final String code;
  final String message;
  final List<dynamic> details;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
