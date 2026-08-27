import type { Request, Response } from 'express';
import { ApiError } from '../../shared/http/api-error.js';
import { list, ok } from '../../shared/http/respond.js';
import {
  notificationIdParamSchema,
  registerDeviceTokenSchema,
  unregisterDeviceTokenSchema,
} from './notifications.schemas.js';
import * as notificationsService from './notifications.service.js';

function selfId(req: Request): string {
  if (!req.auth) throw ApiError.unauthenticated();
  return req.auth.userId;
}

export async function listNotificationsHandler(req: Request, res: Response): Promise<void> {
  list(res, await notificationsService.listForUser(selfId(req)));
}

export async function markNotificationReadHandler(req: Request, res: Response): Promise<void> {
  const { id } = notificationIdParamSchema.parse(req.params);
  ok(res, await notificationsService.markRead(selfId(req), id));
}

export async function registerDeviceTokenHandler(req: Request, res: Response): Promise<void> {
  const { token, platform } = registerDeviceTokenSchema.parse(req.body);
  await notificationsService.registerDeviceToken(selfId(req), token, platform);
  res.status(204).send();
}

export async function unregisterDeviceTokenHandler(req: Request, res: Response): Promise<void> {
  const { token } = unregisterDeviceTokenSchema.parse(req.body);
  await notificationsService.unregisterDeviceToken(selfId(req), token);
  res.status(204).send();
}
