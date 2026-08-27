import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import { authenticate } from '../../shared/middleware/authenticate.js';
import { authorize } from '../../shared/middleware/authorize.js';
import {
  confirmReceiptHandler,
  getDeliveriesHandler,
  reportIssueHandler,
  sendLocationHandler,
} from '../delivery/delivery.controller.js';
import { listNotificationsHandler } from '../notifications/notifications.controller.js';
import { confirmSubscriptionHandler, previewChildHandler } from '../subscriptions/subscriptions.controller.js';
import {
  addChildHandler,
  assignKitHandler,
  createContributionHandler,
  listChildrenHandler,
  listContributionsHandler,
  listRefundsHandler,
  meHandler,
  meFamilyHandler,
  removeChildHandler,
  requestRefundHandler,
  updateChildHandler,
  updateProfileHandler,
  setTuitionGoalHandler,
  setTransportGoalHandler,
} from './parents.controller.js';

// Self-service parent (app Client) — réutilise les fonctions déjà écrites
// pour l'admin (`admin.service.ts`) en passant `clientId = req.auth.userId`
// : un parent ne peut agir que sur sa propre famille (mêmes vérifications
// d'appartenance déjà en place côté admin).
export const parentsRouter = Router();

parentsRouter.use(authenticate, authorize('client'));

parentsRouter.get('/me', asyncHandler(meHandler));
parentsRouter.get('/me/family', asyncHandler(meFamilyHandler));
parentsRouter.patch('/me', asyncHandler(updateProfileHandler));

parentsRouter.get('/me/children', asyncHandler(listChildrenHandler));
parentsRouter.post('/me/children', asyncHandler(addChildHandler));
parentsRouter.patch('/me/children/:childId', asyncHandler(updateChildHandler));
parentsRouter.delete('/me/children/:childId', asyncHandler(removeChildHandler));
parentsRouter.post('/me/children/:childId/kit', asyncHandler(assignKitHandler));
parentsRouter.post('/me/children/:childId/tuition', asyncHandler(setTuitionGoalHandler));
parentsRouter.post('/me/children/:childId/transport', asyncHandler(setTransportGoalHandler));
parentsRouter.post('/me/children/preview', asyncHandler(previewChildHandler));

parentsRouter.post('/me/subscription/confirm', asyncHandler(confirmSubscriptionHandler));

parentsRouter.get('/me/contributions', asyncHandler(listContributionsHandler));
parentsRouter.post('/me/contributions', asyncHandler(createContributionHandler));

parentsRouter.get('/me/delivery', asyncHandler(getDeliveriesHandler));
parentsRouter.post('/me/delivery/location', asyncHandler(sendLocationHandler));
parentsRouter.post('/me/delivery/confirm-receipt', asyncHandler(confirmReceiptHandler));
parentsRouter.post('/me/delivery/issues', asyncHandler(reportIssueHandler));

parentsRouter.get('/me/refunds', asyncHandler(listRefundsHandler));
parentsRouter.post('/me/refunds', asyncHandler(requestRefundHandler));

parentsRouter.get('/me/notifications', asyncHandler(listNotificationsHandler));
