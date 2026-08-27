import { z } from 'zod';

// Catalogue de fournitures réutilisable — mêmes contraintes que
// `kitItemSchema` (kits.schemas.ts), catégorie libre (une quinzaine de
// catégories réelles selon le cycle, pas un enum fermé).
export const createSupplySchema = z.object({
  category: z.string().trim().min(1).max(80),
  label: z.string().trim().min(1).max(120),
  unit: z.string().trim().min(1).max(40),
  unit_price: z.number().int().nonnegative(),
});

export const updateSupplySchema = createSupplySchema.partial();

export type CreateSupplyInput = z.infer<typeof createSupplySchema>;
export type UpdateSupplyInput = z.infer<typeof updateSupplySchema>;
