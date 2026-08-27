import { Router } from 'express';
import { authRouter } from './modules/auth/auth.routes.js';
import { adminRouter } from './modules/admin/admin.routes.js';
import { agentRouter } from './modules/agent/agent.routes.js';
import { catalogRouter } from './modules/catalog/catalog.routes.js';
import { notificationsRouter } from './modules/notifications/notifications.routes.js';
import { parentsRouter } from './modules/parents/parents.routes.js';
import { paymentsRouter } from './modules/payments/payments.routes.js';
import { docsRouter } from './shared/openapi/docs.router.js';

// Monté sous /api/v1 (contrat §1). Chaque module ajoute son sous-routeur.
export const apiRouter = Router();

apiRouter.get('/health', (_req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

// Documentation interactive : /api/v1/docs (UI) et /api/v1/docs.json (OpenAPI).
apiRouter.use('/', docsRouter);

apiRouter.use('/auth', authRouter);
apiRouter.use('/admin', adminRouter);
apiRouter.use('/agent', agentRouter);
apiRouter.use('/catalog', catalogRouter);
apiRouter.use('/notifications', notificationsRouter);
apiRouter.use('/parents', parentsRouter);
// Public (pas d'auth JWT) : webhook de la passerelle de paiement.
apiRouter.use('/payments', paymentsRouter);
