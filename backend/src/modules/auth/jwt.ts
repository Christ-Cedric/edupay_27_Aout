import jwt from 'jsonwebtoken';
import { randomUUID } from 'node:crypto';
import type { UserRole, UserStatus } from '@prisma/client';
import { env } from '../../config/env.js';

export interface AccessClaims {
  sub: string;
  role: UserRole;
  status: UserStatus;
}

export function signAccessToken(claims: AccessClaims): string {
  return jwt.sign(claims, env.JWT_ACCESS_SECRET, {
    expiresIn: env.JWT_ACCESS_TTL,
  } as jwt.SignOptions);
}

export function verifyAccessToken(token: string): AccessClaims {
  return jwt.verify(token, env.JWT_ACCESS_SECRET) as AccessClaims;
}

/**
 * Le refresh token est opaque côté client ; on ne stocke que son hash. Le `jti`
 * aléatoire garantit l'unicité même si deux jetons sont émis dans la même
 * seconde pour le même utilisateur (sinon `{sub, iat, exp}` seraient identiques
 * → collision de `token_hash`).
 */
export function signRefreshToken(sub: string): string {
  return jwt.sign({ sub, jti: randomUUID() }, env.JWT_REFRESH_SECRET, {
    expiresIn: env.JWT_REFRESH_TTL,
  } as jwt.SignOptions);
}

export function verifyRefreshToken(token: string): { sub: string } {
  return jwt.verify(token, env.JWT_REFRESH_SECRET) as { sub: string };
}

/**
 * Jeton de portée à usage unique pour l'inscription client par OTP (§2) :
 * lie un numéro de téléphone VÉRIFIÉ à l'étape suivante du flux, sans que le
 * client puisse falsifier ce numéro dans le corps de la requête `register`.
 * Signé avec un secret distinct de l'access token (voir `env.ts`).
 */
export interface ScopeClaims {
  phone: string;
  purpose: 'signup' | 'password_reset';
}

export function signScopeToken(claims: ScopeClaims): string {
  return jwt.sign(claims, env.JWT_SCOPE_SECRET, {
    expiresIn: env.JWT_SCOPE_TTL,
  } as jwt.SignOptions);
}

export function verifyScopeToken(token: string, expectedPurpose: ScopeClaims['purpose']): ScopeClaims {
  const claims = jwt.verify(token, env.JWT_SCOPE_SECRET) as ScopeClaims;
  if (claims.purpose !== expectedPurpose) {
    throw new Error('Jeton de portée invalide pour cette action.');
  }
  return claims;
}
