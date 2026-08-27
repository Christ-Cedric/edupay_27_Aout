import { z } from 'zod';

// Aperçu de faisabilité (§4.4.4 chez la référence Client) : le parent teste
// un kit hypothétique pour un nouvel enfant, sans rien écrire.
export const previewChildSchema = z.object({
  kit_id: z.string().min(1),
});

// Confirme le plan — la fréquence est optionnelle : si absente, celle déjà
// choisie (ou `weekly` par défaut pour un tout premier appel) est conservée.
export const confirmSubscriptionSchema = z.object({
  frequency: z.enum(['daily', 'weekly', 'monthly']).optional(),
  // Signature manuscrite (base64) du contrat — même contrainte que
  // `delivery.schemas.ts::confirmReceiptSchema`.
  signature: z.string().min(1).max(500_000).optional(),
});

export type PreviewChildInput = z.infer<typeof previewChildSchema>;
export type ConfirmSubscriptionInput = z.infer<typeof confirmSubscriptionSchema>;
