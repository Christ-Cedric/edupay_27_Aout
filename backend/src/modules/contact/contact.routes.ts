import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import { submitContactHandler } from './contact.controller.js';

export const contactRouter = Router();

// Route publique pour le formulaire de contact du site web officiel
contactRouter.post('/', asyncHandler(submitContactHandler));
