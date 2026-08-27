import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { created, list, noContent, ok } from '../../shared/http/respond.js';
import { idParamSchema } from '../admin/admin.schemas.js';
import { importKitsSchema, createKitSchema, updateKitSchema } from './kits.schemas.js';
import * as kitsService from './kits.service.js';
import { importKitsCatalog } from './kits.import.service.js';

function actorId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

export async function listKitsHandler(_req: Request, res: Response): Promise<void> {
  list(res, await kitsService.listKits());
}

export async function getKitHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await kitsService.getKit(id));
}

export async function createKitHandler(req: Request, res: Response): Promise<void> {
  const input = createKitSchema.parse(req.body);
  created(res, await kitsService.createKit(actorId(req), input));
}

export async function updateKitHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const input = updateKitSchema.parse(req.body);
  ok(res, await kitsService.updateKit(actorId(req), id, input));
}

export async function deleteKitHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  await kitsService.deleteKit(actorId(req), id);
  noContent(res);
}

export async function importKitsHandler(req: Request, res: Response): Promise<void> {
  const input = importKitsSchema.parse(req.body);
  ok(res, await importKitsCatalog(actorId(req), input.file_base64));
}
