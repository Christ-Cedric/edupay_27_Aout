import { z } from 'zod';

// Modèle Flutter `Kit` : niveau + fournitures structurées. Le prix total est
// toujours calculé côté serveur (somme des lignes), jamais saisi par
// l'admin — voir `kits.service.ts`.
export const kitLevelEnum = z.enum(['basic', 'intermediate', 'premium']);

// Une fourniture : catégorie libre (le vrai catalogue fournisseur a une
// quinzaine de catégories différentes selon le cycle, pas un petit enum
// fermé), quantité, unité et prix unitaire. Montants en FCFA entiers.
export const kitItemSchema = z.object({
  category: z.string().trim().min(1).max(80),
  label: z.string().trim().min(1).max(120),
  quantity: z.number().int().positive(),
  unit: z.string().trim().min(1).max(40),
  unit_price: z.number().int().nonnegative(),
});

// `level` = variant (basic/intermediate/premium) ; `level_scope` = classe
// ciblée (ex. "CM2") — deux dimensions distinctes (contrat §3.6 : un kit
// cible une classe, avec plusieurs variants selon le budget de la famille).
export const createKitSchema = z.object({
  level: kitLevelEnum,
  level_scope: z.string().trim().min(1),
  items: z.array(kitItemSchema).min(1),
});

// PUT (remplacement complet du kit). Champs optionnels pour tolérer un PATCH,
// mais l'app envoie le kit entier.
export const updateKitSchema = z
  .object({
    level: kitLevelEnum,
    level_scope: z.string().trim().min(1),
    items: z.array(kitItemSchema).min(1),
  })
  .partial();

export type KitItemInput = z.infer<typeof kitItemSchema>;
export type CreateKitInput = z.infer<typeof createKitSchema>;
export type UpdateKitInput = z.infer<typeof updateKitSchema>;

// Import du catalogue fournisseur (fichier Excel encodé en base64 dans un
// corps JSON classique — le fichier est petit, ~280Ko en base64, pas besoin
// d'une pipeline multipart pour ça).
export const importKitsSchema = z.object({
  file_base64: z.string().min(1),
});

export type ImportKitsInput = z.infer<typeof importKitsSchema>;
