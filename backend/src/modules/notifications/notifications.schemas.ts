import { z } from 'zod';

export const notificationIdParamSchema = z.object({
  id: z.string().min(1),
});

export const registerDeviceTokenSchema = z.object({
  token: z.string().min(1),
  platform: z.enum(['ios', 'android', 'web']).optional(),
});

export const unregisterDeviceTokenSchema = z.object({
  token: z.string().min(1),
});

export type RegisterDeviceTokenInput = z.infer<typeof registerDeviceTokenSchema>;
export type UnregisterDeviceTokenInput = z.infer<typeof unregisterDeviceTokenSchema>;
