import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import {
  createKitHandler,
  deleteKitHandler,
  getKitHandler,
  importKitsHandler,
  listKitsHandler,
  updateKitHandler,
} from './kits.controller.js';

// Sous-routeur monté sous /admin/kits (auth admin appliquée par le parent).
// Aligné sur le seam Flutter `RestKitDataSource` : GET liste, GET détail,
// PUT (remplacement), DELETE. POST create conservé pour l'amorçage catalogue.
// POST /import (avant /:id pour ne pas être capturé comme un id) : import en
// masse du catalogue fournisseur depuis un fichier Excel.
export const kitsRouter = Router();

kitsRouter.get('/', asyncHandler(listKitsHandler));
kitsRouter.post('/', asyncHandler(createKitHandler));
kitsRouter.post('/import', asyncHandler(importKitsHandler));
kitsRouter.get('/:id', asyncHandler(getKitHandler));
kitsRouter.put('/:id', asyncHandler(updateKitHandler));
kitsRouter.delete('/:id', asyncHandler(deleteKitHandler));
