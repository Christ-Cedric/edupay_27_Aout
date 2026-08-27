import type { ErrorRequestHandler } from 'express';
import { ZodError } from 'zod';
import { ApiError } from '../http/api-error.js';
import { logger } from '../logger.js';

/**
 * Middleware d'erreur terminal — traduit toute erreur en format unifié §1.1.
 * À monter en dernier, après les routes.
 */
export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof ApiError) {
    res.status(err.statusCode).json({
      error: { code: err.code, message: err.message, details: err.details },
    });
    return;
  }

  if (err instanceof ZodError) {
    res.status(400).json({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Données invalides.',
        details: err.issues.map((i) => ({
          field: i.path.join('.'),
          issue: i.message,
        })),
      },
    });
    return;
  }

  logger.error({ err }, 'Erreur non gérée');
  res.status(500).json({
    error: { code: 'SERVER_ERROR', message: 'Erreur serveur.', details: [] },
  });
};
