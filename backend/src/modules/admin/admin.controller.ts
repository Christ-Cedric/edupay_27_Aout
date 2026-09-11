import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { created, list, noContent, ok } from '../../shared/http/respond.js';
import { buildMeta } from '../../shared/http/pagination.js';
import {
  addChildSchema,
  agentsQuerySchema,
  approveFamilySchema,
  assignKitSchema,
  childIdParamSchema,
  createAgentSchema,
  enrollFamilySchema,
  familiesQuerySchema,
  idParamSchema,
  incidentSchema,
  paginationQuerySchema,
  reassignAgentSchema,
  rejectSchema,
  suspendSchema,
  updateChildSchema,
  updateFamilyProfileSchema,
  assignDeliveryLocationSchema,
} from './admin.schemas.js';
import * as adminService from './admin.service.js';
import { recordCashContributionSchema } from '../payments/payments.schemas.js';
import * as paymentsService from '../payments/payments.service.js';

function actorId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

export async function listAgentsHandler(req: Request, res: Response): Promise<void> {
  const query = agentsQuerySchema.parse(req.query);
  list(res, await adminService.listAgents(query));
}

export async function getAgentHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await adminService.getAgent(id));
}

export async function createAgentHandler(req: Request, res: Response): Promise<void> {
  const input = createAgentSchema.parse(req.body);
  created(res, await adminService.createAgent(actorId(req), input));
}

export async function suspendAgentHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const { reason } = suspendSchema.parse(req.body);
  ok(res, await adminService.suspendAgent(actorId(req), id, reason));
}

export async function reactivateAgentHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await adminService.reactivateAgent(actorId(req), id));
}

export async function dashboardHandler(_req: Request, res: Response): Promise<void> {
  ok(res, await adminService.dashboardStats());
}

export async function listFamiliesHandler(req: Request, res: Response): Promise<void> {
  const query = familiesQuerySchema.parse(req.query);
  list(res, await adminService.listFamilies(query));
}

export async function listPendingFamiliesHandler(_req: Request, res: Response): Promise<void> {
  list(res, await adminService.listPendingFamilies());
}

export async function getFamilyHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await adminService.getFamily(id));
}

export async function enrollFamilyHandler(req: Request, res: Response): Promise<void> {
  const input = enrollFamilySchema.parse(req.body);
  created(res, await adminService.enrollFamily(actorId(req), input));
}

export async function updateFamilyHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const input = updateFamilyProfileSchema.parse(req.body);
  ok(res, await adminService.updateFamilyProfile(actorId(req), id, input));
}

export async function archiveFamilyHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await adminService.archiveFamily(actorId(req), id));
}

export async function reassignAgentHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const { assigned_agent_id } = reassignAgentSchema.parse(req.body);
  ok(res, await adminService.reassignAgent(actorId(req), id, assigned_agent_id));
}

export async function addChildHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const input = addChildSchema.parse(req.body);
  created(res, await adminService.addChild(actorId(req), id, input));
}

export async function updateChildHandler(req: Request, res: Response): Promise<void> {
  const { id, childId } = childIdParamSchema.parse(req.params);
  const input = updateChildSchema.parse(req.body);
  ok(res, await adminService.updateChild(actorId(req), id, childId, input));
}

export async function removeChildHandler(req: Request, res: Response): Promise<void> {
  const { id, childId } = childIdParamSchema.parse(req.params);
  ok(res, await adminService.removeChild(actorId(req), id, childId));
}

export async function assignKitHandler(req: Request, res: Response): Promise<void> {
  const { id, childId } = childIdParamSchema.parse(req.params);
  const input = assignKitSchema.parse(req.body);
  ok(res, await adminService.assignKit(actorId(req), id, childId, input));
}

export async function familyContributionsHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  list(res, await adminService.listFamilyContributions(id));
}

/** Rapport « cotisations » (écran Rapports & exports) — toutes familles confondues. */
export async function listContributionsHandler(_req: Request, res: Response): Promise<void> {
  list(res, await adminService.listAllContributions());
}

/** Enregistre un encaissement cash pour cette famille (écran à venir). */
export async function recordCashContributionHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const input = recordCashContributionSchema.parse(req.body);
  created(res, await paymentsService.recordCashContribution(actorId(req), id, input));
}

export async function reportIncidentHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const { note } = incidentSchema.parse(req.body);
  await adminService.reportFamilyIncident(actorId(req), id, note);
  noContent(res);
}

export async function approveFamilyHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const { assigned_agent_id } = approveFamilySchema.parse(req.body ?? {});
  ok(res, await adminService.approveFamily(actorId(req), id, assigned_agent_id));
}

export async function rejectFamilyHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const { reason } = rejectSchema.parse(req.body);
  ok(res, await adminService.rejectFamily(actorId(req), id, reason));
}

export const listAuditLogsHandler = async (req: Request, res: Response): Promise<void> => {
  const query = paginationQuerySchema.parse(req.query);
  const { rows, total } = await adminService.listAuditLogs(query);
  list(res, rows, buildMeta(query, total));
};

export async function assignDeliveryLocationHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params); // delivery ID
  const { lat, lng, address, assigned_agent_id } = assignDeliveryLocationSchema.parse(req.body);
  ok(res, await adminService.assignDeliveryLocation(actorId(req), id, { lat, lng, address, assigned_agent_id }));
}
