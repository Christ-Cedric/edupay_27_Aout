import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { createHash, randomInt } from 'node:crypto';
import type { User } from '@prisma/client';
import { env, isProd } from '../../config/env.js';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { normalizePhone } from '../../shared/util/phone.js';
import { whatsAppProvider } from '../notifications/providers/whatsapp-cloud-provider.js';
import * as notificationsService from '../notifications/notifications.service.js';
import { toUserDto } from './auth.serializer.js';
import {
  signAccessToken,
  signRefreshToken,
  signScopeToken,
  verifyRefreshToken,
  verifyScopeToken,
} from './jwt.js';
import type { RegisterInput } from './auth.schemas.js';

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export interface DeviceMeta {
  ip?: string;
  userAgent?: string;
}

/** Signe la paire access/refresh et persiste le hash du refresh (rotation) —
 * étape commune à `issueSession` (nouvelle session) et `refresh` (rotation
 * d'une session existante), qui divergent ensuite sur ce qu'ils font de
 * `Session` (créer vs mettre à jour en place). */
async function createTokenPair(user: User) {
  const accessToken = signAccessToken({
    sub: user.id,
    role: user.role,
    status: user.status,
  });
  const refreshToken = signRefreshToken(user.id);
  const decoded = jwt.decode(refreshToken) as { exp: number };

  const refreshTokenRow = await prisma.refreshToken.create({
    data: {
      userId: user.id,
      tokenHash: hashToken(refreshToken),
      expiresAt: new Date(decoded.exp * 1000),
    },
  });

  return { accessToken, refreshToken, refreshTokenRow };
}

/** Émet une nouvelle session (nouvel appareil/contexte — login, inscription,
 * reset ou changement de mot de passe) : nouveau refresh token ET nouvelle
 * ligne `Session` (écran « Sessions actives »). */
export async function issueSession(user: User, deviceMeta?: DeviceMeta) {
  const { accessToken, refreshToken, refreshTokenRow } = await createTokenPair(user);

  await prisma.session.create({
    data: {
      userId: user.id,
      refreshTokenId: refreshTokenRow.id,
      ipAddress: deviceMeta?.ip ?? null,
      userAgent: deviceMeta?.userAgent ?? null,
    },
  });

  return {
    access_token: accessToken,
    refresh_token: refreshToken,
    user: toUserDto(user),
  };
}

/**
 * Inscription client par OTP (§2, mise à jour) — agent/admin restent en
 * téléphone + mot de passe, provisionnés par l'admin ; ce flux ne concerne
 * QUE le rôle `client` (app parent).
 */

function generateOtpCode(): string {
  return randomInt(0, 1_000_000).toString().padStart(6, '0');
}

/**
 * Refuse explicitement d'envoyer un OTP d'inscription si le numéro est déjà
 * associé à un compte (décision produit du 2026-08-06 — un même numéro ne
 * doit jamais pouvoir servir à créer plusieurs comptes, quitte à révéler son
 * existence ; ceci remplace l'ancienne réponse 200 uniforme "anti-énumération"
 * qui laissait `register()` être le seul point de blocage).
 */
export async function requestOtp(rawPhone: string): Promise<{ dev_code?: string }> {
  const phone = normalizePhone(rawPhone);

  const existingUser = await prisma.user.findUnique({ where: { phone } });
  if (existingUser) {
    throw ApiError.conflict('Ce numéro est déjà associé à un compte.');
  }

  // Anti-spam par numéro : indépendant du rate-limit par IP (`authLimiter`),
  // qui ne protège pas un numéro ciblé depuis plusieurs IP (coût SMS réel /
  // harcèlement). Renvoie 200 (pas d'erreur) pour ne pas révéler l'existence
  // d'une demande récente à un tiers — juste un nouveau code non régénéré.
  const recent = await prisma.otpCode.findFirst({
    where: {
      phone,
      purpose: 'signup',
      createdAt: { gt: new Date(Date.now() - env.OTP_RESEND_COOLDOWN_SECONDS * 1000) },
    },
    orderBy: { createdAt: 'desc' },
  });
  if (recent) return {};

  const code = generateOtpCode();

  await prisma.otpCode.create({
    data: {
      phone,
      purpose: 'signup',
      codeHash: hashToken(code),
      expiresAt: new Date(Date.now() + env.OTP_TTL_MINUTES * 60_000),
    },
  });

  // eslint-disable-next-line no-console
  console.log(`[OTP] ${phone} → ${code} (valide ${env.OTP_TTL_MINUTES} min)`);

  // Envoi réel best-effort via WhatsApp (canal fonctionnel — voir
  // `whatsapp-cloud-provider.ts`) : fire-and-forget, ne bloque jamais la
  // réponse. Sans identifiants configurés, échoue silencieusement ; `dev_code`
  // reste le filet de secours pour tester sans compte WhatsApp Business.
  whatsAppProvider
    .send(phone, `Votre code de vérification EduPay : ${code} (valide ${env.OTP_TTL_MINUTES} min).`)
    .catch(() => {});

  return env.OTP_DEV_EXPOSE && !isProd ? { dev_code: code } : {};
}

/**
 * Vérifie un OTP — une seule route pour les deux flux (inscription ET reset
 * de mot de passe, comme chez la référence Client) : le type de jeton
 * renvoyé dépend du `purpose` du code TROUVÉ PAR CORRESPONDANCE, jamais du
 * simple "plus récent" (audit 2026-07-28 : prendre le plus récent sans
 * comparer le code permettait à quiconque de masquer le reset OTP d'un
 * tiers en redemandant un OTP d'inscription pour son numéro juste après —
 * `/otp/request` n'exige aucune preuve de propriété du compte, contrairement
 * à `/password/forgot` qui, lui, exige un compte existant. Chercher par
 * correspondance de code élimine cette ambiguïté : peu importe combien
 * d'autres codes ont été générés entre-temps pour ce numéro, le bon code
 * retrouve toujours la bonne demande).
 */
export async function verifyOtp(
  rawPhone: string,
  code: string,
): Promise<{ registration_token: string } | { reset_token: string }> {
  const phone = normalizePhone(rawPhone);

  const candidates = await prisma.otpCode.findMany({
    where: { phone, consumedAt: null, expiresAt: { gt: new Date() } },
    orderBy: { createdAt: 'desc' },
  });
  if (candidates.length === 0) {
    throw ApiError.businessRule('OTP_INVALID', 'Code invalide ou expiré.');
  }

  const codeHash = hashToken(code);
  const match = candidates.find((c) => c.codeHash === codeHash);

  if (!match) {
    // Compte la tentative ratée sur le code le plus récent (anti-bruteforce)
    // même si aucun candidat ne correspond — sinon un attaquant pourrait
    // sonder sans jamais faire progresser aucun compteur.
    const mostRecent = candidates[0]!;
    if (mostRecent.attempts < env.OTP_MAX_ATTEMPTS) {
      await prisma.otpCode.update({ where: { id: mostRecent.id }, data: { attempts: { increment: 1 } } });
    }
    throw ApiError.businessRule('OTP_INVALID', 'Code invalide ou expiré.');
  }

  if (match.attempts >= env.OTP_MAX_ATTEMPTS) {
    throw ApiError.businessRule('OTP_TOO_MANY_ATTEMPTS', 'Trop de tentatives, demandez un nouveau code.');
  }

  await prisma.otpCode.update({ where: { id: match.id }, data: { consumedAt: new Date() } });

  if (match.purpose === 'passwordReset') {
    return { reset_token: signScopeToken({ phone, purpose: 'password_reset' }) };
  }
  return { registration_token: signScopeToken({ phone, purpose: 'signup' }) };
}

/**
 * Crée le compte client. Le téléphone vient UNIQUEMENT du jeton d'inscription
 * vérifié, jamais du corps de la requête — un client ne peut pas s'inscrire
 * avec un numéro qu'il n'a pas prouvé posséder. `status` reste
 * `pendingValidation` (défaut du schéma) : l'admin doit approuver le compte,
 * même règle que l'inscription faite par un agent (contrat de validation
 * existant, non changé par ce flux).
 */
export async function register(registrationToken: string, input: RegisterInput, deviceMeta?: DeviceMeta) {
  let phone: string;
  try {
    phone = verifyScopeToken(registrationToken, 'signup').phone;
  } catch {
    throw ApiError.unauthenticated('Jeton d’inscription invalide ou expiré.');
  }

  const existing = await prisma.user.findUnique({ where: { phone } });
  if (existing) throw ApiError.conflict('Ce numéro est déjà associé à un compte.');

  const user = await prisma.user.create({
    data: {
      role: 'client',
      fullName: input.full_name,
      phone,
      passwordHash: await bcrypt.hash(input.password, 10),
      city: input.city,
      district: input.district,
    },
  });

  notificationsService
    .notifyAdmins(
      'new_registration',
      'Nouvelle inscription',
      `${user.fullName} vient de créer un compte et attend une validation.`,
    )
    .catch(() => {});

  return issueSession(user, deviceMeta);
}

/**
 * Mot de passe oublié — anti-énumération STRICTE (contrat §5.2.1), plus
 * stricte que `requestOtp` : si le numéro ne correspond à aucun compte, 200
 * uniforme SANS rien écrire ni envoyer (contrairement à l'inscription, un
 * reset de mot de passe présuppose un compte déjà existant — créer une ligne
 * `OtpCode` pour un numéro inconnu n'a aucune utilité et fuiterait un signal
 * temporel).
 */
export async function requestPasswordResetOtp(rawPhone: string): Promise<{ dev_code?: string }> {
  const phone = normalizePhone(rawPhone);

  const user = await prisma.user.findUnique({ where: { phone } });
  if (!user) {
    throw ApiError.notFound("Aucun compte n'est associé à ce numéro de téléphone.");
  }


  const recent = await prisma.otpCode.findFirst({
    where: {
      phone,
      purpose: 'passwordReset',
      createdAt: { gt: new Date(Date.now() - env.OTP_RESEND_COOLDOWN_SECONDS * 1000) },
    },
    orderBy: { createdAt: 'desc' },
  });
  if (recent) return {};

  const code = generateOtpCode();
  await prisma.otpCode.create({
    data: {
      phone,
      purpose: 'passwordReset',
      codeHash: hashToken(code),
      expiresAt: new Date(Date.now() + env.OTP_TTL_MINUTES * 60_000),
    },
  });

  // eslint-disable-next-line no-console
  console.log(`[OTP reset] ${phone} → ${code} (valide ${env.OTP_TTL_MINUTES} min)`);

  whatsAppProvider
    .send(phone, `Votre code de réinitialisation EduPay : ${code} (valide ${env.OTP_TTL_MINUTES} min).`)
    .catch(() => {});

  return env.OTP_DEV_EXPOSE && !isProd ? { dev_code: code } : {};
}

/** Réinitialise le mot de passe à partir du `reset_token` vérifié — révoque
 * toutes les sessions existantes (un reset de mot de passe doit déconnecter
 * les autres appareils, potentiellement compromis) et émet une nouvelle
 * session pour l'appareil courant. */
export async function resetPassword(resetToken: string, newPassword: string) {
  let phone: string;
  try {
    phone = verifyScopeToken(resetToken, 'password_reset').phone;
  } catch {
    throw ApiError.unauthenticated('Jeton de réinitialisation invalide ou expiré.');
  }

  const user = await prisma.user.findUnique({ where: { phone } });
  if (!user) throw ApiError.notFound('Compte introuvable.');

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.user.update({
      where: { id: user.id },
      data: { passwordHash: await bcrypt.hash(newPassword, 10), mustChangePassword: false },
    });
    await tx.refreshToken.updateMany({ where: { userId: user.id, revokedAt: null }, data: { revokedAt: new Date() } });
    await tx.session.updateMany({ where: { userId: user.id, revokedAt: null }, data: { revokedAt: new Date() } });
    return u;
  });

  return issueSession(updated);
}

/**
 * Change le mot de passe en exigeant l'ancien (défense en profondeur —
 * distinct de `updateMe` ci-dessous, qui ne l'exige pas car réservé à
 * l'écran « Mon compte » Admin/Agent déjà en prod, non touché par ce
 * chantier). Révoque les autres sessions, comme `resetPassword`.
 */
export async function changePassword(userId: string, currentPassword: string, newPassword: string) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw ApiError.notFound('Compte introuvable.');

  const currentOk = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!currentOk) throw ApiError.unauthenticated('Mot de passe actuel incorrect.');

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.user.update({
      where: { id: userId },
      data: { passwordHash: await bcrypt.hash(newPassword, 10), mustChangePassword: false },
    });
    await tx.refreshToken.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } });
    await tx.session.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } });
    return u;
  });

  return issueSession(updated);
}

export async function login(phone: string, password: string, deviceMeta?: DeviceMeta) {
  const user = await prisma.user.findUnique({
    where: { phone: normalizePhone(phone) },
  });
  if (!user) {
    throw ApiError.notFound("Aucun compte n'est associé à ce numéro de téléphone.");
  }

  const passwordOk = await bcrypt.compare(password, user.passwordHash);
  if (!passwordOk) {
    throw ApiError.unauthenticated('Mot de passe incorrect. Veuillez réessayer.');
  }


  if (user.status === 'rejected' || user.status === 'suspended') {
    throw ApiError.forbidden('Ce compte est désactivé.');
  }
  return issueSession(user, deviceMeta);
}

export async function refresh(refreshToken: string, deviceMeta?: DeviceMeta) {
  let sub: string;
  try {
    sub = verifyRefreshToken(refreshToken).sub;
  } catch {
    throw ApiError.unauthenticated('Jeton de rafraîchissement invalide.');
  }

  const stored = await prisma.refreshToken.findUnique({
    where: { tokenHash: hashToken(refreshToken) },
  });
  if (!stored || stored.userId !== sub) {
    throw ApiError.unauthenticated('Session expirée, reconnectez-vous.');
  }

  if (stored.revokedAt) {
    // Un jeton déjà révoqué par ROTATION (`rotated: true`) qui revient est un
    // vrai signal de rejeu — un client légitime n'utilise jamais un jeton
    // qu'il vient de faire remplacer, donc soit un double appel réseau
    // bénin (rare, la rotation est atomique), soit un vol de jeton : dans le
    // doute, on révoque TOUTES les sessions actives (même logique que le
    // backend Client audité). En revanche, un jeton révoqué par une
    // déconnexion EXPLICITE (logout, révocation d'une session précise,
    // reset/changement de mot de passe — `rotated: false`) revenir ensuite
    // est normal (ex. minuteur de rafraîchissement en arrière-plan sur un
    // appareil qu'on vient de déconnecter à distance) : simple session
    // expirée, PAS une compromission — sans cette distinction, révoquer une
    // seule session en tuait silencieusement d'autres (bug détecté en test).
    if (stored.rotated) {
      await revokeAllSessions(sub);
      throw ApiError.unauthenticated('Session compromise détectée, reconnectez-vous.');
    }
    throw ApiError.unauthenticated('Session expirée, reconnectez-vous.');
  }

  if (stored.expiresAt.getTime() < Date.now()) {
    throw ApiError.unauthenticated('Session expirée, reconnectez-vous.');
  }

  // Rotation : on révoque l'ancien avant d'en émettre un nouveau.
  await prisma.refreshToken.update({
    where: { id: stored.id },
    data: { revokedAt: new Date(), rotated: true },
  });
  const user = await prisma.user.findUniqueOrThrow({ where: { id: sub } });

  const { accessToken, refreshToken: newRefreshToken, refreshTokenRow } = await createTokenPair(user);

  // La session survit à la rotation silencieuse : on la fait pointer vers le
  // nouveau refresh token plutôt que d'en créer une nouvelle à chaque appel
  // (sinon `GET /auth/sessions` gonflerait juste parce que l'app a rafraîchi
  // son token en arrière-plan). Filet de sécurité si la session d'origine
  // n'existe pas (comptes créés avant ce chantier) : on en crée une.
  const existingSession = await prisma.session.findUnique({ where: { refreshTokenId: stored.id } });
  if (existingSession) {
    await prisma.session.update({
      where: { id: existingSession.id },
      data: {
        refreshTokenId: refreshTokenRow.id,
        lastUsedAt: new Date(),
        ...(deviceMeta?.ip ? { ipAddress: deviceMeta.ip } : {}),
        ...(deviceMeta?.userAgent ? { userAgent: deviceMeta.userAgent } : {}),
      },
    });
  } else {
    await prisma.session.create({
      data: {
        userId: user.id,
        refreshTokenId: refreshTokenRow.id,
        ipAddress: deviceMeta?.ip ?? null,
        userAgent: deviceMeta?.userAgent ?? null,
      },
    });
  }

  return {
    access_token: accessToken,
    refresh_token: newRefreshToken,
    user: toUserDto(user),
  };
}

export async function logout(refreshToken: string): Promise<void> {
  const stored = await prisma.refreshToken.findFirst({
    where: { tokenHash: hashToken(refreshToken), revokedAt: null },
  });
  if (!stored) return;
  await prisma.$transaction([
    prisma.refreshToken.update({ where: { id: stored.id }, data: { revokedAt: new Date() } }),
    prisma.session.updateMany({
      where: { refreshTokenId: stored.id, revokedAt: null },
      data: { revokedAt: new Date() },
    }),
  ]);
}

/** Déconnexion de tous les appareils — révoque toutes les sessions actives
 * (et leurs refresh tokens) de l'utilisateur authentifié. Simple alias de
 * `revokeAllSessions` : un seul chemin de révocation totale, exposé sous
 * deux routes (`POST /auth/logout-all` et `DELETE /auth/sessions`). */
export async function logoutAll(userId: string): Promise<void> {
  return revokeAllSessions(userId);
}

/** Appareils actuellement connectés (écran « Sessions actives »), plus
 * récemment utilisés d'abord. */
export async function listSessions(userId: string) {
  const sessions = await prisma.session.findMany({
    where: { userId, revokedAt: null },
    orderBy: { lastUsedAt: 'desc' },
  });
  return sessions.map((s) => ({
    id: s.id,
    device: s.userAgent,
    ip: s.ipAddress,
    last_used_at: s.lastUsedAt.toISOString(),
    created_at: s.createdAt.toISOString(),
  }));
}

/** Révoque UNE session à distance (et son refresh token) — 404 si elle
 * n'existe pas ou n'appartient pas à cet utilisateur. */
export async function revokeSession(userId: string, sessionId: string): Promise<void> {
  const session = await prisma.session.findFirst({
    where: { id: sessionId, userId, revokedAt: null },
  });
  if (!session) throw ApiError.notFound('Session introuvable.');

  await prisma.$transaction([
    prisma.session.update({ where: { id: session.id }, data: { revokedAt: new Date() } }),
    prisma.refreshToken.update({ where: { id: session.refreshTokenId }, data: { revokedAt: new Date() } }),
  ]);
}

/** Révoque toutes les sessions actives (et leurs refresh tokens). */
export async function revokeAllSessions(userId: string): Promise<void> {
  await prisma.$transaction([
    prisma.session.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } }),
    prisma.refreshToken.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } }),
  ]);
}

export async function currentUser(userId: string) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw ApiError.notFound('Compte introuvable.');
  return toUserDto(user);
}

/**
 * Met à jour le compte courant (écran « Mon compte ») : téléphone et/ou mot de
 * passe, sans exiger l'ancien (l'utilisateur est déjà authentifié). Si le mot
 * de passe change, toutes les autres sessions sont révoquées (sécurité). Émet
 * une nouvelle session pour que l'appareil courant reste connecté.
 */
export async function updateMe(
  userId: string,
  input: { new_phone?: string; new_password?: string },
) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw ApiError.notFound('Compte introuvable.');

  const data: { phone?: string; passwordHash?: string; mustChangePassword?: boolean } = {};

  if (input.new_phone !== undefined) {
    const phone = normalizePhone(input.new_phone);
    const taken = await prisma.user.findFirst({
      where: { phone, id: { not: userId } },
      select: { id: true },
    });
    if (taken) throw ApiError.conflict('Ce numéro de téléphone est déjà utilisé.');
    data.phone = phone;
  }

  const passwordChanged = input.new_password !== undefined;
  if (passwordChanged) {
    data.passwordHash = await bcrypt.hash(input.new_password!, 10);
    data.mustChangePassword = false;
  }

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.user.update({ where: { id: userId }, data });
    if (passwordChanged) {
      await tx.refreshToken.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      await tx.session.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }
    return u;
  });

  return issueSession(updated);
}
