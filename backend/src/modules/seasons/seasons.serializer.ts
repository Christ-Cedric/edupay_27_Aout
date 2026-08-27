import type { Season } from '@prisma/client';

/** DTO saison en snake_case (contrat §1). Montants en FCFA entiers. */
export function toSeasonDto(s: Season) {
  return {
    id: s.id,
    label: s.label,
    launch_date: s.launchDate.toISOString(),
    delivery_deadline: s.deliveryDeadline.toISOString(),
    enrollment_open: s.enrollmentOpen,
    refund_fee: s.refundFee,
    is_current: s.isCurrent,
  };
}
