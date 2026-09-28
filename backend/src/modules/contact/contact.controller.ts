import type { Request, Response } from 'express';
import { contactInquirySchema } from './contact.schemas.js';
import { submitContactInquiry } from './contact.service.js';
import { ok } from '../../shared/http/respond.js';

export async function submitContactHandler(req: Request, res: Response): Promise<void> {
  const input = contactInquirySchema.parse(req.body);
  const ip = typeof req.ip === 'string' ? req.ip : undefined;
  const userAgent = typeof req.headers['user-agent'] === 'string' ? req.headers['user-agent'] : undefined;

  const result = await submitContactInquiry(input, ip, userAgent);
  ok(res, result);
}
