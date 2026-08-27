import type { Delivery, DeliveryIssue, DeliveryStatus } from '@prisma/client';

const STATUS_CODE: Record<DeliveryStatus, string> = {
  preparation: 'preparation',
  shipped: 'shipped',
  outForDelivery: 'out_for_delivery',
  delivered: 'delivered',
  receiptConfirmed: 'receipt_confirmed',
};

const ISSUE_TYPE_CODE: Record<DeliveryIssue['type'], string> = {
  notReceived: 'not_received',
  missingItem: 'missing_item',
  damagedItem: 'damaged_item',
  lateDelivery: 'late_delivery',
  other: 'other',
};

type DeliveryWithIssues = Delivery & { issues: DeliveryIssue[] };

export function toDeliveryDto(d: DeliveryWithIssues) {
  return {
    id: d.id,
    child_id: d.childId,
    kit_id: d.kitId,
    status: STATUS_CODE[d.status],
    location:
      d.locationLat != null && d.locationLng != null
        ? { lat: d.locationLat, lng: d.locationLng, address: d.address ?? '' }
        : null,
    signed_at: d.signedAt?.toISOString() ?? null,
    scheduled_at: d.scheduledAt?.toISOString() ?? null,
    signature: d.signature,
    issues: d.issues.map(toDeliveryIssueDto),
  };
}

export function toDeliveryIssueDto(i: DeliveryIssue) {
  return {
    id: i.id,
    type: ISSUE_TYPE_CODE[i.type],
    description: i.description,
    photo_url: i.photoUrl,
    status: i.status,
    created_at: i.createdAt.toISOString(),
  };
}
