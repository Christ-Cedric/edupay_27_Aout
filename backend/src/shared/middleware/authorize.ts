import type { RequestHandler } from 'express';
import type { UserRole } from '@prisma/client';
import { ApiError } from '../http/api-error.js';

/**
 * Restreint une route à certains rôles. À monter APRÈS `authenticate`.
 * Exemple : `router.use(authenticate, authorize('admin'))`.
 */
export function authorize(...roles: UserRole[]): RequestHandler {
  return (req, _res, next) => {
    if (!req.auth) throw ApiError.unauthenticated();
    if (!roles.includes(req.auth.role)) throw ApiError.forbidden();
    next();
  };
}
