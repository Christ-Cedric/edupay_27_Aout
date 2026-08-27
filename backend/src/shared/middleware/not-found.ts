import type { RequestHandler } from 'express';
import { ApiError } from '../http/api-error.js';

/** Route inconnue → 404 au format unifié (via le middleware d'erreur). */
export const notFound: RequestHandler = (req, _res, next) => {
  next(ApiError.notFound(`Route inconnue : ${req.method} ${req.originalUrl}`));
};
