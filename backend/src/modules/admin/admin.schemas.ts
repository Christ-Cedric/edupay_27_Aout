import { z } from 'zod';
import { paginationQuerySchema } from '../../shared/http/pagination.js';

export { paginationQuerySchema };

// Filtres de la liste des familles, alignés sur `FamilyFilter` (Flutter) :
// recherche nom/téléphone, statut famille, ville. Validé directement contre
// `req.query` (route admin) — n'y ajouter QUE des champs qu'un admin peut
// légitimement fournir depuis l'extérieur (voir `AdminFamiliesQuery`
// ci-dessous pour le filtre interne réservé au module agent).
export const familiesQuerySchema = z.object({
  search: z.string().trim().min(1).max(100).optional(),
  status: z.enum(['pendingValidation', 'active', 'lateOverdue', 'rejected']).optional(),
  city: z.string().trim().min(1).max(80).optional(),
});

/**
 * Sur-ensemble de `FamiliesQuery` avec un filtre réservé aux appels internes
 * (module agent, `GET /agent/me/families`) — délibérément PAS dans le zod
 * schema ci-dessus pour qu'aucune requête HTTP (même admin) ne puisse le
 * fournir ; seul `agent.service.ts` construit cet objet, avec l'id de
 * l'agent authentifié, jamais une valeur venue du client.
 */
export type AdminFamiliesQuery = z.infer<typeof familiesQuerySchema> & {
  assignedAgentId?: string;
};

// Un enfant à inscrire, avec son propre kit (§7 #2 du contrat : kit par
// enfant, pas par famille). Seule la photo n'est pas collectée à ce stade.
export const enrollFamilyChildSchema = z.object({
  first_name: z.string().trim().min(1),
  level: z.string().trim().optional(),
  school: z.string().trim().optional(),
  kit_id: z.string().min(1),
});

// Inscription directe d'une famille par l'admin (statut actif immédiat).
// `assigned_agent_id` : id serveur réel, désormais optionnel — une famille
// peut ne pas avoir d'agent assigné (l'écran propose des agents selon la
// ville/le quartier saisis, mais l'admin peut laisser la famille sans
// agent s'il n'y en a pas dans sa zone). `city` en revanche est obligatoire
// (choisie dans une liste fermée de villes côté écran) — chaque famille a
// une ville explicite, indépendante de tout agent. Le plan de cotisation
// et l'agent sont au niveau du foyer ; le kit est par enfant (`children`).
// Une famille peut exister sans enfant (ex. ajoutés plus tard depuis l'app
// Client) — dans ce cas `children` est vide et l'objectif reste à 0 (aucun
// `SavingsGoal` créé), jamais un objectif « fantôme » sans enfant.
export const enrollFamilySchema = z.object({
  full_name: z.string().trim().min(2),
  phone: z.string().trim().min(8),
  plan: z.enum(['daily', 'weekly', 'monthly']),
  children: z.array(enrollFamilyChildSchema).default([]),
  assigned_agent_id: z.string().min(1).optional(),
  city: z.string().trim().min(1).max(80),
  district: z.string().trim().min(1).max(80).optional(),
  // Kit direct pour la famille (sans enfant), crée un SavingsGoal famille dès l'inscription.
  family_kit_id: z.string().min(1).optional(),
});

// Ajout d'un enfant à une famille existante — jamais de kit ici : le choix
// du kit (donc l'objectif d'épargne) est une action séparée, par saison
// (voir `assignKitSchema`). Un enfant peut légitimement exister sans kit
// pour la saison en cours (état normal en début de saison).
export const addChildSchema = z.object({
  first_name: z.string().trim().min(1),
  level: z.string().trim().optional(),
  school: z.string().trim().optional(),
});

// Changement de classe/école (chaque saison, l'enfant change de classe) —
// mise à jour partielle.
export const updateChildSchema = z
  .object({
    level: z.string().trim().min(1),
    school: z.string().trim().min(1),
  })
  .partial();

// Personnalisation d'un kit standard PAR CET ENFANT UNIQUEMENT (§ demande
// 2026-07-29) : n'affecte jamais le `Kit` partagé du catalogue admin, ni les
// autres familles ayant choisi le même kit. `added_items` référence des
// fournitures du catalogue public (`GET /catalog/articles`, `Supply.id`) ;
// `removed_items` identifie des lignes du kit de base à exclure du prix par
// (category, label) — ces deux champs n'existant pas sur `kitItemSchema`
// comme identifiant stable (voir `kits.schemas.ts`).
export const kitCustomAddedItemSchema = z.object({
  supply_id: z.string().min(1),
  quantity: z.number().int().positive(),
});

export const kitCustomRemovedItemSchema = z.object({
  category: z.string().trim().min(1),
  label: z.string().trim().min(1),
});

// Choix ou changement du kit d'un enfant POUR LA SAISON COURANTE — crée ou
// remplace le `SavingsGoal` de cet enfant pour cette saison (jamais plus
// d'un goal par enfant et par saison, contrainte `@@unique` en base).
export const assignKitSchema = z.object({
  kit_id: z.string().min(1),
  added_items: z.array(kitCustomAddedItemSchema).optional(),
  removed_items: z.array(kitCustomRemovedItemSchema).optional(),
});

// Aligné sur l'écran `new_agent_screen` (Flutter) : pas de politique stricte
// (le mot de passe est provisoire, l'agent le changera au 1er login). Le
// champ est optionnel — s'il est absent, le backend génère un mot de passe
// temporaire et le renvoie une seule fois. `contract_type` = volunteer/paid
// (modèle app), mappé vers l'enum Prisma volunteer/salaried côté service.
export const createAgentSchema = z.object({
  full_name: z.string().trim().min(2),
  phone: z.string().trim().min(8),
  zone: z.string().trim().min(1),
  district: z.string().trim().max(80).optional(),
  contract_type: z.enum(['volunteer', 'paid']).default('volunteer'),
  password: z.string().min(6).optional(),
});

export const idParamSchema = z.object({
  id: z.string().min(1),
});

// Filtre agents par zone — sert à retrouver les agents d'une ville donnée
// au moment de valider une famille (voir `approveFamilySchema` ci-dessous).
export const agentsQuerySchema = z.object({
  zone: z.string().trim().min(1).max(80).optional(),
});

// Assignation d'agent optionnelle au moment de la validation — comble le
// trou identifié en simulation : une famille auto-inscrite n'a jamais
// d'agent tant que personne ne le fait à ce moment-là.
export const approveFamilySchema = z.object({
  assigned_agent_id: z.string().min(1).optional(),
});

// Réassignation après coup (agent muté, parti, zone changée) — `null`
// explicite pour désassigner (famille repasse 100% self-service), distinct
// de "champ absent" qui ne changerait rien.
export const reassignAgentSchema = z.object({
  assigned_agent_id: z.string().min(1).nullable(),
});

// Édition des champs de base d'une famille (nom, ville, quartier) — le
// téléphone reste géré séparément (`PATCH /auth/me`, changement sensible).
export const updateFamilyProfileSchema = z
  .object({
    full_name: z.string().trim().min(2),
    city: z.string().trim().min(1).max(80),
    district: z.string().trim().min(1).max(80),
  })
  .partial();

export const childIdParamSchema = z.object({
  id: z.string().min(1),
  childId: z.string().min(1),
});

export const suspendSchema = z.object({
  reason: z.string().trim().min(1).max(500).optional(),
});

// Motif obligatoire au rejet : il est renvoyé au client (transparence).
export const rejectSchema = z.object({
  reason: z.string().trim().min(3).max(500),
});

// Signalement d'incident depuis le dossier famille (écran `ad_do`).
export const incidentSchema = z.object({
  note: z.string().trim().min(1).max(500),
});

export type CreateAgentInput = z.infer<typeof createAgentSchema>;
export type SuspendInput = z.infer<typeof suspendSchema>;
export type FamiliesQuery = z.infer<typeof familiesQuerySchema>;
export type EnrollFamilyInput = z.infer<typeof enrollFamilySchema>;
export type RejectInput = z.infer<typeof rejectSchema>;
export type IncidentInput = z.infer<typeof incidentSchema>;
export type AddChildInput = z.infer<typeof addChildSchema>;
export type UpdateChildInput = z.infer<typeof updateChildSchema>;
export type AssignKitInput = z.infer<typeof assignKitSchema>;
export type UpdateFamilyProfileInput = z.infer<typeof updateFamilyProfileSchema>;
export type AgentsQuery = z.infer<typeof agentsQuerySchema>;
export type ApproveFamilyInput = z.infer<typeof approveFamilySchema>;
export type ReassignAgentInput = z.infer<typeof reassignAgentSchema>;
