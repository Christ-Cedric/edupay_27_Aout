import type { PaymentProvider } from './payment-provider.js';

/**
 * Cotisation collectée en espèces (par un agent terrain ou, en attendant que
 * ce module soit construit, saisie directement par l'admin). Pas de
 * passerelle externe : la confirmation est immédiate, il n'y aura jamais de
 * webhook pour ce provider.
 */
export const cashProvider: PaymentProvider = {
  name: 'cash_agent',

  async initiate({ reference }) {
    return { providerReference: `CASH-${reference}`, status: 'confirmed' };
  },

  verifyWebhook() {
    throw new Error('cash_agent ne reçoit jamais de webhook.');
  },

  parseWebhook() {
    throw new Error('cash_agent ne reçoit jamais de webhook.');
  },
};
