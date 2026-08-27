import { Router } from 'express';
import swaggerUi from 'swagger-ui-express';
import { buildOpenApiDocument } from './document.js';

// Document généré une fois au démarrage (les schémas ne changent pas à chaud).
const openApiDocument = buildOpenApiDocument();

/** Sert Swagger UI (`/docs`) et le document brut (`/docs.json`). */
export const docsRouter = Router();

docsRouter.get('/docs.json', (_req, res) => {
  res.json(openApiDocument);
});

docsRouter.use(
  '/docs',
  swaggerUi.serve,
  swaggerUi.setup(openApiDocument, {
    customSiteTitle: 'EduPay API — Docs',
    swaggerOptions: { persistAuthorization: true },
  }),
);
