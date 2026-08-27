import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { noContent, ok } from '../../shared/http/respond.js';
import { idParamSchema } from '../admin/admin.schemas.js';
import * as refundsService from './refunds.service.js';

function actorId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

export async function listRefundsHandler(_req: Request, res: Response): Promise<void> {
  ok(res, await refundsService.listRefunds());
}

export async function getRefundHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await refundsService.getRefundById(id));
}

export async function approveRefundHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  await refundsService.approveRefund(actorId(req), id);
  noContent(res);
}

export async function rejectRefundHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  await refundsService.rejectRefund(actorId(req), id);
  noContent(res);
}
