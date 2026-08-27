import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { toSupplyDto } from './supplies.serializer.js';
import type { CreateSupplyInput, UpdateSupplyInput } from './supplies.schemas.js';

async function getSupplyOrThrow(id: string) {
  const supply = await prisma.supply.findUnique({ where: { id } });
  if (!supply) throw ApiError.notFound('Fourniture introuvable.');
  return supply;
}

export async function listSupplies() {
  const supplies = await prisma.supply.findMany({ orderBy: [{ category: 'asc' }, { label: 'asc' }] });
  return supplies.map(toSupplyDto);
}

export async function getSupply(id: string) {
  return toSupplyDto(await getSupplyOrThrow(id));
}

export async function createSupply(actorId: string, input: CreateSupplyInput) {
  const supply = await prisma.$transaction(async (tx) => {
    const created = await tx.supply.create({
      data: {
        category: input.category,
        label: input.label,
        unit: input.unit,
        unitPrice: input.unit_price,
      },
    });
    await writeAudit(tx, {
      actorId,
      action: 'supply.created',
      entity: 'supply',
      entityId: created.id,
      after: { label: input.label, unit_price: input.unit_price },
    });
    return created;
  });
  return toSupplyDto(supply);
}

export async function updateSupply(actorId: string, id: string, input: UpdateSupplyInput) {
  const existing = await getSupplyOrThrow(id);
  const supply = await prisma.$transaction(async (tx) => {
    const updated = await tx.supply.update({
      where: { id },
      data: {
        ...(input.category !== undefined ? { category: input.category } : {}),
        ...(input.label !== undefined ? { label: input.label } : {}),
        ...(input.unit !== undefined ? { unit: input.unit } : {}),
        ...(input.unit_price !== undefined ? { unitPrice: input.unit_price } : {}),
      },
    });
    await writeAudit(tx, {
      actorId,
      action: 'supply.updated',
      entity: 'supply',
      entityId: id,
      before: { label: existing.label, unit_price: existing.unitPrice },
      after: { label: updated.label, unit_price: updated.unitPrice },
    });
    return updated;
  });
  return toSupplyDto(supply);
}

export async function deleteSupply(actorId: string, id: string) {
  const existing = await getSupplyOrThrow(id);
  // Pas de FK depuis KitItem (§ commentaire du modèle Prisma) : suppression
  // toujours sûre, aucun kit existant n'en dépend.
  await prisma.$transaction(async (tx) => {
    await tx.supply.delete({ where: { id } });
    await writeAudit(tx, {
      actorId,
      action: 'supply.deleted',
      entity: 'supply',
      entityId: id,
      before: { label: existing.label },
    });
  });
}
