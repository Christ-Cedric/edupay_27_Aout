import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { ok } from '../../shared/http/respond.js';
import * as adminService from '../admin/admin.service.js';
import { addChildSchema, assignKitSchema, updateChildSchema } from '../admin/admin.schemas.js';
import { currentUser } from '../auth/auth.service.js';
import { selfContributionSchema } from '../payments/payments.schemas.js';
import * as paymentsService from '../payments/payments.service.js';
import { requestRefundSchema } from '../refunds/refunds.schemas.js';
import * as refundsService from '../refunds/refunds.service.js';
import { childIdParamSchema, updateProfileSchema, setTuitionGoalSchema, setTransportGoalSchema } from './parents.schemas.js';
import * as parentsService from './parents.service.js';
import { getFamily as getFamilyAdmin } from '../admin/admin.service.js';

function selfId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

/** `X-Idempotency-Key` optionnel — protège d'un double-tap réseau (voir
 * `payments.service.ts::initiateContribution`). */
function idempotencyKey(req: Request): string | undefined {
  const header = req.headers['x-idempotency-key'];
  return typeof header === 'string' && header.length > 0 ? header : undefined;
}

export async function meHandler(req: Request, res: Response): Promise<void> {
  ok(res, await currentUser(selfId(req)));
}

export async function meFamilyHandler(req: Request, res: Response): Promise<void> {
  const id = selfId(req);
  ok(res, await getFamilyAdmin(id));
}

export async function updateProfileHandler(req: Request, res: Response): Promise<void> {
  const input = updateProfileSchema.parse(req.body);
  ok(res, await parentsService.updateProfile(selfId(req), input));
}

export async function listChildrenHandler(req: Request, res: Response): Promise<void> {
  const family = await adminService.getFamily(selfId(req));
  ok(res, { data: family.children });
}

export async function addChildHandler(req: Request, res: Response): Promise<void> {
  const input = addChildSchema.parse(req.body);
  const id = selfId(req);
  ok(res, await adminService.addChild(id, id, input));
}

export async function updateChildHandler(req: Request, res: Response): Promise<void> {
  const { childId } = childIdParamSchema.parse(req.params);
  const input = updateChildSchema.parse(req.body);
  const id = selfId(req);
  ok(res, await adminService.updateChild(id, id, childId, input));
}

export async function removeChildHandler(req: Request, res: Response): Promise<void> {
  const { childId } = childIdParamSchema.parse(req.params);
  const id = selfId(req);
  ok(res, await adminService.removeChild(id, id, childId));
}

export async function assignKitHandler(req: Request, res: Response): Promise<void> {
  const { childId } = childIdParamSchema.parse(req.params);
  const input = assignKitSchema.parse(req.body);
  const id = selfId(req);
  ok(res, await adminService.assignKit(id, id, childId, input));
}

export async function setTuitionGoalHandler(req: Request, res: Response): Promise<void> {
  const { childId } = childIdParamSchema.parse(req.params);
  const input = setTuitionGoalSchema.parse(req.body);
  const id = selfId(req);
  ok(res, await adminService.setChildGoal(id, id, childId, 'registration', input.amount));
}

export async function setTransportGoalHandler(req: Request, res: Response): Promise<void> {
  const { childId } = childIdParamSchema.parse(req.params);
  const input = setTransportGoalSchema.parse(req.body);
  const id = selfId(req);
  ok(res, await adminService.setChildGoal(id, id, childId, 'transport', input.amount, input.type));
}

export async function listContributionsHandler(req: Request, res: Response): Promise<void> {
  const id = selfId(req);
  ok(res, { data: await paymentsService.listContributions(id) });
}

export async function createContributionHandler(req: Request, res: Response): Promise<void> {
  console.log('[EduPay Backend] 📥 POST /parents/me/contributions body=', JSON.stringify(req.body));
  try {
    const input = selfContributionSchema.parse(req.body);
    const id = selfId(req);
    console.log('[EduPay Backend] ✅ Validation OK, parentId=', id, 'amount=', input.amount, 'method=', input.method, 'targetGoalType=', input.targetGoalType);
    const result = await paymentsService.initiateContribution(id, id, input.amount, input.method, undefined, idempotencyKey(req), input.targetGoalType);
    console.log('[EduPay Backend] ✅ Cotisation créée:', JSON.stringify(result));
    ok(res, result);
  } catch (err) {
    console.error('[EduPay Backend] ❌ Erreur createContribution:', err);
    throw err;
  }
}

export async function listRefundsHandler(req: Request, res: Response): Promise<void> {
  ok(res, { data: await refundsService.listMyRefunds(selfId(req)) });
}

export async function requestRefundHandler(req: Request, res: Response): Promise<void> {
  const input = requestRefundSchema.parse(req.body);
  ok(res, await refundsService.requestRefund(selfId(req), input));
}
