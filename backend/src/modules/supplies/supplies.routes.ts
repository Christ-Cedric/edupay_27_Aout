import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import {
  createSupplyHandler,
  deleteSupplyHandler,
  getSupplyHandler,
  listSuppliesHandler,
  updateSupplyHandler,
} from './supplies.controller.js';

// Sous-routeur monté sous /admin/supplies (auth admin appliquée par le
// parent). Catalogue de fournitures réutilisable, indépendant des saisons.
export const suppliesRouter = Router();

suppliesRouter.get('/', asyncHandler(listSuppliesHandler));
suppliesRouter.post('/', asyncHandler(createSupplyHandler));
suppliesRouter.get('/:id', asyncHandler(getSupplyHandler));
suppliesRouter.put('/:id', asyncHandler(updateSupplyHandler));
suppliesRouter.delete('/:id', asyncHandler(deleteSupplyHandler));
