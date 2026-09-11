import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { list, ok } from '../../shared/http/respond.js';
import { advanceStatusSchema, confirmByAgentSchema, scheduleDeliverySchema } from '../delivery/delivery.schemas.js';
import { addChildSchema, enrollFamilySchema, updateFamilyProfileSchema, assignKitSchema } from '../admin/admin.schemas.js';
import * as agentService from './agent.service.js';
import * as adminService from '../admin/admin.service.js';
import { prisma } from '../../shared/prisma.js';
import {
  agentContributionSchema,
  agentDeliveriesQuerySchema,
  agentFamiliesQuerySchema,
  contributionIdParamSchema,
  deliveryIdParamSchema,
  familyCodeParamSchema,
  familyIdParamSchema,
  updateAgentProfileSchema,
  agentSetGoalSchema,
  agentRefundSchema,
  agentSetSchoolingGoalSchema,
} from './agent.schemas.js';

function selfId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

/** `X-Idempotency-Key` optionnel — protège d'un double-tap sur un réseau
 * terrain instable (voir `payments.service.ts::initiateContribution`). */
function idempotencyKey(req: Request): string | undefined {
  const header = req.headers['x-idempotency-key'];
  return typeof header === 'string' && header.length > 0 ? header : undefined;
}

export async function profileHandler(req: Request, res: Response): Promise<void> {
  ok(res, await agentService.getProfile(selfId(req)));
}

export async function updateProfileHandler(req: Request, res: Response): Promise<void> {
  const input = updateAgentProfileSchema.parse(req.body);
  ok(res, await agentService.updateProfile(selfId(req), input));
}

export async function dashboardHandler(req: Request, res: Response): Promise<void> {
  ok(res, await agentService.getDashboard(selfId(req)));
}

export async function familiesHandler(req: Request, res: Response): Promise<void> {
  const query = agentFamiliesQuerySchema.parse(req.query);
  list(res, await agentService.getMyFamilies(selfId(req), query));
}

export async function familyByCodeHandler(req: Request, res: Response): Promise<void> {
  const { code } = familyCodeParamSchema.parse(req.params);
  ok(res, await agentService.getFamilyByCode(selfId(req), code));
}

export async function enrollFamilyHandler(req: Request, res: Response): Promise<void> {
  const input = enrollFamilySchema.parse(req.body);
  ok(res, await agentService.enrollFamily(selfId(req), input));
}

export async function familyDetailHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  ok(res, await agentService.getFamilyDetail(selfId(req), id));
}

export async function updateFamilyHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  const input = updateFamilyProfileSchema.parse(req.body);
  ok(res, await agentService.updateFamily(selfId(req), id, input));
}

export async function addChildHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  const input = addChildSchema.parse(req.body);
  ok(res, await agentService.addChild(selfId(req), id, input));
}

export async function assignChildKitHandler(req: Request, res: Response): Promise<void> {
  const { id, childId } = req.params;
  if (!id || !childId) throw ApiError.badRequest('Paramètres manquants.');
  
  if (req.body.custom === true && Array.isArray(req.body.items)) {
    const targetAmount = req.body.items.reduce((acc: number, item: any) => acc + (item.quantity * item.price), 0);
    const seasonId = (await prisma.season.findFirst({ where: { isCurrent: true } }))?.id;
    if (!seasonId) throw ApiError.badRequest('Aucune saison courante.');
    
    const existingGoal = await prisma.savingsGoal.findUnique({
      where: { childId_seasonId_type: { childId, seasonId, type: 'supplies' } },
    });
    
    if (existingGoal) {
      await prisma.savingsGoal.update({
        where: { id: existingGoal.id },
        data: { targetAmount, name: 'Kit Personnalisé', customAddedItems: req.body.items },
      });
    } else {
      await prisma.savingsGoal.create({
        data: {
          parentId: id,
          childId,
          seasonId,
          type: 'supplies',
          name: 'Kit Personnalisé',
          targetAmount,
          status: 'active',
          customAddedItems: req.body.items,
        },
      });
    }
    ok(res, { success: true });
    return;
  }

  const input = assignKitSchema.parse(req.body);
  ok(res, await agentService.assignChildKit(selfId(req), id, childId, input));
}

export async function setSchoolingGoalHandler(req: Request, res: Response): Promise<void> {
  const { id, childId } = req.params;
  if (!id || !childId) throw ApiError.badRequest('Paramètres manquants.');
  const input = agentSetSchoolingGoalSchema.parse(req.body);
  if (input.amount < 25000) {
    throw ApiError.badRequest('Le coût total de la scolarité doit être d\'au moins 25 000 FCFA.');
  }

  // Calcul du nombre total de jours du plan
  let daysPerContribution = 1;
  if (input.frequency === 'weekly') daysPerContribution = 7;
  if (input.frequency === 'monthly') daysPerContribution = 30;

  const numberOfContributions = Math.ceil(input.amount / input.capacity);
  const totalDays = numberOfContributions * daysPerContribution;

  // Calcul de la date de fin
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + totalDays);

  // Détermination de la limite du 15 Septembre de l'année scolaire en cours
  const now = new Date();
  let targetYear = now.getFullYear();
  if (now.getMonth() >= 9) { // Octobre (9) ou plus
    targetYear++;
  }
  const deadline = new Date(targetYear, 8, 15); // Mois 8 = Septembre

  if (endDate > deadline) {
    throw ApiError.badRequest(`La durée du plan choisi dépasse la limite du 15 septembre ${targetYear}. Veuillez choisir une capacité de cotisation plus élevée ou une fréquence plus courte pour respecter la limite.`);
  }

  ok(res, await adminService.setChildGoal(
    selfId(req), id, childId, 'registration', input.amount, input.name, 
    { frequency: input.frequency, capacity: input.capacity }
  ));
}

export async function setTransportGoalHandler(req: Request, res: Response): Promise<void> {
  const { id, childId } = req.params;
  if (!id || !childId) throw ApiError.badRequest('Paramètres manquants.');
  const input = agentSetSchoolingGoalSchema.parse(req.body);
  ok(res, await adminService.setChildGoal(
    selfId(req), id, childId, 'transport', input.amount, input.name,
    { frequency: input.frequency, capacity: input.capacity }
  ));
}

export async function requestRefundHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  const input = agentRefundSchema.parse(req.body);
  
  // Directly create the refund in Prisma for agent requests.
  const refund = await prisma.refund.create({
    data: {
      parentId: id,
      amount: input.amount,
      reason: input.reason,
      status: 'requested',
    },
  });
  ok(res, refund);
}


export async function archiveFamilyHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  ok(res, await agentService.archiveFamily(selfId(req), id));
}

export async function familyContributionsHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  list(res, await agentService.getFamilyContributions(selfId(req), id));
}

export async function familyLedgerHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  list(res, await agentService.getFamilyLedger(selfId(req), id));
}

export async function familyNotificationsHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  list(res, await agentService.getFamilyNotifications(selfId(req), id));
}

export async function recordContributionHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  const { amount, targetGoalType } = agentContributionSchema.parse(req.body);
  ok(res, await agentService.recordContribution(selfId(req), id, amount, idempotencyKey(req), targetGoalType));
}

export async function myContributionsHandler(req: Request, res: Response): Promise<void> {
  list(res, await agentService.listMyContributions(selfId(req)));
}

export async function contributionDetailHandler(req: Request, res: Response): Promise<void> {
  const { id } = contributionIdParamSchema.parse(req.params);
  ok(res, await agentService.getContribution(selfId(req), id));
}

export async function commissionsHandler(req: Request, res: Response): Promise<void> {
  list(res, await agentService.listCommissions(selfId(req)));
}

export async function remindLateFamilyHandler(req: Request, res: Response): Promise<void> {
  const { id } = familyIdParamSchema.parse(req.params);
  ok(res, await agentService.remindLateFamily(selfId(req), id));
}

export async function deliveriesTodayHandler(req: Request, res: Response): Promise<void> {
  const query = agentDeliveriesQuerySchema.parse(req.query);
  list(res, await agentService.getDeliveriesToday(selfId(req), query));
}

export async function deliveryDetailHandler(req: Request, res: Response): Promise<void> {
  const { id } = deliveryIdParamSchema.parse(req.params);
  ok(res, await agentService.getDelivery(selfId(req), id));
}

export async function advanceDeliveryHandler(req: Request, res: Response): Promise<void> {
  const { id } = deliveryIdParamSchema.parse(req.params);
  const input = advanceStatusSchema.parse(req.body);
  ok(res, await agentService.advanceDelivery(selfId(req), id, input));
}

export async function confirmDeliveryHandler(req: Request, res: Response): Promise<void> {
  const { id } = deliveryIdParamSchema.parse(req.params);
  const input = confirmByAgentSchema.parse(req.body);
  ok(res, await agentService.confirmDelivery(selfId(req), id, input));
}

export async function scheduleDeliveryHandler(req: Request, res: Response): Promise<void> {
  const { id } = deliveryIdParamSchema.parse(req.params);
  const input = scheduleDeliverySchema.parse(req.body);
  ok(res, await agentService.scheduleDelivery(selfId(req), id, input));
}

export async function sendReportHandler(req: Request, res: Response): Promise<void> {
  ok(res, await agentService.sendReportToDirector(selfId(req)));
}

export async function directorContactHandler(_req: Request, res: Response): Promise<void> {
  ok(res, agentService.getDirectorContact());
}
