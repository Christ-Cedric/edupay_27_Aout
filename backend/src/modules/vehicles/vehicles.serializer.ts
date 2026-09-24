import type { TransportVehicle } from '@prisma/client';

export interface VehicleDto {
  id: string;
  name: string;
  description: string | null;
  price: number;
  images: string[];
  is_available: boolean;
  created_at: string;
  updated_at: string;
}

export function toVehicleDto(vehicle: TransportVehicle): VehicleDto {
  let parsedImages: string[] = [];
  if (Array.isArray(vehicle.images)) {
    parsedImages = vehicle.images.map(img => String(img));
  } else if (typeof vehicle.images === 'string') {
    try {
      parsedImages = JSON.parse(vehicle.images);
    } catch (_) {
      parsedImages = [vehicle.images];
    }
  }

  return {
    id: vehicle.id,
    name: vehicle.name,
    description: vehicle.description ?? null,
    price: vehicle.price,
    images: parsedImages,
    is_available: vehicle.isAvailable,
    created_at: vehicle.createdAt.toISOString(),
    updated_at: vehicle.updatedAt.toISOString(),
  };
}
