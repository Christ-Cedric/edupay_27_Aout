import { z } from 'zod';

// Profil self-service (nom/ville/quartier) — distinct de `PATCH /auth/me`
// qui gère les identifiants (téléphone/mot de passe).
export const updateProfileSchema = z
  .object({
    full_name: z.string().trim().min(2).max(120),
    city: z.string().trim().min(1).max(80),
    district: z.string().trim().min(2, 'Quartier trop court.'),
  })
  .partial()
  .refine((d) => Object.keys(d).length > 0, {
    message: 'Fournir au moins un champ à mettre à jour.',
  });

export const setTuitionGoalSchema = z.object({
  amount: z.number().int().nonnegative('Le montant doit être positif.'),
});

export const setTransportGoalSchema = z.object({
  amount: z.number().int().nonnegative('Le montant doit être positif.'),
  type: z.string().trim().optional(),
});

export const childIdParamSchema = z.object({
  childId: z.string().min(1),
});

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
