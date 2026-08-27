import { z } from 'zod';

/**
 * Une saison = une année scolaire (contrat §3.7). `delivery_deadline` pilote le
 * calcul des échéances côté épargne, d'où la validation de cohérence des dates.
 */
export const createSeasonSchema = z
  .object({
    label: z.string().trim().min(4).max(20),
    launch_date: z.coerce.date(),
    delivery_deadline: z.coerce.date(),
    enrollment_open: z.boolean().default(true),
    refund_fee: z.number().int().nonnegative().default(500),
  })
  .refine((d) => d.delivery_deadline > d.launch_date, {
    message: 'La date limite de livraison doit être postérieure au lancement.',
    path: ['delivery_deadline'],
  });

// Mise à jour partielle. La cohérence des dates est revalidée en service (elle
// dépend des valeurs existantes non fournies dans la requête).
export const updateSeasonSchema = z
  .object({
    label: z.string().trim().min(4).max(20),
    launch_date: z.coerce.date(),
    delivery_deadline: z.coerce.date(),
    enrollment_open: z.boolean(),
    refund_fee: z.number().int().nonnegative(),
  })
  .partial();

export type CreateSeasonInput = z.infer<typeof createSeasonSchema>;
export type UpdateSeasonInput = z.infer<typeof updateSeasonSchema>;
