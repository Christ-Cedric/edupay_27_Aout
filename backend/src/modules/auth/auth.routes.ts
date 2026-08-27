import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import { authenticate } from '../../shared/middleware/authenticate.js';
import { authLimiter } from '../../shared/middleware/rate-limit.js';
import {
  listSessionsHandler,
  loginHandler,
  logoutAllHandler,
  logoutHandler,
  meHandler,
  passwordChangeHandler,
  passwordForgotHandler,
  passwordResetHandler,
  refreshHandler,
  registerHandler,
  requestOtpHandler,
  revokeAllSessionsHandler,
  revokeSessionHandler,
  updateMeHandler,
  verifyOtpHandler,
} from './auth.controller.js';

// Contrat §2 — pas d'OTP côté Admin/Agent (admin seedé, agents créés par
// l'admin) : ces routes login/refresh/logout servent les 3 rôles. L'OTP
// (request/verify/register/mot de passe oublié) ne concerne QUE le rôle
// client (app parent).
export const authRouter = Router();

// Rate-limit sur les points sensibles au brute-force (mots de passe / jetons
// / codes OTP).
authRouter.post('/otp/request', authLimiter, asyncHandler(requestOtpHandler));
// Route unique pour les deux flux (inscription ET mot de passe oublié) — le
// type de jeton renvoyé dépend du `purpose` de l'OTP trouvé, voir auth.service.ts.
authRouter.post('/otp/verify', authLimiter, asyncHandler(verifyOtpHandler));
authRouter.post('/register', authLimiter, asyncHandler(registerHandler));

authRouter.post('/login', authLimiter, asyncHandler(loginHandler));
authRouter.post('/refresh', authLimiter, asyncHandler(refreshHandler));
authRouter.post('/logout', asyncHandler(logoutHandler));
authRouter.post('/logout-all', authenticate, asyncHandler(logoutAllHandler));

authRouter.post('/password/forgot', authLimiter, asyncHandler(passwordForgotHandler));
// Bearer = reset_token (issu de /otp/verify), pas une session utilisateur.
authRouter.post('/password/reset', authLimiter, asyncHandler(passwordResetHandler));
// Additive — ne remplace pas PATCH /me (écran « Mon compte » Admin/Agent
// existant, qui ne change pas l'ancien mot de passe).
authRouter.post('/password/change', authenticate, asyncHandler(passwordChangeHandler));

authRouter.get('/sessions', authenticate, asyncHandler(listSessionsHandler));
authRouter.delete('/sessions', authenticate, asyncHandler(revokeAllSessionsHandler));
authRouter.delete('/sessions/:id', authenticate, asyncHandler(revokeSessionHandler));

authRouter.get('/me', authenticate, asyncHandler(meHandler));
// Écran « Mon compte » : mise à jour téléphone / mot de passe.
authRouter.patch('/me', authenticate, asyncHandler(updateMeHandler));
