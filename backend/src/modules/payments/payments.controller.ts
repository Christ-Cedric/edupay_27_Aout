import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { noContent } from '../../shared/http/respond.js';
import { ligdiCashProvider } from './providers/ligdicash-provider.js';
import * as paymentsService from './payments.service.js';

/**
 * Webhook LigdiCash — PAS d'authentification JWT (appelé par la passerelle,
 * pas par un utilisateur EduPay). L'authenticité repose entièrement sur la
 * signature vérifiée ici, sur les octets bruts (`req.rawBody`, capturés par
 * `express.json({ verify })` dans `app.ts`).
 */
export async function ligdiCashWebhookHandler(req: Request, res: Response): Promise<void> {
  if (!req.rawBody || !ligdiCashProvider.verifyWebhook(req.rawBody, req.headers)) {
    throw ApiError.unauthenticated('Signature de webhook invalide.');
  }
  const event = ligdiCashProvider.parseWebhook(req.rawBody);
  await paymentsService.handleLigdiCashWebhookEvent(event.providerReference, event.status);
  noContent(res);
}
