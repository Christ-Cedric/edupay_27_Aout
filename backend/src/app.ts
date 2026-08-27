import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { pinoHttp } from 'pino-http';
import { apiRouter } from './routes.js';
import { logger } from './shared/logger.js';
import { errorHandler } from './shared/middleware/error-handler.js';
import { notFound } from './shared/middleware/not-found.js';
import { isProd } from './config/env.js';

export function createApp() {
  const app = express();

  // Derrière un reverse-proxy (Render/AWS) un seul hop : permet au rate-limiter
  // de lire la vraie IP via X-Forwarded-For. Désactivé en dev (pas de proxy)
  // pour éviter tout spoofing d'IP.
  if (isProd) app.set('trust proxy', 1);

  app.use(helmet());
  app.use(cors());
  // `verify` capture les octets bruts avant parsing JSON : la vérification de
  // signature HMAC des webhooks (LigdiCash) porte sur ces octets exacts, pas
  // sur une resérialisation qui pourrait différer (ordre des clés, espaces).
  app.use(
    express.json({
      // Le défaut (100kb) est trop bas pour l'import du catalogue de kits
      // (fichier Excel encodé en base64 dans le corps JSON, ~280Ko).
      limit: '10mb',
      verify: (req, _res, buf) => {
        (req as express.Request).rawBody = buf;
      },
    }),
  );
  app.use(pinoHttp({ logger }));

  app.use('/api/v1', apiRouter);
  
  app.use(notFound);
  app.use(errorHandler);

  return app;
}
