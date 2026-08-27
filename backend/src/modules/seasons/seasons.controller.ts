import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { created, list, ok } from '../../shared/http/respond.js';
import { idParamSchema } from '../admin/admin.schemas.js';
import { createSeasonSchema, updateSeasonSchema } from './seasons.schemas.js';
import * as seasonsService from './seasons.service.js';

function actorId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

export async function listSeasonsHandler(_req: Request, res: Response): Promise<void> {
  list(res, await seasonsService.listSeasons());
}

export async function getSeasonHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await seasonsService.getSeason(id));
}

export async function createSeasonHandler(req: Request, res: Response): Promise<void> {
  const input = createSeasonSchema.parse(req.body);
  created(res, await seasonsService.createSeason(actorId(req), input));
}

export async function updateSeasonHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  const input = updateSeasonSchema.parse(req.body);
  ok(res, await seasonsService.updateSeason(actorId(req), id, input));
}

export async function setCurrentSeasonHandler(req: Request, res: Response): Promise<void> {
  const { id } = idParamSchema.parse(req.params);
  ok(res, await seasonsService.setCurrentSeason(actorId(req), id));
}
