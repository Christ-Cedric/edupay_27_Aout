/**
 * Provider Pattern (choix technique confirmé du projet) : chaque passerelle de
 * paiement mobile money implémente ce contrat unique. Le reste du module
 * Paiements (`payments.service.ts`) ne connaît jamais LigdiCash ni aucune
 * autre passerelle directement — il ne dépend que de cette interface.
 */

export interface InitiateParams {
  /** Montant en FCFA (entier, contrat §1). */
  amount: number;
  /** Numéro mobile money du payeur, au format normalisé (+226...). */
  phone: string;
  /** Référence interne EduPay (idempotency key côté passerelle si supportée). */
  reference: string;
}

export interface InitiateResult {
  /** Identifiant de la transaction côté passerelle — sert à recouper le webhook. */
  providerReference: string;
  /**
   * `confirmed` : la passerelle a validé instantanément (cas du cash, qui n'a
   * pas de passerelle externe à proprement parler).
   * `pending` : confirmation asynchrone attendue via webhook (cas normal
   * d'un paiement mobile money réel).
   */
  status: 'confirmed' | 'pending';
  /** URL de redirection / prompt USSD à afficher au payeur, si applicable. */
  redirectUrl?: string;
}

export interface WebhookEvent {
  providerReference: string;
  status: 'confirmed' | 'failed';
  /** Montant rapporté par la passerelle — à recouper avec celui attendu avant de créditer. */
  amount: number;
}

export interface PaymentProvider {
  readonly name: string;

  initiate(params: InitiateParams): Promise<InitiateResult>;

  /**
   * Vérifie l'authenticité du webhook (signature HMAC ou équivalent côté
   * passerelle) AVANT tout traitement. Doit porter sur les octets bruts du
   * corps de requête (`req.rawBody`), jamais sur une resérialisation JSON.
   */
  verifyWebhook(rawBody: Buffer, headers: Record<string, string | string[] | undefined>): boolean;

  /** Interprète le corps du webhook — n'appeler qu'après `verifyWebhook`. */
  parseWebhook(rawBody: Buffer): WebhookEvent;
}
