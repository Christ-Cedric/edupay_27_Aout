import { env } from '../../../config/env.js';

/**
 * ⚠️ CODÉ MAIS NON APPELÉ — décision produit (2026-07-28) : le canal réel des
 * notifications terrain et de l'OTP client est WhatsApp
 * (`whatsapp-cloud-provider.ts`), pas Africa's Talking, malgré ce que le
 * backend Agent terrain de référence laissait supposer. Ce provider est écrit
 * avec la même complétude (appel HTTP réel, identifiants lus depuis `env`,
 * échec explicite si absents) pour rester prêt si une activation SMS est
 * décidée plus tard — mais rien dans `notifications.service.ts` ni
 * `auth.service.ts` ne l'importe aujourd'hui. Si activé un jour, il ne doit
 * concerner que l'OTP côté client, jamais les notifications agent.
 */

export interface SmsSendResult {
  success: boolean;
  reason?: string;
}

export const africasTalkingProvider = {
  name: 'africas-talking',

  async send(to: string, body: string): Promise<SmsSendResult> {
    if (!env.AFRICAS_TALKING_API_KEY) {
      return { success: false, reason: "Africa's Talking non configuré (clé API absente)." };
    }

    try {
      const apiUrl =
        env.AFRICAS_TALKING_USERNAME === 'sandbox'
          ? 'https://api.sandbox.africastalking.com/version1/messaging'
          : 'https://api.africastalking.com/version1/messaging';

      const params = new URLSearchParams();
      params.append('username', env.AFRICAS_TALKING_USERNAME);
      params.append('to', to.startsWith('+') ? to : `+${to}`);
      params.append('message', body);

      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          apiKey: env.AFRICAS_TALKING_API_KEY,
          'Content-Type': 'application/x-www-form-urlencoded',
          Accept: 'application/json',
        },
        body: params.toString(),
      });

      if (!response.ok) {
        return { success: false, reason: `Erreur HTTP ${response.status}.` };
      }
      return { success: true };
    } catch (err) {
      return { success: false, reason: err instanceof Error ? err.message : 'Erreur réseau inconnue.' };
    }
  },
};
