import type { RequestHandler } from 'express';
import { ApiError } from '../http/api-error.js';
import { prisma } from '../prisma.js';
import { verifyAccessToken } from '../../modules/auth/jwt.js';

/**
 * Vérifie le `Authorization: Bearer <access_token>`, PUIS revalide le compte en
 * base à chaque requête. Le JWT ne fait qu'attester l'identité ; le rôle, le
 * statut et `mustChangePassword` sont relus depuis la source de vérité pour que
 * la suspension/rejet d'un compte prenne effet immédiatement (et non à
 * l'expiration du token, jusqu'à 15 min plus tard) — critique pour une app qui
 * manipule de l'argent.
 *
 * Renvoie TOKEN_EXPIRED (401) sur jeton expiré pour déclencher la rotation
 * refresh côté client (contrat §2.2).
 */
export const authenticate: RequestHandler = async (req, _res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw ApiError.unauthenticated();
    }

    const token = header.slice('Bearer '.length);
    let userId: string;
    try {
      userId = verifyAccessToken(token).sub;
    } catch (err) {
      if (err instanceof Error && err.name === 'TokenExpiredError') {
        throw ApiError.tokenExpired();
      }
      throw ApiError.unauthenticated('Jeton invalide.');
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, role: true, status: true, mustChangePassword: true },
    });

    // Compte supprimé, ou désactivé depuis l'émission du token → accès refusé
    // sans attendre l'expiration. On aligne la règle sur `login`.
    if (!user) throw ApiError.unauthenticated('Compte introuvable.');
    if (user.status === 'rejected' || user.status === 'suspended') {
      throw ApiError.forbidden('Ce compte est désactivé.');
    }

    req.auth = {
      userId: user.id,
      role: user.role,
      status: user.status,
      mustChangePassword: user.mustChangePassword,
    };
    next();
  } catch (err) {
    next(err);
  }
};
