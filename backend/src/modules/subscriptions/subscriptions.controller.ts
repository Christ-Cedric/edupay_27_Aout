import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { ok } from '../../shared/http/respond.js';
import { confirmSubscriptionSchema, previewChildSchema } from './subscriptions.schemas.js';
import * as subscriptionsService from './subscriptions.service.js';

function selfId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

export async function previewChildHandler(req: Request, res: Response): Promise<void> {
  const { kit_id } = previewChildSchema.parse(req.body);
  ok(res, await subscriptionsService.previewChildForKit(selfId(req), kit_id));
}

export async function confirmSubscriptionHandler(req: Request, res: Response): Promise<void> {
  const { frequency, signature } = confirmSubscriptionSchema.parse(req.body);
  ok(res, await subscriptionsService.confirmSubscription(selfId(req), frequency, signature));
}
