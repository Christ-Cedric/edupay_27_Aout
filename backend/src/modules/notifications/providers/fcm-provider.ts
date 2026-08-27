import { cert, getApps, initializeApp, type App } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { env } from '../../../config/env.js';

/**
 * Canal push, EN PLUS de WhatsApp (jamais à sa place) — même complétude que
 * `ligdicash-provider.ts`/`whatsapp-cloud-provider.ts` : SDK réellement
 * appelé, identifiants lus depuis `env`, échec explicite si absents, jamais
 * un crash. Un seul `App` Firebase pour tout le process (le SDK admin
 * n'autorise qu'une init par nom d'app).
 */

let cachedApp: App | null | undefined; // undefined = pas encore tenté, null = non configuré

function getFirebaseApp(): App | null {
  if (cachedApp !== undefined) return cachedApp;

  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_CLIENT_EMAIL || !env.FIREBASE_PRIVATE_KEY) {
    cachedApp = null;
    return cachedApp;
  }

  const existing = getApps()[0];
  cachedApp =
    existing ??
    initializeApp({
      credential: cert({
        projectId: env.FIREBASE_PROJECT_ID,
        clientEmail: env.FIREBASE_CLIENT_EMAIL,
        // La console Firebase fournit la clé avec des `\n` littéraux (pas de
        // vrais retours à la ligne) une fois collée dans une variable d'env.
        privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      }),
    });
  return cachedApp;
}

export interface PushSendResult {
  success: boolean;
  reason?: string;
  /** Tokens que FCM signale comme invalides/expirés — à supprimer côté appelant. */
  invalidTokens: string[];
}

function isInvalidTokenCode(code: string | undefined): boolean {
  return code === 'messaging/invalid-registration-token' || code === 'messaging/registration-token-not-registered';
}

export const fcmProvider = {
  name: 'fcm',

  async send(tokens: string[], title: string, body: string): Promise<PushSendResult> {
    if (tokens.length === 0) {
      return { success: false, reason: 'Aucun appareil enregistré.', invalidTokens: [] };
    }

    const app = getFirebaseApp();
    if (!app) {
      return { success: false, reason: 'Firebase non configuré (identifiants absents).', invalidTokens: [] };
    }

    try {
      const response = await getMessaging(app).sendEachForMulticast({
        tokens,
        notification: { title, body },
      });

      const invalidTokens: string[] = [];
      response.responses.forEach((r, i) => {
        if (!r.success && isInvalidTokenCode(r.error?.code)) {
          invalidTokens.push(tokens[i]!);
        }
      });

      return {
        success: response.successCount > 0,
        reason: response.successCount === 0 ? 'Aucun envoi réussi.' : undefined,
        invalidTokens,
      };
    } catch (err) {
      return {
        success: false,
        reason: err instanceof Error ? err.message : 'Erreur réseau inconnue.',
        invalidTokens: [],
      };
    }
  },
};
