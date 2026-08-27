import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import {
  createSeasonHandler,
  getSeasonHandler,
  listSeasonsHandler,
  setCurrentSeasonHandler,
  updateSeasonHandler,
} from './seasons.controller.js';

// Sous-routeur monté sous /admin/seasons — l'auth admin + mot de passe changé
// est appliquée en amont par l'adminRouter parent.
export const seasonsRouter = Router();

seasonsRouter.get('/', asyncHandler(listSeasonsHandler));
seasonsRouter.post('/', asyncHandler(createSeasonHandler));
seasonsRouter.get('/:id', asyncHandler(getSeasonHandler));
seasonsRouter.patch('/:id', asyncHandler(updateSeasonHandler));
seasonsRouter.post('/:id/set-current', asyncHandler(setCurrentSeasonHandler));
