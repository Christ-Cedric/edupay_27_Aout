import { z } from 'zod';

export const createVehicleSchema = z.object({
  name: z.string().trim().min(2, 'Le nom de l\'engin doit contenir au moins 2 caractères.'),
  description: z.string().trim().optional().nullable(),
  price: z.number().int().min(0, 'Le prix doit être un entier positif.'),
  images: z.array(z.string()).optional().default([]),
  is_available: z.boolean().optional().default(true),
});

export const updateVehicleSchema = z.object({
  name: z.string().trim().min(2).optional(),
  description: z.string().trim().optional().nullable(),
  price: z.number().int().min(0).optional(),
  images: z.array(z.string()).optional(),
  is_available: z.boolean().optional(),
});

export type CreateVehicleInput = z.infer<typeof createVehicleSchema>;
export type UpdateVehicleInput = z.infer<typeof updateVehicleSchema>;
