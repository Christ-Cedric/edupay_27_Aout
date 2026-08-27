import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import { authenticate } from '../../shared/middleware/authenticate.js';
import { authorize } from '../../shared/middleware/authorize.js';
import { listNotificationsHandler } from '../notifications/notifications.controller.js';
import {
  addChildHandler,
  advanceDeliveryHandler,
  archiveFamilyHandler,
  commissionsHandler,
  confirmDeliveryHandler,
  contributionDetailHandler,
  dashboardHandler,
  deliveriesTodayHandler,
  deliveryDetailHandler,
  directorContactHandler,
  enrollFamilyHandler,
  familiesHandler,
  familyByCodeHandler,
  familyContributionsHandler,
  familyDetailHandler,
  familyLedgerHandler,
  familyNotificationsHandler,
  myContributionsHandler,
  profileHandler,
  recordContributionHandler,
  remindLateFamilyHandler,
  scheduleDeliveryHandler,
  sendReportHandler,
  updateFamilyHandler,
  updateProfileHandler,
  assignChildKitHandler,
} from './agent.controller.js';

// Self-service terrain (app Agent) — un agent n'agit jamais que sur les
// familles qui lui sont assignées (`assertOwnFamily`, agent.service.ts).
export const agentRouter = Router();

agentRouter.use(authenticate, authorize('agent'));

agentRouter.get('/me', asyncHandler(profileHandler));
agentRouter.patch('/me', asyncHandler(updateProfileHandler));
agentRouter.get('/me/dashboard', asyncHandler(dashboardHandler));
agentRouter.get('/me/commissions', asyncHandler(commissionsHandler));
agentRouter.get('/me/notifications', asyncHandler(listNotificationsHandler));

agentRouter.get('/me/families', asyncHandler(familiesHandler));
agentRouter.post('/me/families', asyncHandler(enrollFamilyHandler));
agentRouter.get('/me/families/by-code/:code', asyncHandler(familyByCodeHandler));
agentRouter.get('/me/families/:id', asyncHandler(familyDetailHandler));
agentRouter.patch('/me/families/:id', asyncHandler(updateFamilyHandler));
agentRouter.delete('/me/families/:id', asyncHandler(archiveFamilyHandler));
agentRouter.post('/me/families/:id/children', asyncHandler(addChildHandler));
agentRouter.post('/me/families/:id/children/:childId/kit', asyncHandler(assignChildKitHandler));
agentRouter.get('/me/families/:id/contributions', asyncHandler(familyContributionsHandler));
agentRouter.get('/me/families/:id/ledger', asyncHandler(familyLedgerHandler));
agentRouter.get('/me/families/:id/notifications', asyncHandler(familyNotificationsHandler));
agentRouter.post('/me/families/:id/contributions', asyncHandler(recordContributionHandler));
agentRouter.post('/me/families/:id/remind', asyncHandler(remindLateFamilyHandler));

agentRouter.get('/me/contributions', asyncHandler(myContributionsHandler));
agentRouter.get('/me/contributions/:id', asyncHandler(contributionDetailHandler));

agentRouter.get('/me/deliveries', asyncHandler(deliveriesTodayHandler));
agentRouter.get('/me/deliveries/:id', asyncHandler(deliveryDetailHandler));
agentRouter.patch('/me/deliveries/:id/status', asyncHandler(advanceDeliveryHandler));
agentRouter.post('/me/deliveries/:id/confirm', asyncHandler(confirmDeliveryHandler));
agentRouter.patch('/me/deliveries/:id/schedule', asyncHandler(scheduleDeliveryHandler));

agentRouter.post('/me/reports/send', asyncHandler(sendReportHandler));
agentRouter.get('/me/contact-director', asyncHandler(directorContactHandler));
