import type { KitTier, Prisma } from '@prisma/client';

type KitWithItems = Prisma.KitGetPayload<{ include: { items: true } }>;

/** Enum Prisma (basic/comfort/complete) → niveau app (basic/intermediate/premium). */
export function tierToLevel(tier: KitTier): 'basic' | 'intermediate' | 'premium' {
  return tier === 'comfort' ? 'intermediate' : tier === 'complete' ? 'premium' : 'basic';
}
export function levelToTier(level: 'basic' | 'intermediate' | 'premium'): KitTier {
  return level === 'intermediate' ? 'comfort' : level === 'premium' ? 'complete' : 'basic';
}

/**
 * DTO kit aligné sur le modèle Flutter `Kit` : { id, level, price, items[] }.
 * `price` est toujours `Σ(quantity × unit_price)` sur les fournitures —
 * calculé et stocké côté service (`kits.service.ts`), jamais saisi par
 * l'admin — jamais recalculé ici pour rester cohérent avec la valeur
 * persistée (source unique).
 */
export function toKitDto(kit: KitWithItems) {
  return {
    id: kit.id,
    level: tierToLevel(kit.tier),
    level_scope: kit.levelScope,
    price: kit.totalPrice,
    items: kit.items.map((i) => ({
      category: i.category,
      label: i.label,
      quantity: i.quantity,
      unit: i.unit,
      unit_price: i.unitPrice,
    })),
  };
}
