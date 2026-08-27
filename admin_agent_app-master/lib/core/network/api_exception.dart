/// Erreur d'API normalisée, issue du format d'erreur unifié du contrat
/// partagé (`docs/SHARED_API_CONTRACT.md`, §1.1) :
///
/// ```json
/// { "error": { "code": "...", "message": "...", "details": [...] } }
/// ```
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

  bool get isPendingValidation => code == 'ACCOUNT_PENDING_VALIDATION';

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
