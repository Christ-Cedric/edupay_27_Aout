import type { Notification } from '@prisma/client';

export function toNotificationDto(n: Notification) {
  return {
    id: n.id,
    type: n.type,
    title: n.title,
    body: n.body,
    channel: n.channel,
    read_at: n.readAt?.toISOString() ?? null,
    sent_at: n.sentAt?.toISOString() ?? null,
    error: n.error,
    push_sent_at: n.pushSentAt?.toISOString() ?? null,
    push_error: n.pushError,
    created_at: n.createdAt.toISOString(),
  };
}
