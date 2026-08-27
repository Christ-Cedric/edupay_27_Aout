import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import { ligdiCashWebhookHandler } from './payments.controller.js';

/**
 * Routeur PUBLIC (pas d'`authenticate`) — LigdiCash appelle ce endpoint
 * directement, sans jeton EduPay. L'authenticité est garantie par la
 * vérification de signature dans `ligdiCashWebhookHandler`, pas par un JWT.
 */
export const paymentsRouter = Router();

paymentsRouter.post('/webhooks/ligdicash', asyncHandler(ligdiCashWebhookHandler));
