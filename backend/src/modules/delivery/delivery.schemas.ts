import { z } from 'zod';
import type { DeliveryIssueType, DeliveryStatus } from '@prisma/client';

const deliveryStatusInputValues = [
  'preparation',
  'shipped',
  'out_for_delivery',
  'outForDelivery',
  'delivered',
  'receipt_confirmed',
  'receiptConfirmed',
] as const;

const deliveryStatusByApiCode: Record<(typeof deliveryStatusInputValues)[number], DeliveryStatus> = {
  preparation: 'preparation',
  shipped: 'shipped',
  out_for_delivery: 'outForDelivery',
  outForDelivery: 'outForDelivery',
  delivered: 'delivered',
  receipt_confirmed: 'receiptConfirmed',
  receiptConfirmed: 'receiptConfirmed',
};

export const deliveryStatusInputSchema = z
  .enum(deliveryStatusInputValues)
  .transform((status) => deliveryStatusByApiCode[status]);

const deliveryIssueTypeInputValues = [
  'not_received',
  'notReceived',
  'missing_item',
  'missingItem',
  'damaged_item',
  'damagedItem',
  'late_delivery',
  'lateDelivery',
  'other',
] as const;

const deliveryIssueTypeByApiCode: Record<(typeof deliveryIssueTypeInputValues)[number], DeliveryIssueType> = {
  not_received: 'notReceived',
  notReceived: 'notReceived',
  missing_item: 'missingItem',
  missingItem: 'missingItem',
  damaged_item: 'damagedItem',
  damagedItem: 'damagedItem',
  late_delivery: 'lateDelivery',
  lateDelivery: 'lateDelivery',
  other: 'other',
};

const deliveryIssueTypeInputSchema = z
  .enum(deliveryIssueTypeInputValues)
  .transform((type) => deliveryIssueTypeByApiCode[type]);

// Confirmation par le parent (self-service) — signature manuscrite capturée
// sur son propre appareil, même contrainte de taille que `confirmByAgentSchema`.
export const confirmReceiptSchema = z.object({
  signature: z.string().min(1).max(500_000).optional(),
});

export const sendLocationSchema = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  address: z.string().trim().min(1).max(200),
});

export const reportIssueSchema = z.object({
  child_id: z.string().min(1),
  type: deliveryIssueTypeInputSchema,
  description: z.string().trim().min(1).max(1000),
  photo_url: z.string().url().optional(),
});

// Avance d'un cran la livraison d'UN enfant (agent/admin) — pas de retour
// arrière (même règle que le backend Client audité).
export const advanceStatusSchema = z.object({
  to: z
    .enum(['shipped', 'out_for_delivery', 'outForDelivery', 'delivered'])
    .transform((status): DeliveryStatus => (status === 'out_for_delivery' ? 'outForDelivery' : status)),
});

// Confirmation par l'agent sur le terrain, signature capturée sur son propre
// appareil — chemin alternatif à `confirmReceipt` (parent, self-service).
// Les deux champs restent optionnels (même souplesse que le backend Agent
// terrain de référence : parfois seule une note est possible, ex. zone sans
// réseau au moment de la signature).
export const confirmByAgentSchema = z.object({
  signature: z.string().min(1).max(500_000).optional(),
  notes: z.string().trim().max(500).optional(),
});

// Planification (« livraisons du jour ») — posée par l'agent ou l'admin.
export const scheduleDeliverySchema = z.object({
  scheduled_at: z.string().datetime(),
});

export type ConfirmReceiptInput = z.infer<typeof confirmReceiptSchema>;
export type SendLocationInput = z.infer<typeof sendLocationSchema>;
export type ReportIssueInput = z.infer<typeof reportIssueSchema>;
export type AdvanceStatusInput = z.infer<typeof advanceStatusSchema>;
export type ConfirmByAgentInput = z.infer<typeof confirmByAgentSchema>;
export type ScheduleDeliveryInput = z.infer<typeof scheduleDeliverySchema>;
