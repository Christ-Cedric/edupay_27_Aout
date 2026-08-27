import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import { articlesHandler, kitsHandler, plansHandler } from './catalog.controller.js';

// Public, sans authentification — un prospect peut consulter le catalogue
// avant de s'inscrire (§ contrat, comportement du backend Client repris).
export const catalogRouter = Router();

catalogRouter.get('/kits', asyncHandler(kitsHandler));
catalogRouter.get('/articles', asyncHandler(articlesHandler));
catalogRouter.get('/plans', asyncHandler(plansHandler));
