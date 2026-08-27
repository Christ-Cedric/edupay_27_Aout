/**
 * Erreur applicative typée → sérialisée au format d'erreur unifié du contrat
 * (§1.1) : `{ error: { code, message, details } }`.
 */
export class ApiError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: string,
    message: string,
    public readonly details: unknown[] = [],
  ) {
    super(message);
    this.name = 'ApiError';
  }

  static badRequest(message: string, details: unknown[] = []): ApiError {
    return new ApiError(400, 'VALIDATION_ERROR', message, details);
  }

  static unauthenticated(message = 'Authentification requise.'): ApiError {
    return new ApiError(401, 'UNAUTHENTICATED', message);
  }

  static tokenExpired(message = 'Session expirée.'): ApiError {
    return new ApiError(401, 'TOKEN_EXPIRED', message);
  }

  static forbidden(message = 'Accès refusé.'): ApiError {
    return new ApiError(403, 'FORBIDDEN', message);
  }

  static accountPending(message = 'Compte en attente de validation.'): ApiError {
    return new ApiError(403, 'ACCOUNT_PENDING_VALIDATION', message);
  }

  static passwordChangeRequired(
    message = 'Vous devez changer votre mot de passe avant de continuer.',
  ): ApiError {
    return new ApiError(403, 'PASSWORD_CHANGE_REQUIRED', message);
  }

  static tooManyRequests(message = 'Trop de tentatives, réessayez plus tard.'): ApiError {
    return new ApiError(429, 'TOO_MANY_REQUESTS', message);
  }

  static notFound(message = 'Ressource introuvable.'): ApiError {
    return new ApiError(404, 'NOT_FOUND', message);
  }

  static conflict(message: string): ApiError {
    return new ApiError(409, 'CONFLICT', message);
  }

  /** Violation d'une règle métier (ex. code OTP invalide, transition de
   * livraison interdite) — la requête est syntaxiquement valide mais l'état
   * actuel ne permet pas l'opération. `code` distingue le cas précis pour le
   * client (ex. `OTP_TOO_MANY_ATTEMPTS`, `DELIVERY_NOT_READY`). */
  static businessRule(code: string, message: string): ApiError {
    return new ApiError(422, code, message);
  }

  static serviceUnavailable(message: string): ApiError {
    return new ApiError(503, 'SERVICE_UNAVAILABLE', message);
  }
}
