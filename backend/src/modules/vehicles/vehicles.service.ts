import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { toVehicleDto, type VehicleDto } from './vehicles.serializer.js';
import type { CreateVehicleInput, UpdateVehicleInput } from './vehicles.schemas.js';

async function getVehicleOrThrow(id: string) {
  const vehicle = await prisma.transportVehicle.findUnique({ where: { id } });
  if (!vehicle) throw ApiError.notFound('Moyen de déplacement introuvable.');
  return vehicle;
}

const DEFAULT_VEHICLES = [
  {
    name: 'Moto Yamaha YBR 125',
    description: 'Moto solide et économe, idéale pour le transport des enfants et déplacements professionnels.',
    price: 650000,
    images: ['https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600'],
    isAvailable: true,
  },
  {
    name: 'Vélo Tout-Terrain (VTT) Junior',
    description: 'Vélo robuste équipé pour la piste, adapté aux élèves de collège et lycée.',
    price: 95000,
    images: ['https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=600'],
    isAvailable: true,
  },
  {
    name: 'Tricycle KAVAKI Cargo 200cc',
    description: 'Engin 3 roues grand volume pour le transport familial et marchandises.',
    price: 1200000,
    images: ['https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600'],
    isAvailable: true,
  },
];

export async function listVehicles(onlyAvailable = false): Promise<VehicleDto[]> {
  const where = onlyAvailable ? { isAvailable: true } : {};
  let vehicles = await prisma.transportVehicle.findMany({
    where,
    orderBy: { createdAt: 'desc' },
  });

  if (vehicles.length === 0) {
    try {
      await prisma.transportVehicle.createMany({
        data: DEFAULT_VEHICLES,
      });
      vehicles = await prisma.transportVehicle.findMany({
        where,
        orderBy: { createdAt: 'desc' },
      });
    } catch (_) {
      // Best-effort auto-seed
    }
  }

  return vehicles.map(toVehicleDto);
}

export async function getVehicle(id: string): Promise<VehicleDto> {
  const vehicle = await getVehicleOrThrow(id);
  return toVehicleDto(vehicle);
}

export async function createVehicle(actorId: string, input: CreateVehicleInput): Promise<VehicleDto> {
  const vehicle = await prisma.$transaction(async (tx) => {
    const created = await tx.transportVehicle.create({
      data: {
        name: input.name,
        description: input.description ?? null,
        price: input.price,
        images: input.images ?? [],
        isAvailable: input.is_available ?? true,
      },
    });

    await writeAudit(tx, {
      actorId,
      action: 'vehicle.created',
      entity: 'transport_vehicle',
      entityId: created.id,
      after: { name: input.name, price: input.price },
    });

    return created;
  });

  return toVehicleDto(vehicle);
}

export async function updateVehicle(actorId: string, id: string, input: UpdateVehicleInput): Promise<VehicleDto> {
  const existing = await getVehicleOrThrow(id);

  const vehicle = await prisma.$transaction(async (tx) => {
    const updated = await tx.transportVehicle.update({
      where: { id },
      data: {
        ...(input.name !== undefined ? { name: input.name } : {}),
        ...(input.description !== undefined ? { description: input.description } : {}),
        ...(input.price !== undefined ? { price: input.price } : {}),
        ...(input.images !== undefined ? { images: input.images } : {}),
        ...(input.is_available !== undefined ? { isAvailable: input.is_available } : {}),
      },
    });

    await writeAudit(tx, {
      actorId,
      action: 'vehicle.updated',
      entity: 'transport_vehicle',
      entityId: id,
      before: { name: existing.name, price: existing.price, isAvailable: existing.isAvailable },
      after: { name: updated.name, price: updated.price, isAvailable: updated.isAvailable },
    });

    return updated;
  });

  return toVehicleDto(vehicle);
}

export async function deleteVehicle(actorId: string, id: string): Promise<void> {
  const existing = await getVehicleOrThrow(id);

  await prisma.$transaction(async (tx) => {
    await tx.transportVehicle.delete({ where: { id } });

    await writeAudit(tx, {
      actorId,
      action: 'vehicle.deleted',
      entity: 'transport_vehicle',
      entityId: id,
      before: { name: existing.name },
    });
  });
}
