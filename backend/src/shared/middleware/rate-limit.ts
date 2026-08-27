import rateLimit from 'express-rate-limit';
import { ApiError } from '../http/api-error.js';
import { isProd } from '../../config/env.js';

/**
 * Limiteur pour les routes d'authentification : freine le brute-force sur les
 * mots de passe / jetons. Clé = IP. En dev on est permissif pour ne pas gêner
 * les tests ; en prod la fenêtre est stricte.
 *
 * NB : passe par notre gestionnaire d'erreurs → réponse au format §1.1 (429).
 */
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  limit: isProd ? 10 : 100,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(ApiError.tooManyRequests());
  },
});
