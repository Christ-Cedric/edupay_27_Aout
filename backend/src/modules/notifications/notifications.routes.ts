import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import { authenticate } from '../../shared/middleware/authenticate.js';
import {
  markNotificationReadHandler,
  registerDeviceTokenHandler,
  unregisterDeviceTokenHandler,
} from './notifications.controller.js';

// Commun à tous les rôles (parent, agent, admin) : chacun ne peut marquer
// comme lue qu'une notification lui appartenant (`markRead` scope sur
// `userId`, voir notifications.service.ts). Les listes elles-mêmes restent
// sous /parents/me/notifications et /agent/me/notifications (§ contrat).
export const notificationsRouter = Router();

notificationsRouter.use(authenticate);
notificationsRouter.patch('/:id/read', asyncHandler(markNotificationReadHandler));

// Enregistrement du token push FCM de l'appareil courant — commun aux trois
// rôles, comme le reste de ce routeur.
notificationsRouter.post('/device-token', asyncHandler(registerDeviceTokenHandler));
notificationsRouter.delete('/device-token', asyncHandler(unregisterDeviceTokenHandler));
