import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import { authenticate } from '../../shared/middleware/authenticate.js';
import { authorize } from '../../shared/middleware/authorize.js';
import { seasonsRouter } from '../seasons/seasons.routes.js';
import { kitsRouter } from '../kits/kits.routes.js';
import { suppliesRouter } from '../supplies/supplies.routes.js';
import { vehiclesAdminRouter } from '../vehicles/vehicles.routes.js';
import { refundsRouter } from '../refunds/refunds.routes.js';
import { listNotificationsHandler } from '../notifications/notifications.controller.js';
import { listPaymentGatewaysHandler, updatePaymentGatewayHandler } from '../payments/payment-gateway.controller.js';
import {
  addChildHandler,
  approveFamilyHandler,
  archiveFamilyHandler,
  assignKitHandler,
  createAgentHandler,
  dashboardHandler,
  enrollFamilyHandler,
  familyContributionsHandler,
  getAgentHandler,
  getFamilyHandler,
  listAgentsHandler,
  listAuditLogsHandler,
  listContributionsHandler,
  listFamiliesHandler,
  listPendingFamiliesHandler,
  reactivateAgentHandler,
  reassignAgentHandler,
  recordCashContributionHandler,
  rejectFamilyHandler,
  removeChildHandler,
  reportIncidentHandler,
  suspendAgentHandler,
  updateChildHandler,
  updateFamilyHandler,
  assignDeliveryLocationHandler,
} from './admin.controller.js';

// Module Administration (notre équipe) — contrat §5.4. Réservé au rôle admin.
// (L'app n'a pas de flux de changement de mot de passe forcé : on ne bloque
// donc pas sur `mustChangePassword` — la MAJ des identifiants se fait via
// `PATCH /auth/me`, écran « Mon compte ».)
export const adminRouter = Router();

adminRouter.use(authenticate, authorize('admin'));

adminRouter.get('/dashboard', asyncHandler(dashboardHandler));
adminRouter.get('/families', asyncHandler(listFamiliesHandler));
adminRouter.get('/families/pending', asyncHandler(listPendingFamiliesHandler));
adminRouter.post('/families', asyncHandler(enrollFamilyHandler));
adminRouter.get('/families/:id', asyncHandler(getFamilyHandler));
adminRouter.patch('/families/:id', asyncHandler(updateFamilyHandler));
adminRouter.delete('/families/:id', asyncHandler(archiveFamilyHandler));
adminRouter.patch('/families/:id/agent', asyncHandler(reassignAgentHandler));
adminRouter.get('/families/:id/contributions', asyncHandler(familyContributionsHandler));
adminRouter.post('/families/:id/contributions', asyncHandler(recordCashContributionHandler));
adminRouter.post('/families/:id/incident', asyncHandler(reportIncidentHandler));
adminRouter.post('/families/:id/children', asyncHandler(addChildHandler));
adminRouter.patch('/families/:id/children/:childId', asyncHandler(updateChildHandler));
adminRouter.delete('/families/:id/children/:childId', asyncHandler(removeChildHandler));
adminRouter.post('/families/:id/children/:childId/kit', asyncHandler(assignKitHandler));
adminRouter.post('/families/:id/approve', asyncHandler(approveFamilyHandler));
adminRouter.post('/families/:id/reject', asyncHandler(rejectFamilyHandler));
adminRouter.get('/audit-logs', asyncHandler(listAuditLogsHandler));
// Inbox in-app de l'admin connecté (assignations, nouvelles inscriptions...)
// — même service générique que parents/agent, il manquait juste sa route ici.
adminRouter.get('/notifications', asyncHandler(listNotificationsHandler));
adminRouter.get('/contributions', asyncHandler(listContributionsHandler));
adminRouter.get('/payment-gateways', asyncHandler(listPaymentGatewaysHandler));
adminRouter.patch('/payment-gateways/:name', asyncHandler(updatePaymentGatewayHandler));

// Livraison
adminRouter.patch('/deliveries/:id/assign', asyncHandler(assignDeliveryLocationHandler));

// Catalogue (saisons + kits) — sous-ressources du module Administration.
adminRouter.use('/seasons', seasonsRouter);
adminRouter.use('/kits', kitsRouter);
adminRouter.use('/supplies', suppliesRouter);
adminRouter.use('/vehicles', vehiclesAdminRouter);
adminRouter.use('/refunds', refundsRouter);

adminRouter.get('/agents', asyncHandler(listAgentsHandler));
adminRouter.post('/agents', asyncHandler(createAgentHandler));
adminRouter.get('/agents/:id', asyncHandler(getAgentHandler));
adminRouter.post('/agents/:id/suspend', asyncHandler(suspendAgentHandler));
adminRouter.post('/agents/:id/reactivate', asyncHandler(reactivateAgentHandler));
