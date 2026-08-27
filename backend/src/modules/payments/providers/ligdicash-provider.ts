import { createHmac, timingSafeEqual } from 'node:crypto';
import { env } from '../../../config/env.js';
import { ApiError } from '../../../shared/http/api-error.js';
import type { InitiateParams, InitiateResult, PaymentProvider, WebhookEvent } from './payment-provider.js';

export const ligdiCashProvider: PaymentProvider = {
  name: 'ligdicash',

  async initiate(params: InitiateParams): Promise<InitiateResult> {
    if (!env.LIGDICASH_API_KEY || !env.LIGDICASH_AUTH_TOKEN) {
      if (env.NODE_ENV === 'development' || env.NODE_ENV === 'test') {
        // En développement local : simulation réussie immédiate si aucune clé LigdiCash n'est fournie
        return {
          providerReference: `DEV-MM-${params.reference}`,
          status: 'confirmed', 
        };
      }
      throw ApiError.serviceUnavailable(
        'Paiement mobile money momentanément indisponible (passerelle non configurée).',
      );
    }

    throw ApiError.serviceUnavailable(
      'Intégration LigdiCash non finalisée (identifiants présents mais appel API non implémenté).',
    );
  },

  verifyWebhook(rawBody, headers) {
    if (!env.LIGDICASH_WEBHOOK_SECRET) return false;

    const signatureHeader = headers['x-ligdicash-signature'];
    const signature = Array.isArray(signatureHeader) ? signatureHeader[0] : signatureHeader;
    if (!signature) return false;

    const expected = createHmac('sha256', env.LIGDICASH_WEBHOOK_SECRET).update(rawBody).digest('hex');

    const a = Buffer.from(signature);
    const b = Buffer.from(expected);
    return a.length === b.length && timingSafeEqual(a, b);
  },

  parseWebhook(rawBody): WebhookEvent {
    const body = JSON.parse(rawBody.toString('utf8')) as {
      token: string;
      status: string;
      amount: number;
    };
    return {
      providerReference: body.token,
      status: body.status === 'completed' ? 'confirmed' : 'failed',
      amount: body.amount,
    };
  },
};
