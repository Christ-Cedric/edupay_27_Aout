import type { Request, Response } from 'express';
import { listPaymentGateways, updatePaymentGateway } from './payment-gateway.service.js';
import { ok } from '../../shared/http/respond.js';
import { z } from 'zod';

const updateGatewaySchema = z.object({
  is_active: z.boolean().optional(),
  is_sandbox: z.boolean().optional(),
  api_key: z.string().optional(),
  auth_token: z.string().optional(),
  webhook_secret: z.string().optional(),
  base_url: z.string().url().optional(),
});

export async function listPaymentGatewaysHandler(_req: Request, res: Response): Promise<void> {
  const gateways = await listPaymentGateways();
  ok(res, { data: gateways });
}

export async function updatePaymentGatewayHandler(req: Request, res: Response): Promise<void> {
  const name = String(req.params.name);
  const input = updateGatewaySchema.parse(req.body);
  const updated = await updatePaymentGateway(name, input);
  ok(res, { data: updated });
}
