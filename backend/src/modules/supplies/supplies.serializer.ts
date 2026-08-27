import type { Supply } from '@prisma/client';

export function toSupplyDto(supply: Supply) {
  return {
    id: supply.id,
    category: supply.category,
    label: supply.label,
    unit: supply.unit,
    unit_price: supply.unitPrice,
  };
}
