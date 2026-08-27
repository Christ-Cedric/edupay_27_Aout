import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { ok } from '../../shared/http/respond.js';
import * as deliveryService from './delivery.service.js';
import { confirmReceiptSchema, reportIssueSchema, sendLocationSchema } from './delivery.schemas.js';

function selfId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

export async function getDeliveriesHandler(req: Request, res: Response): Promise<void> {
  ok(res, { data: await deliveryService.getDeliveries(selfId(req)) });
}

export async function sendLocationHandler(req: Request, res: Response): Promise<void> {
  const input = sendLocationSchema.parse(req.body);
  ok(res, { data: await deliveryService.sendLocation(selfId(req), input) });
}

export async function confirmReceiptHandler(req: Request, res: Response): Promise<void> {
  const input = confirmReceiptSchema.parse(req.body ?? {});
  ok(res, { data: await deliveryService.confirmReceipt(selfId(req), input.signature) });
}

export async function reportIssueHandler(req: Request, res: Response): Promise<void> {
  const input = reportIssueSchema.parse(req.body);
  ok(res, await deliveryService.reportIssue(selfId(req), input));
}
