import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { created, list, noContent, ok } from '../../shared/http/respond.js';
import { idParamSchema } from '../admin/admin.schemas.js';
import { createSupplySchema, updateSupplySchema } from './supplies.schemas.js';
import * as suppliesService from './supplies.service.js';

function actorId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

export async function listSuppliesHandler(_req: Request, res: Response): Promise<void> {
  list(res, await suppliesService.listSupplies());
}

export async function getSupplyHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await suppliesService.getSupply(id));
}

export async function createSupplyHandler(req: Request, res: Response): Promise<void> {
  const input = createSupplySchema.parse(req.body);
  created(res, await suppliesService.createSupply(actorId(req), input));
}

export async function updateSupplyHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const input = updateSupplySchema.parse(req.body);
  ok(res, await suppliesService.updateSupply(actorId(req), id, input));
}

export async function deleteSupplyHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  await suppliesService.deleteSupply(actorId(req), id);
  noContent(res);
}
