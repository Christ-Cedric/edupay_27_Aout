import { z } from 'zod';
import { deliveryStatusInputSchema } from '../delivery/delivery.schemas.js';

export const agentContributionSchema = z.object({
  amount: z.number().int().positive(),
  targetGoalType: z.enum(['supplies', 'registration', 'exam', 'transport', 'canteen', 'uniform']).optional(),
});

export const familyIdParamSchema = z.object({
  id: z.string().min(1),
});

export const deliveryIdParamSchema = z.object({
  id: z.string().min(1),
});

export const familyCodeParamSchema = z.object({
  code: z.string().min(1),
});

export const contributionIdParamSchema = z.object({
  id: z.string().min(1),
});

export const agentSetGoalSchema = z.object({
  amount: z.number().int().positive(),
  name: z.string().optional(),
});

export const agentSetSchoolingGoalSchema = z.object({
  amount: z.number().int().positive(),
  name: z.string().optional(),
  frequency: z.enum(['daily', 'weekly', 'monthly']),
  capacity: z.number().int().positive(),
});

export const agentRefundSchema = z.object({
  amount: z.number().int().positive(),
  reason: z.string().min(1),
});


// Filtres liste familles — sur-ensemble volontairement restreint de
// `familiesQuerySchema` (admin) : un agent ne doit filtrer que par statut,
// jamais par ville/recherche globale (il ne voit déjà que ses familles).
export const agentFamiliesQuerySchema = z.object({
  status: z.enum(['pendingValidation', 'active', 'lateOverdue', 'rejected']).optional(),
});

export const agentDeliveriesQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Format attendu : YYYY-MM-DD.')
    .optional(),
  status: deliveryStatusInputSchema.optional(),
});

// Profil agent (auto-édition) — pas de changement de zone/agence sans
// justification métier plus poussée, donc limité à ce qu'un agent peut
// légitimement corriger lui-même.
export const updateAgentProfileSchema = z
  .object({
    full_name: z.string().trim().min(2),
    zone: z.string().trim().min(1),
    district: z.string().trim().min(1).max(80),
  })
  .partial();

export type AgentContributionInput = z.infer<typeof agentContributionSchema>;
export type AgentFamiliesQuery = z.infer<typeof agentFamiliesQuerySchema>;
export type AgentDeliveriesQuery = z.infer<typeof agentDeliveriesQuerySchema>;
export type UpdateAgentProfileInput = z.infer<typeof updateAgentProfileSchema>;
