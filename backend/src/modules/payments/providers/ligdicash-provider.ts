import { createHmac, timingSafeEqual } from 'node:crypto';
import { env } from '../../../config/env.js';
import { ApiError } from '../../../shared/http/api-error.js';
import type { InitiateParams, InitiateResult, PaymentProvider, WebhookEvent } from './payment-provider.js';
import { getGatewayConfig } from '../payment-gateway.service.js';

export const ligdiCashProvider: PaymentProvider = {
  name: 'ligdicash',

  async initiate(params: InitiateParams): Promise<InitiateResult> {
    const config = await getGatewayConfig('ligdicash');

    const apiKey = config?.apiKey || env.LIGDICASH_API_KEY;
    const authToken = config?.authToken || env.LIGDICASH_AUTH_TOKEN;
    const baseUrl = config?.baseUrl || env.LIGDICASH_BASE_URL || 'https://app.ligdicash.com/pay/v01';
    const isSandbox = config?.isSandbox ?? (env.PAYMENT_GATEWAY_SANDBOX || env.NODE_ENV !== 'production' || !apiKey);

    // Mode simulation / Sandbox ou USSD direct (sans passerelle externe requise)
    if (isSandbox || !apiKey || !authToken) {
      return {
        providerReference: `USSD-${params.reference}`,
        status: 'confirmed',
        redirectUrl: `https://edupay.bf/pay/ussd?ref=${params.reference}`,
      };
    }

    // Mode Production réel avec identifiants : appel HTTP réel à l'API LigdiCash
    try {
      const endpoint = `${baseUrl.replace(/\/+$/, '')}/redirect/checkout-invoice/create`;
      const payload = {
        commande: {
          invoice: {
            items: [
              {
                name: 'Cotisation EduPay',
                description: `Paiement cotisation pour ${params.phone}`,
                quantity: 1,
                unit_price: params.amount,
                total_price: params.amount,
              },
            ],
            total_amount: params.amount,
            devise: 'XOF',
            description: `Cotisation EduPay ${params.reference}`,
            customer: '',
            customer_firstname: '',
            customer_lastname: '',
            customer_email: '',
            external_id: params.reference,
            otp: '',
          },
          store: {
            name: 'EduPay',
            website_url: 'https://edupay.bf',
          },
          actions: {
            cancel_url: 'https://edupay.bf/payment/cancel',
            return_url: 'https://edupay.bf/payment/success',
            callback_url: `${baseUrl.includes('localhost') ? 'http://localhost:3000' : 'https://api.edupay.bf'}/api/v1/payments/webhooks/ligdicash`,
          },
          custom_data: {
            reference: params.reference,
            phone: params.phone,
          },
        },
      };

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          Apikey: apiKey,
          Authorization: `Bearer ${authToken}`,
          'Content-Type': 'application/json',
          Accept: 'application/json',
        },
        body: JSON.stringify(payload),
      });

      const responseData = (await response.json()) as any;

      if (!response.ok || (responseData.response_code && responseData.response_code !== '00')) {
        const errorMsg =
          responseData.description ||
          responseData.response_text ||
          `Erreur passerelle LigdiCash (HTTP ${response.status})`;
        throw ApiError.serviceUnavailable(`Échec de la transaction LigdiCash : ${errorMsg}`);
      }

      return {
        providerReference: responseData.token || `LIGDI-${params.reference}`,
        status: 'pending',
        redirectUrl: responseData.response_text || responseData.payment_url,
      };
    } catch (error) {
      if (error instanceof ApiError) throw error;
      throw ApiError.serviceUnavailable(`Erreur de connexion avec la passerelle LigdiCash : ${(error as Error).message}`);
    }
  },

  verifyWebhook(rawBody, headers) {
    const secret = env.LIGDICASH_WEBHOOK_SECRET;
    if (!secret) return true; // Si aucun secret configuré, accepter pour compatibilité sandbox

    const signatureHeader = headers['x-ligdicash-signature'];
    const signature = Array.isArray(signatureHeader) ? signatureHeader[0] : signatureHeader;
    if (!signature) return false;

    const expected = createHmac('sha256', secret).update(rawBody).digest('hex');

    const a = Buffer.from(signature);
    const b = Buffer.from(expected);
    return a.length === b.length && timingSafeEqual(a, b);
  },

  parseWebhook(rawBody): WebhookEvent {
    const body = JSON.parse(rawBody.toString('utf8')) as {
      token?: string;
      provider_reference?: string;
      status?: string;
      amount?: number;
    };
    return {
      providerReference: body.token || body.provider_reference || '',
      status: body.status === 'completed' || body.status === 'confirmed' ? 'confirmed' : 'failed',
      amount: Number(body.amount) || 0,
    };
  },
};
