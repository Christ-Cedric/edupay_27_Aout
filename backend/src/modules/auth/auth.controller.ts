import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { list, ok } from '../../shared/http/respond.js';
import type { DeviceMeta } from './auth.service.js';
import {
  loginSchema,
  passwordChangeSchema,
  passwordForgotSchema,
  passwordResetSchema,
  refreshSchema,
  registerSchema,
  requestOtpSchema,
  updateMeSchema,
  verifyOtpSchema,
} from './auth.schemas.js';
import * as authService from './auth.service.js';

function bearerToken(req: Request): string {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) throw ApiError.unauthenticated();
  return header.slice('Bearer '.length);
}

/** Métadonnées d'appareil best-effort pour l'écran « Sessions actives » —
 * jamais bloquant si absentes (proxy sans `X-Forwarded-For`, client sans
 * en-tête `User-Agent`). */
function deviceMeta(req: Request): DeviceMeta {
  const userAgent = req.headers['user-agent'];
  return {
    ip: req.ip,
    userAgent: typeof userAgent === 'string' ? userAgent : undefined,
  };
}

export async function requestOtpHandler(req: Request, res: Response): Promise<void> {
  const { phone } = requestOtpSchema.parse(req.body);
  ok(res, await authService.requestOtp(phone));
}

export async function verifyOtpHandler(req: Request, res: Response): Promise<void> {
  const { phone, code } = verifyOtpSchema.parse(req.body);
  ok(res, await authService.verifyOtp(phone, code));
}

export async function registerHandler(req: Request, res: Response): Promise<void> {
  const input = registerSchema.parse(req.body);
  ok(res, await authService.register(bearerToken(req), input, deviceMeta(req)));
}

export async function loginHandler(req: Request, res: Response): Promise<void> {
  const { phone, password } = loginSchema.parse(req.body);
  ok(res, await authService.login(phone, password, deviceMeta(req)));
}

export async function refreshHandler(req: Request, res: Response): Promise<void> {
  const { refresh_token } = refreshSchema.parse(req.body);
  ok(res, await authService.refresh(refresh_token, deviceMeta(req)));
}

export async function logoutHandler(req: Request, res: Response): Promise<void> {
  const { refresh_token } = refreshSchema.parse(req.body);
  await authService.logout(refresh_token);
  res.status(204).send();
}

export async function logoutAllHandler(req: Request, res: Response): Promise<void> {
  if (!req.auth) throw ApiError.unauthenticated();
  await authService.logoutAll(req.auth.userId);
  res.status(204).send();
}

export async function meHandler(req: Request, res: Response): Promise<void> {
  if (!req.auth) throw ApiError.unauthenticated();
  ok(res, await authService.currentUser(req.auth.userId));
}

export async function updateMeHandler(req: Request, res: Response): Promise<void> {
  if (!req.auth) throw ApiError.unauthenticated();
  const input = updateMeSchema.parse(req.body);
  ok(res, await authService.updateMe(req.auth.userId, input));
}

export async function passwordForgotHandler(req: Request, res: Response): Promise<void> {
  const { phone } = passwordForgotSchema.parse(req.body);
  ok(res, await authService.requestPasswordResetOtp(phone));
}

export async function passwordResetHandler(req: Request, res: Response): Promise<void> {
  const { password } = passwordResetSchema.parse(req.body);
  ok(res, await authService.resetPassword(bearerToken(req), password));
}

export async function passwordChangeHandler(req: Request, res: Response): Promise<void> {
  if (!req.auth) throw ApiError.unauthenticated();
  const { current_password, new_password } = passwordChangeSchema.parse(req.body);
  ok(res, await authService.changePassword(req.auth.userId, current_password, new_password));
}

export async function listSessionsHandler(req: Request, res: Response): Promise<void> {
  if (!req.auth) throw ApiError.unauthenticated();
  list(res, await authService.listSessions(req.auth.userId));
}

export async function revokeSessionHandler(req: Request, res: Response): Promise<void> {
  if (!req.auth) throw ApiError.unauthenticated();
  const { id } = req.params;
  if (!id) throw ApiError.badRequest('Identifiant de session manquant.');
  await authService.revokeSession(req.auth.userId, id);
  res.status(204).send();
}

export async function revokeAllSessionsHandler(req: Request, res: Response): Promise<void> {
  if (!req.auth) throw ApiError.unauthenticated();
  await authService.revokeAllSessions(req.auth.userId);
  res.status(204).send();
}
