import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import {
  createVehicleHandler,
  deleteVehicleHandler,
  getVehicleHandler,
  listVehiclesHandler,
  updateVehicleHandler,
} from './vehicles.controller.js';

// Routeur pour la gestion des moyens de déplacement
export const vehiclesAdminRouter = Router();
export const vehiclesPublicRouter = Router();

// Routes publiques / Client
vehiclesPublicRouter.get('/', asyncHandler(listVehiclesHandler));
vehiclesPublicRouter.get('/:id', asyncHandler(getVehicleHandler));

// Routes d'administration
vehiclesAdminRouter.get('/', asyncHandler(listVehiclesHandler));
vehiclesAdminRouter.post('/', asyncHandler(createVehicleHandler));
vehiclesAdminRouter.get('/:id', asyncHandler(getVehicleHandler));
vehiclesAdminRouter.put('/:id', asyncHandler(updateVehicleHandler));
vehiclesAdminRouter.delete('/:id', asyncHandler(deleteVehicleHandler));
