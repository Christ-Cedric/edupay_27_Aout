import type { UserRole, UserStatus } from '@prisma/client';

// Contexte d'authentification attaché par le middleware `authenticate`.
declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      auth?: {
        userId: string;
        role: UserRole;
        status: UserStatus;
        mustChangePassword: boolean;
      };
      /** Octets bruts du corps de requête, capturés par `express.json({ verify })`
       * — nécessaire pour vérifier la signature HMAC des webhooks (LigdiCash),
       * qui porte sur les octets exacts reçus, pas sur le JSON re-sérialisé. */
      rawBody?: Buffer;
    }
  }
}

export {};
