import { env } from '../../../config/env.js';

/**
 * Canal réellement invoqué par `notifications.service.ts` — reçu de
 * cotisation, objectif atteint, livraison confirmée, relance retard, et OTP
 * client (`auth.service.ts::requestOtp`). Même complétude que
 * `ligdicash-provider.ts` : appel HTTP réel écrit, identifiants lus depuis
 * `env`, échec explicite si absents — jamais un crash silencieux.
 */

export interface WhatsAppSendResult {
  success: boolean;
  messageId?: string;
  reason?: string;
}

interface WhatsAppApiResponse {
  messages?: { id: string }[];
  error?: { message: string };
}

export const whatsAppProvider = {
  name: 'whatsapp-cloud',

  async send(to: string, body: string): Promise<WhatsAppSendResult> {
    if (!env.WHATSAPP_API_TOKEN || !env.WHATSAPP_PHONE_NUMBER_ID) {
      return { success: false, reason: 'WhatsApp non configuré (identifiants absents).' };
    }

    try {
      const response = await fetch(`${env.WHATSAPP_API_URL}/${env.WHATSAPP_PHONE_NUMBER_ID}/messages`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${env.WHATSAPP_API_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          // L'API attend le numéro sans le `+` (contrat E.164 sans préfixe).
          to: to.replace(/^\+/, ''),
          type: 'text',
          text: { body },
        }),
      });

      const data = (await response.json()) as WhatsAppApiResponse;
      if (!response.ok) {
        return { success: false, reason: data.error?.message ?? `Erreur HTTP ${response.status}.` };
      }
      return { success: true, messageId: data.messages?.[0]?.id };
    } catch (err) {
      return { success: false, reason: err instanceof Error ? err.message : 'Erreur réseau inconnue.' };
    }
  },
};
