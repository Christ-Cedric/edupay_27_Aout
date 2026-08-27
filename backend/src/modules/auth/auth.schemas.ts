import { z } from 'zod';

export const loginSchema = z.object({
  phone: z.string().min(8),
  password: z.string().min(1),
});

// Inscription client par OTP (§2) — agent/admin gardent phone + mot de passe.
export const requestOtpSchema = z.object({
  phone: z.string().min(8),
});

export const verifyOtpSchema = z.object({
  phone: z.string().min(8),
  code: z.string().regex(/^\d{6}$/, 'Code à 6 chiffres.'),
});

export const registerSchema = z.object({
  full_name: z.string().trim().min(2).max(120),
  password: z.string().min(6),
  city: z.string().trim().min(1).max(80),
  district: z.string().trim().max(80).optional(),
});

export const refreshSchema = z.object({
  refresh_token: z.string().min(1),
});

// Mise à jour du compte courant — écran « Mon compte » (`updateCredentials`) :
// change le téléphone et/ou le mot de passe. Pas de mot de passe actuel exigé
// (l'utilisateur est déjà authentifié). `min(6)` = même règle que l'écran.
export const updateMeSchema = z
  .object({
    new_phone: z.string().trim().min(8).optional(),
    new_password: z.string().min(6).optional(),
  })
  .refine((d) => d.new_phone !== undefined || d.new_password !== undefined, {
    message: 'Fournir au moins le téléphone ou le mot de passe.',
  });

// Mot de passe oublié (§5.2.1) — mêmes schémas que l'OTP d'inscription,
// dupliqués volontairement plutôt que réutilisés : ce sont deux flux
// métier distincts (l'un présuppose un compte existant, l'autre non), les
// faire dériver l'un de l'autre créerait un couplage accidentel.
export const passwordForgotSchema = z.object({
  phone: z.string().min(8),
});

export const passwordResetSchema = z.object({
  password: z.string().min(6),
});

export const passwordChangeSchema = z.object({
  current_password: z.string().min(1),
  new_password: z.string().min(6),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshInput = z.infer<typeof refreshSchema>;
export type UpdateMeInput = z.infer<typeof updateMeSchema>;
export type RequestOtpInput = z.infer<typeof requestOtpSchema>;
export type VerifyOtpInput = z.infer<typeof verifyOtpSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type PasswordForgotInput = z.infer<typeof passwordForgotSchema>;
export type PasswordResetInput = z.infer<typeof passwordResetSchema>;
export type PasswordChangeInput = z.infer<typeof passwordChangeSchema>;
