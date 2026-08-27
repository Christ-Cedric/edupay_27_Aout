import { z } from 'zod';

// Écran (à venir) « Enregistrer un encaissement » — cash uniquement pour
// l'admin ; le mobile money passera par LigdiCash côté app Client/Agent, pas
// par cet endpoint (contrat §5.3/§5.4 à confirmer entre équipes).
export const recordCashContributionSchema = z.object({
  amount: z.number().int().positive(),
  collected_by_agent_id: z.string().min(1).optional(),
  targetGoalType: z.enum(['supplies', 'registration', 'exam', 'transport', 'canteen', 'uniform']).optional(),
});

export type RecordCashContributionInput = z.infer<typeof recordCashContributionSchema>;

// Cotisation self-service (app Client, `POST /parents/me/contributions`) —
// mobile money uniquement (le cash passe par l'agent, `recordCashContributionSchema`
// ci-dessus). `orangeMoney`/`moovMoney` reprend tel quel le nom d'enum Prisma
// déjà exposé sur le wire par `toContributionDto` (`method: c.method`,
// jamais transformé en snake_case) — cohérent avec l'existant plutôt qu'une
// nouvelle convention isolée sur cette seule route.
export const selfContributionSchema = z.object({
  amount: z.number().int().positive(),
  method: z.enum(['orangeMoney', 'moovMoney', 'wave']),
  targetGoalType: z.enum(['supplies', 'registration', 'exam', 'transport', 'canteen', 'uniform']).optional(),
});

export type SelfContributionInput = z.infer<typeof selfContributionSchema>;
