import { Router } from 'express';
import { asyncHandler } from '../../shared/http/async-handler.js';
import {
  approveRefundHandler,
  getRefundHandler,
  listRefundsHandler,
  rejectRefundHandler,
} from './refunds.controller.js';

// Sous-routeur monté sous /admin/refunds (auth admin appliquée par le parent).
export const refundsRouter = Router();

refundsRouter.get('/', asyncHandler(listRefundsHandler));
refundsRouter.get('/:id', asyncHandler(getRefundHandler));
refundsRouter.post('/:id/approve', asyncHandler(approveRefundHandler));
refundsRouter.post('/:id/reject', asyncHandler(rejectRefundHandler));
