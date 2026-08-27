import { z } from 'zod';

export const requestRefundSchema = z.object({
  reason: z.string().trim().min(1).max(500),
});

export type RequestRefundInput = z.infer<typeof requestRefundSchema>;
