import 'dotenv/config';
import { z } from 'zod';

/**
 * Validation stricte des variables d'environnement au démarrage : mieux vaut
 * planter tout de suite qu'à la première requête. Voir `.env.example`.
 */
const schema = z.object({
  NODE_ENV: z
    .enum(['development', 'test', 'staging', 'production'])
    .default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
  JWT_ACCESS_SECRET: z.string().min(16),
  JWT_REFRESH_SECRET: z.string().min(16),
  JWT_ACCESS_TTL: z.string().default('15m'),
  JWT_REFRESH_TTL: z.string().default('30d'),

  // Inscription client par OTP (§2) — secret distinct de JWT_ACCESS_SECRET :
  // un jeton d'inscription ne doit jamais pouvoir être accepté comme un
  // access token même en cas de bug de vérification.
  JWT_SCOPE_SECRET: z.string().min(16),
  JWT_SCOPE_TTL: z.string().default('15m'),
  OTP_TTL_MINUTES: z.coerce.number().int().positive().default(5),
  OTP_MAX_ATTEMPTS: z.coerce.number().int().positive().default(5),
  // Anti-spam par numéro (indépendant du rate-limit par IP, `authLimiter`) :
  // un attaquant avec plusieurs IP pourrait sinon harceler un numéro de SMS
  // OTP à volonté. Un simple cooldown suffit, pas besoin de Redis.
  OTP_RESEND_COOLDOWN_SECONDS: z.coerce.number().int().nonnegative().default(60),
  // true en dev/test uniquement : renvoie le code dans la réponse JSON pour
  // pouvoir tester sans passerelle SMS réelle (jamais en production).
  OTP_DEV_EXPOSE: z
    .string()
    .default('false')
    .transform((v) => v === 'true'),

  SEED_ADMIN_PHONE: z.string().default('+22676691911'),
  SEED_ADMIN_PASSWORD: z.string().default('change-me-admin'),
  SEED_ADMIN_NAME: z.string().default('DERRA Bassirou'),

  // LigdiCash (passerelle mobile money) — optionnelles : tant qu'absentes,
  // le provider reste en mode "non configuré" (503 explicite plutôt qu'un
  // crash), voir `modules/payments/providers/ligdicash-provider.ts`.
  LIGDICASH_API_KEY: z.string().optional(),
  LIGDICASH_AUTH_TOKEN: z.string().optional(),
  LIGDICASH_WEBHOOK_SECRET: z.string().optional(),
  LIGDICASH_BASE_URL: z.string().url().default('https://app.ligdicash.com/pay/v01'),
  PAYMENT_GATEWAY_SANDBOX: z
    .string()
    .optional()
    .transform((v) => v === 'true' || v === '1'),

  // WhatsApp Business Cloud API — canal réel des notifications (reçu,
  // livraison, relance retard, OTP client). Optionnelles : sans elles,
  // `whatsapp-cloud-provider.ts` renvoie un échec explicite (notification
  // marquée `error`), jamais un crash — même pattern que LigdiCash.
  WHATSAPP_API_URL: z.string().url().default('https://graph.facebook.com/v17.0'),
  WHATSAPP_API_TOKEN: z.string().optional(),
  WHATSAPP_PHONE_NUMBER_ID: z.string().optional(),
  // Numéro du directeur pour le rapport agent (lien wa.me) et le contact.
  WHATSAPP_DIRECTOR_NUMBER: z.string().optional(),

  // Africa's Talking (SMS) — implémentée (même complétude que LigdiCash) mais
  // volontairement non appelée par le code d'envoi actuel : réservée à une
  // activation future, et scopée au seul OTP client si un jour activée.
  AFRICAS_TALKING_API_KEY: z.string().optional(),
  AFRICAS_TALKING_USERNAME: z.string().default('sandbox'),

  // Firebase Cloud Messaging (push) — canal réel EN PLUS de WhatsApp (jamais
  // à sa place) pour les notifications déjà câblées. Optionnelles : sans
  // elles, `fcm-provider.ts` renvoie un échec explicite, jamais un crash —
  // même pattern que LigdiCash/WhatsApp. `FIREBASE_PRIVATE_KEY` garde ses
  // `\n` littéraux tels que fournis par la console Firebase (restaurés au
  // moment de l'appel SDK, pas ici).
  FIREBASE_PROJECT_ID: z.string().optional(),
  FIREBASE_CLIENT_EMAIL: z.string().optional(),
  FIREBASE_PRIVATE_KEY: z.string().optional(),
});

const parsed = schema.safeParse(process.env);
if (!parsed.success) {
  // eslint-disable-next-line no-console
  console.error('❌ Variables d\'environnement invalides :', parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;
export const isProd = env.NODE_ENV === 'production';
