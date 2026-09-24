import type { Request, Response } from 'express';
import { createVehicleSchema, updateVehicleSchema } from './vehicles.schemas.js';
import {
  createVehicle,
  deleteVehicle,
  getVehicle,
  listVehicles,
  updateVehicle,
} from './vehicles.service.js';

export async function listVehiclesHandler(req: Request, res: Response): Promise<void> {
  const onlyAvailable = req.query.available === 'true';
  const vehicles = await listVehicles(onlyAvailable);
  res.json({ data: vehicles });
}

export async function getVehicleHandler(req: Request, res: Response): Promise<void> {
  const vehicle = await getVehicle(req.params.id!);
  res.json({ data: vehicle });
}

export async function createVehicleHandler(req: Request, res: Response): Promise<void> {
  const actorId = (req as any).user?.id ?? 'system';
  const input = createVehicleSchema.parse(req.body);
  const vehicle = await createVehicle(actorId, input);
  res.status(201).json({ data: vehicle });
}

export async function updateVehicleHandler(req: Request, res: Response): Promise<void> {
  const actorId = (req as any).user?.id ?? 'system';
  const input = updateVehicleSchema.parse(req.body);
  const vehicle = await updateVehicle(actorId, req.params.id!, input);
  res.json({ data: vehicle });
}

export async function deleteVehicleHandler(req: Request, res: Response): Promise<void> {
  const actorId = (req as any).user?.id ?? 'system';
  await deleteVehicle(actorId, req.params.id!);
  res.status(204).send();
}
