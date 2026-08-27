import type { RequestHandler } from 'express';
import { ApiError } from '../http/api-error.js';

/**
 * Bloque toute action métier tant que l'utilisateur n'a pas remplacé son mot de
 * passe provisoire (agents créés par l'admin, contrat §2.1). À monter APRÈS
 * `authenticate`, et JAMAIS sur `/auth/change-password`, `/auth/me`,
 * `/auth/logout` — sinon l'utilisateur serait enfermé.
 */
export const requirePasswordChanged: RequestHandler = (req, _res, next) => {
  if (!req.auth) throw ApiError.unauthenticated();
  if (req.auth.mustChangePassword) throw ApiError.passwordChangeRequired();
  next();
};
