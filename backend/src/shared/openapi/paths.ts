import { z } from 'zod';
import { registry, bearerAuth } from './registry.js';
import {
  ActiveSessionDto,
  AddChildPreviewDto,
  AgentCommissionDto,
  AgentDashboardDto,
  AgentDto,
  AuditLogDto,
  CollectionDto,
  ContributionDto,
  DashboardDto,
  DirectorContactDto,
  FamilyDto,
  DeliveryDto,
  DeliveryIssueDto,
  ImportKitsSummaryDto,
  KitDto,
  LedgerEntryDto,
  NotificationDto,
  OtpRequestResponseDto,
  OtpVerifyResponseDto,
  RefundDetailDto,
  RefundsResponse,
  SeasonDto,
  SelfRefundDto,
  SendReportResponseDto,
  SessionDto,
  SubscriptionConfirmationDto,
  SupplyDto,
  UserDto,
  errorResponse,
  jsonResponse,
  paginatedResponse,
} from './components.js';
import {
  recordCashContributionSchema,
  selfContributionSchema,
} from '../../modules/payments/payments.schemas.js';
import {
  createSeasonSchema,
  updateSeasonSchema,
} from '../../modules/seasons/seasons.schemas.js';
import {
  createKitSchema,
  importKitsSchema,
  updateKitSchema,
} from '../../modules/kits/kits.schemas.js';
import {
  createSupplySchema,
  updateSupplySchema,
} from '../../modules/supplies/supplies.schemas.js';
import {
  loginSchema,
  passwordChangeSchema,
  passwordForgotSchema,
  passwordResetSchema,
  refreshSchema,
  registerSchema,
  requestOtpSchema,
  updateMeSchema,
  verifyOtpSchema,
} from '../../modules/auth/auth.schemas.js';
import { updateProfileSchema } from '../../modules/parents/parents.schemas.js';
import {
  confirmSubscriptionSchema,
  previewChildSchema,
} from '../../modules/subscriptions/subscriptions.schemas.js';
import {
  registerDeviceTokenSchema,
  unregisterDeviceTokenSchema,
} from '../../modules/notifications/notifications.schemas.js';
import {
  agentContributionSchema,
  agentDeliveriesQuerySchema,
  agentFamiliesQuerySchema,
  familyCodeParamSchema,
  updateAgentProfileSchema,
} from '../../modules/agent/agent.schemas.js';
import { requestRefundSchema } from '../../modules/refunds/refunds.schemas.js';
import {
  advanceStatusSchema,
  confirmByAgentSchema,
  reportIssueSchema,
  scheduleDeliverySchema,
  sendLocationSchema,
} from '../../modules/delivery/delivery.schemas.js';
import {
  addChildSchema,
  agentsQuerySchema,
  approveFamilySchema,
  assignKitSchema,
  createAgentSchema,
  enrollFamilySchema,
  incidentSchema,
  reassignAgentSchema,
  rejectSchema,
  suspendSchema,
  updateChildSchema,
  updateFamilyProfileSchema,
} from '../../modules/admin/admin.schemas.js';

/** Paramètre de chemin `:id`. */
const idPathParam = z.object({
  id: z.string().openapi({ param: { name: 'id', in: 'path' }, example: 'clx123abc' }),
});

/** Paramètres de chemin `:id/children/:childId`. */
const childIdPathParam = z.object({
  id: z.string().openapi({ param: { name: 'id', in: 'path' }, example: 'clx123abc' }),
  childId: z.string().openapi({ param: { name: 'childId', in: 'path' }, example: 'clx456def' }),
});

/** Self-service parent : `:childId` seul, la famille est `req.auth.userId`. */
const childOnlyPathParam = z.object({
  childId: z.string().openapi({ param: { name: 'childId', in: 'path' }, example: 'clx456def' }),
});

/** Corps JSON obligatoire à partir d'un schéma zod. */
function jsonBody(schema: z.ZodTypeAny) {
  return { required: true, content: { 'application/json': { schema } } };
}

/** Paramètres de query communs aux listes paginées. */
const paginationParams = z.object({
  page: z.coerce.number().int().positive().optional().openapi({ example: 1 }),
  perPage: z.coerce.number().int().positive().max(100).optional().openapi({ example: 20 }),
  search: z.string().optional().openapi({ description: 'Filtre nom / téléphone.' }),
});

// ── Système ─────────────────────────────────────────────────────────────────
registry.registerPath({
  method: 'get',
  path: '/health',
  tags: ['Système'],
  summary: 'Sonde de vivacité',
  responses: {
    200: jsonResponse(
      'Service opérationnel.',
      z.object({ status: z.literal('ok'), time: z.string().datetime() }),
    ),
  },
});

// ── Auth (contrat §2) ─────────────────────────────────────────────────────────

// Inscription client par OTP — ne concerne QUE le rôle client (app parent) ;
// agent/admin sont provisionnés par l'admin et gardent phone + mot de passe.
registry.registerPath({
  method: 'post',
  path: '/auth/otp/request',
  tags: ['Auth'],
  summary: 'Demander un code OTP (inscription client)',
  description:
    'Toujours 200 avec un message uniforme, même si le numéro est déjà ' +
    'utilisé (anti-énumération). Limité en fréquence.',
  request: { body: jsonBody(requestOtpSchema) },
  responses: {
    200: jsonResponse('Code envoyé (dev_code présent hors production).', OtpRequestResponseDto),
    429: errorResponse('Trop de tentatives.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/auth/otp/verify',
  tags: ['Auth'],
  summary: 'Vérifier le code OTP',
  request: { body: jsonBody(verifyOtpSchema) },
  responses: {
    200: jsonResponse('Jeton d’inscription (15 min).', OtpVerifyResponseDto),
    422: errorResponse('Code invalide, expiré, ou trop de tentatives.'),
    429: errorResponse('Trop de tentatives.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/auth/register',
  tags: ['Auth'],
  summary: 'Finaliser l’inscription client',
  description:
    'Le téléphone provient du jeton d’inscription vérifié, jamais du corps ' +
    'de la requête. Le compte créé reste `pendingValidation` jusqu’à ' +
    'approbation admin (même règle que les comptes créés par un agent).',
  security: bearerAuth,
  request: { body: jsonBody(registerSchema) },
  responses: {
    200: jsonResponse('Compte créé, session émise.', SessionDto),
    401: errorResponse('Jeton d’inscription invalide ou expiré.'),
    409: errorResponse('Numéro déjà associé à un compte.'),
    429: errorResponse('Trop de tentatives.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/auth/login',
  tags: ['Auth'],
  summary: 'Connexion par téléphone + mot de passe',
  description: 'Limité en fréquence (anti brute-force) : 429 au-delà du quota.',
  request: { body: jsonBody(loginSchema) },
  responses: {
    200: jsonResponse('Session émise (paire access/refresh).', SessionDto),
    401: errorResponse('Numéro ou mot de passe incorrect.'),
    403: errorResponse('Compte désactivé (rejected/suspended).'),
    429: errorResponse('Trop de tentatives.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/auth/refresh',
  tags: ['Auth'],
  summary: 'Rotation du jeton de rafraîchissement',
  request: { body: jsonBody(refreshSchema) },
  responses: {
    200: jsonResponse('Nouvelle session ; l’ancien refresh est révoqué.', SessionDto),
    401: errorResponse('Jeton invalide ou session expirée.'),
    429: errorResponse('Trop de tentatives.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/auth/logout',
  tags: ['Auth'],
  summary: 'Révocation d’une session',
  request: { body: jsonBody(refreshSchema) },
  responses: { 204: { description: 'Session révoquée (idempotent).' } },
});

registry.registerPath({
  method: 'post',
  path: '/auth/logout-all',
  tags: ['Auth'],
  summary: 'Déconnexion de tous les appareils',
  description: 'Révoque tous les refresh tokens actifs de l’utilisateur authentifié.',
  security: bearerAuth,
  responses: {
    204: { description: 'Toutes les sessions révoquées.' },
    401: errorResponse('Authentification requise.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/auth/password/forgot',
  tags: ['Auth'],
  summary: 'Mot de passe oublié — envoie un OTP',
  description:
    'Anti-énumération stricte : 200 uniforme même si le numéro ne correspond à ' +
    'aucun compte (rien n’est écrit ni envoyé dans ce cas). Vérification via ' +
    'le même endpoint que l’inscription (`POST /auth/otp/verify`) — le type de ' +
    'jeton renvoyé dépend du code trouvé.',
  request: { body: jsonBody(passwordForgotSchema) },
  responses: {
    200: jsonResponse('Code envoyé si le numéro existe (dev_code hors production).', OtpRequestResponseDto),
    429: errorResponse('Trop de tentatives.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/auth/password/reset',
  tags: ['Auth'],
  summary: 'Réinitialise le mot de passe',
  description:
    'Bearer = `reset_token` (issu de `POST /auth/otp/verify`), pas une session ' +
    'utilisateur. Révoque toutes les sessions existantes et en émet une nouvelle.',
  security: bearerAuth,
  request: { body: jsonBody(passwordResetSchema) },
  responses: {
    200: jsonResponse('Mot de passe réinitialisé, nouvelle session émise.', SessionDto),
    401: errorResponse('Jeton de réinitialisation invalide ou expiré.'),
    404: errorResponse('Compte introuvable.'),
    429: errorResponse('Trop de tentatives.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/auth/password/change',
  tags: ['Auth'],
  summary: 'Change le mot de passe (ancien exigé)',
  description:
    'Additive — distincte de `PATCH /auth/me` (écran « Mon compte » Admin/Agent ' +
    'existant, qui ne demande pas l’ancien mot de passe). Révoque les autres sessions.',
  security: bearerAuth,
  request: { body: jsonBody(passwordChangeSchema) },
  responses: {
    200: jsonResponse('Mot de passe changé, nouvelle session émise.', SessionDto),
    401: errorResponse('Mot de passe actuel incorrect.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/auth/sessions',
  tags: ['Auth'],
  summary: 'Liste les sessions actives (appareils connectés)',
  security: bearerAuth,
  responses: { 200: jsonResponse('Sessions.', z.object({ data: z.array(ActiveSessionDto) })) },
});

registry.registerPath({
  method: 'delete',
  path: '/auth/sessions',
  tags: ['Auth'],
  summary: 'Révoque toutes les sessions (alias de /auth/logout-all)',
  security: bearerAuth,
  responses: { 204: { description: 'Toutes les sessions révoquées.' } },
});

registry.registerPath({
  method: 'delete',
  path: '/auth/sessions/{id}',
  tags: ['Auth'],
  summary: 'Révoque une session à distance',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    204: { description: 'Session révoquée.' },
    404: errorResponse('Session introuvable.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/auth/me',
  tags: ['Auth'],
  summary: 'Utilisateur courant',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Profil de l’utilisateur authentifié.', UserDto),
    401: errorResponse('Authentification requise.'),
  },
});

registry.registerPath({
  method: 'patch',
  path: '/auth/me',
  tags: ['Auth'],
  summary: 'Modifier ses identifiants (téléphone / mot de passe)',
  description:
    'Écran « Mon compte ». Au moins un champ. Un changement de mot de passe ' +
    'révoque les autres sessions ; une nouvelle paire de jetons est renvoyée.',
  security: bearerAuth,
  request: { body: jsonBody(updateMeSchema) },
  responses: {
    200: jsonResponse('Identifiants mis à jour ; nouvelle session émise.', SessionDto),
    400: errorResponse('Aucun champ fourni / données invalides.'),
    401: errorResponse('Authentification requise.'),
    409: errorResponse('Téléphone déjà utilisé.'),
  },
});

// ── Administration (contrat §5.4) — admin + mot de passe changé ───────────────
registry.registerPath({
  method: 'get',
  path: '/admin/dashboard',
  tags: ['Admin · Dashboard'],
  summary: 'Statistiques agrégées',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Indicateurs calculés en base.', DashboardDto),
    401: errorResponse('Authentification requise.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/families',
  tags: ['Admin · Familles'],
  summary: 'Lister les familles (clients)',
  description: 'Filtres : `?search`, `?status`, `?city`.',
  security: bearerAuth,
  request: {
    query: z.object({
      search: z.string().optional(),
      status: z
        .enum(['pendingValidation', 'active', 'lateOverdue', 'rejected'])
        .optional(),
      city: z.string().optional(),
    }),
  },
  responses: {
    200: jsonResponse('Familles.', z.object({ data: z.array(FamilyDto) })),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/families/pending',
  tags: ['Admin · Familles'],
  summary: 'File de validation (comptes en attente)',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Familles en attente.', z.object({ data: z.array(FamilyDto) })),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/families',
  tags: ['Admin · Familles'],
  summary: 'Inscription directe d’une famille (statut actif)',
  security: bearerAuth,
  request: { body: jsonBody(enrollFamilySchema) },
  responses: {
    201: jsonResponse('Famille inscrite.', FamilyDto),
    400: errorResponse('Kit / agent inconnu ou données invalides.'),
    409: errorResponse('Téléphone déjà utilisé.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/families/{id}',
  tags: ['Admin · Familles'],
  summary: 'Détail d’une famille',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Famille.', FamilyDto),
    404: errorResponse('Famille introuvable.'),
  },
});

registry.registerPath({
  method: 'patch',
  path: '/admin/families/{id}',
  tags: ['Admin · Familles'],
  summary: 'Modifier le profil d’une famille (nom, ville, quartier)',
  description: 'Le téléphone reste géré séparément (changement sensible, hors cette route).',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(updateFamilyProfileSchema) },
  responses: {
    200: jsonResponse('Famille mise à jour.', FamilyDto),
    400: errorResponse('Aucun champ fourni.'),
    404: errorResponse('Famille introuvable.'),
  },
});

registry.registerPath({
  method: 'delete',
  path: '/admin/families/{id}',
  tags: ['Admin · Familles'],
  summary: 'Archiver une famille',
  description:
    'Bascule le compte sur `suspended` (bloque mouvements d’argent et livraisons) et révoque ses ' +
    'sessions actives. Pas de réactivation prévue pour l’instant.',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Famille archivée.', FamilyDto),
    404: errorResponse('Famille introuvable.'),
    409: errorResponse('Famille déjà archivée.'),
  },
});

registry.registerPath({
  method: 'patch',
  path: '/admin/families/{id}/agent',
  tags: ['Admin · Familles'],
  summary: 'Assigner/réassigner/désassigner l’agent référent d’une famille',
  description:
    '`assigned_agent_id: null` désassigne explicitement (famille repasse ' +
    '100% self-service). Distinct de l’assignation faite à la validation ' +
    '(`POST /admin/families/{id}/approve`) — celle-ci gère un changement ' +
    'après coup (agent muté, parti, zone changée).',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(reassignAgentSchema) },
  responses: {
    200: jsonResponse('Famille mise à jour.', FamilyDto),
    400: errorResponse('Agent assigné inconnu ou inactif.'),
    404: errorResponse('Famille introuvable.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/families/{id}/contributions',
  tags: ['Admin · Familles'],
  summary: 'Historique des cotisations d’une famille',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Cotisations.', z.object({ data: z.array(CollectionDto) })),
    404: errorResponse('Famille introuvable.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/families/{id}/contributions',
  tags: ['Admin · Familles'],
  summary: 'Enregistrer un encaissement cash',
  description:
    'Crédite immédiatement le(s) objectif(s) d’épargne actif(s) de la famille ' +
    '(répartition prorata, contrat §6.1) et écrit l’écriture au ledger. ' +
    'Le mobile money (LigdiCash) passe par un flux séparé, asynchrone (webhook).',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(recordCashContributionSchema) },
  responses: {
    201: jsonResponse('Cotisation créée et créditée.', ContributionDto),
    400: errorResponse('Montant supérieur au besoin restant / données invalides.'),
    404: errorResponse('Famille introuvable.'),
    409: errorResponse('Aucun objectif actif à créditer.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/families/{id}/incident',
  tags: ['Admin · Familles'],
  summary: 'Signaler un incident sur un dossier famille',
  description: 'Consigné au journal d’audit.',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(incidentSchema) },
  responses: {
    204: { description: 'Incident consigné.' },
    400: errorResponse('Note manquante.'),
    404: errorResponse('Famille introuvable.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/families/{id}/children',
  tags: ['Admin · Familles'],
  summary: 'Ajouter un enfant à une famille',
  description:
    'Sans kit — le choix du kit est une action séparée, par saison ' +
    '(`POST /admin/families/{id}/children/{childId}/kit`). Un enfant sans ' +
    'objectif pour la saison en cours est un état normal.',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(addChildSchema) },
  responses: {
    201: jsonResponse('Famille mise à jour (dossier complet).', FamilyDto),
    404: errorResponse('Famille introuvable.'),
  },
});

registry.registerPath({
  method: 'patch',
  path: '/admin/families/{id}/children/{childId}',
  tags: ['Admin · Familles'],
  summary: 'Modifier la classe/école d’un enfant',
  description: 'Chaque saison, l’enfant change de classe.',
  security: bearerAuth,
  request: { params: childIdPathParam, body: jsonBody(updateChildSchema) },
  responses: {
    200: jsonResponse('Famille mise à jour.', FamilyDto),
    404: errorResponse('Famille ou enfant introuvable.'),
  },
});

registry.registerPath({
  method: 'delete',
  path: '/admin/families/{id}/children/{childId}',
  tags: ['Admin · Familles'],
  summary: 'Retirer un enfant',
  security: bearerAuth,
  request: { params: childIdPathParam },
  responses: {
    200: jsonResponse('Famille mise à jour.', FamilyDto),
    404: errorResponse('Famille ou enfant introuvable.'),
    409: errorResponse('Enfant avec historique de cotisation — suppression refusée.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/families/{id}/children/{childId}/kit',
  tags: ['Admin · Familles'],
  summary: 'Choisir/changer le kit d’un enfant pour la saison en cours',
  description:
    'Crée l’objectif d’épargne s’il n’existe pas encore pour (cet enfant, ' +
    'cette saison), sinon le fait évoluer vers le nouveau kit.',
  security: bearerAuth,
  request: { params: childIdPathParam, body: jsonBody(assignKitSchema) },
  responses: {
    200: jsonResponse('Famille mise à jour.', FamilyDto),
    400: errorResponse('Kit inconnu ou hors saison courante.'),
    404: errorResponse('Famille ou enfant introuvable.'),
  },
});

// ── Catalogue public (aucune authentification) ────────────────────────────────
registry.registerPath({
  method: 'get',
  path: '/catalog/kits',
  tags: ['Catalogue public'],
  summary: 'Kits de la saison courante',
  responses: { 200: jsonResponse('Kits.', z.object({ data: z.array(KitDto) })) },
});

registry.registerPath({
  method: 'get',
  path: '/catalog/articles',
  tags: ['Catalogue public'],
  summary: 'Fournitures individuelles',
  responses: { 200: jsonResponse('Fournitures.', z.object({ data: z.array(SupplyDto) })) },
});

registry.registerPath({
  method: 'get',
  path: '/catalog/plans',
  tags: ['Catalogue public'],
  summary: 'Fréquences de cotisation disponibles',
  description:
    'Pas de montant de base fixe : le montant par échéance est toujours ' +
    'dérivé du prix des kits choisis et de l’échéance de la saison.',
  responses: {
    200: jsonResponse(
      'Fréquences.',
      z.object({
        data: z.array(z.object({ frequency: z.enum(['daily', 'weekly', 'monthly']), label: z.string() })),
      }),
    ),
  },
});

// ── Self-service parent (app Client) ──────────────────────────────────────────
// Réutilise les mêmes schémas/DTO que le bloc admin ci-dessus : un parent
// agit sur sa propre famille exactement comme un admin agit "pour" une
// famille, juste avec `id` implicite = `req.auth.userId`.
registry.registerPath({
  method: 'get',
  path: '/parents/me',
  tags: ['Parent · Self-service'],
  summary: 'Profil du parent connecté',
  security: bearerAuth,
  responses: { 200: jsonResponse('Profil.', UserDto) },
});

registry.registerPath({
  method: 'patch',
  path: '/parents/me',
  tags: ['Parent · Self-service'],
  summary: 'Modifier son profil (nom / ville / quartier)',
  description: 'Le téléphone et le mot de passe restent gérés par `PATCH /auth/me`.',
  security: bearerAuth,
  request: { body: jsonBody(updateProfileSchema) },
  responses: {
    200: jsonResponse('Profil mis à jour.', UserDto),
    400: errorResponse('Aucun champ fourni.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/parents/me/children',
  tags: ['Parent · Self-service'],
  summary: 'Liste de ses enfants',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Enfants.', z.object({ data: z.array(FamilyDto.shape.children.element) })),
  },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/children',
  tags: ['Parent · Self-service'],
  summary: 'Ajouter un enfant',
  security: bearerAuth,
  request: { body: jsonBody(addChildSchema) },
  responses: { 200: jsonResponse('Dossier famille mis à jour.', FamilyDto) },
});

registry.registerPath({
  method: 'patch',
  path: '/parents/me/children/{childId}',
  tags: ['Parent · Self-service'],
  summary: 'Modifier la classe/école d’un enfant',
  security: bearerAuth,
  request: { params: childOnlyPathParam, body: jsonBody(updateChildSchema) },
  responses: {
    200: jsonResponse('Dossier famille mis à jour.', FamilyDto),
    404: errorResponse('Enfant introuvable.'),
  },
});

registry.registerPath({
  method: 'delete',
  path: '/parents/me/children/{childId}',
  tags: ['Parent · Self-service'],
  summary: 'Retirer un enfant',
  security: bearerAuth,
  request: { params: childOnlyPathParam },
  responses: {
    200: jsonResponse('Dossier famille mis à jour.', FamilyDto),
    404: errorResponse('Enfant introuvable.'),
    409: errorResponse('Enfant avec historique de cotisation — suppression refusée.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/children/{childId}/kit',
  tags: ['Parent · Self-service'],
  summary: 'Choisir/changer le kit d’un enfant pour la saison en cours',
  description:
    'Jamais refusé, même souscription déjà confirmée et cotisations déjà ' +
    'versées : le prix du kit s’ajoute à l’objectif restant, le montant par ' +
    'échéance se recalcule automatiquement. `POST /parents/me/children/preview` ' +
    'permet de prévenir le parent du nouveau montant avant l’ajout réel.',
  security: bearerAuth,
  request: { params: childOnlyPathParam, body: jsonBody(assignKitSchema) },
  responses: {
    200: jsonResponse('Dossier famille mis à jour.', FamilyDto),
    400: errorResponse('Kit inconnu ou hors saison courante.'),
    404: errorResponse('Enfant introuvable.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/children/preview',
  tags: ['Parent · Self-service'],
  summary: 'Aperçu du nouveau montant par échéance avant d’ajouter un enfant en cours de plan',
  description:
    'Aucune écriture, purement informatif — un ajout n’est jamais refusé à ' +
    'l’écriture. Avec souscription confirmée, montre le nouveau montant par ' +
    'échéance recalculé et un avertissement éventuel (`SUBSCRIPTION_CLOSED`, ' +
    '`TOO_LATE_TO_ADD_CHILD`, `INSUFFICIENT_PERIODS`, `UNAFFORDABLE_PLAN`) — ' +
    'sert à prévenir le parent, pas à bloquer.',
  security: bearerAuth,
  request: { body: jsonBody(previewChildSchema) },
  responses: {
    200: jsonResponse('Aperçu.', AddChildPreviewDto),
    400: errorResponse('Kit inconnu / aucune saison courante.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/subscription/confirm',
  tags: ['Parent · Self-service'],
  summary: 'Confirme le plan d’épargne (fréquence + signature)',
  description:
    'Crée la souscription si elle n’existe pas encore (compte auto-inscrit par ' +
    'OTP) puis la confirme. Montants toujours recalculés à la volée, jamais stockés.',
  security: bearerAuth,
  request: { body: jsonBody(confirmSubscriptionSchema) },
  responses: {
    200: jsonResponse('Souscription confirmée.', SubscriptionConfirmationDto),
    400: errorResponse('Aucune saison courante.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/parents/me/contributions',
  tags: ['Parent · Self-service'],
  summary: 'Historique de ses cotisations',
  security: bearerAuth,
  responses: { 200: jsonResponse('Cotisations.', z.object({ data: z.array(ContributionDto) })) },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/contributions',
  tags: ['Parent · Self-service'],
  summary: 'Initier une cotisation (mobile money)',
  description:
    'Cash exclu (réservé à l’encaissement agent, ' +
    '`POST /admin/families/{id}/contributions`). Crédite via LigdiCash — ' +
    'reste `pendingValidation` jusqu’à confirmation par webhook, sauf réponse ' +
    'synchrone immédiate de la passerelle.',
  security: bearerAuth,
  request: { body: jsonBody(selfContributionSchema) },
  responses: {
    200: jsonResponse('Cotisation initiée.', ContributionDto),
    400: errorResponse('Montant supérieur au besoin restant.'),
    403: errorResponse('Compte non actif (en attente de validation admin).'),
    409: errorResponse('Aucun objectif actif à créditer.'),
    503: errorResponse('Passerelle mobile money non configurée.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/parents/me/delivery',
  tags: ['Parent · Self-service'],
  summary: 'Livraisons de la famille (une par enfant avec kit)',
  security: bearerAuth,
  responses: { 200: jsonResponse('Livraisons.', z.object({ data: z.array(DeliveryDto) })) },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/delivery/location',
  tags: ['Parent · Self-service'],
  summary: 'Envoyer la position de livraison',
  description: 'S’applique à toutes les livraisons non encore confirmées de la famille.',
  security: bearerAuth,
  request: { body: jsonBody(sendLocationSchema) },
  responses: { 200: jsonResponse('Livraisons mises à jour.', z.object({ data: z.array(DeliveryDto) })) },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/delivery/confirm-receipt',
  tags: ['Parent · Self-service'],
  summary: 'Confirmer la réception (toutes les livraisons "livré")',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Livraisons confirmées.', z.object({ data: z.array(DeliveryDto) })),
    422: errorResponse('Aucune livraison au statut "livré".'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/delivery/issues',
  tags: ['Parent · Self-service'],
  summary: 'Signaler un problème sur la livraison d’un enfant',
  security: bearerAuth,
  request: { body: jsonBody(reportIssueSchema) },
  responses: {
    200: jsonResponse('Signalement enregistré.', DeliveryIssueDto),
    404: errorResponse('Livraison introuvable pour cet enfant.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/parents/me/refunds',
  tags: ['Parent · Self-service'],
  summary: 'Historique de ses demandes de remboursement',
  security: bearerAuth,
  responses: { 200: jsonResponse('Demandes.', z.object({ data: z.array(SelfRefundDto) })) },
});

registry.registerPath({
  method: 'post',
  path: '/parents/me/refunds',
  tags: ['Parent · Self-service'],
  summary: 'Demander un remboursement',
  description:
    'Montant toujours calculé serveur (solde disponible − frais de la ' +
    'saison courante), jamais saisi par le parent. Reste `requested` ' +
    'jusqu’à traitement par un admin.',
  security: bearerAuth,
  request: { body: jsonBody(requestRefundSchema) },
  responses: {
    200: jsonResponse('Demande créée.', SelfRefundDto),
    422: errorResponse('Aucun solde disponible après déduction des frais.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/parents/me/notifications',
  tags: ['Parent · Self-service'],
  summary: 'Notifications in-app du parent connecté',
  security: bearerAuth,
  responses: { 200: jsonResponse('Notifications (50 plus récentes).', z.object({ data: z.array(NotificationDto) })) },
});

// ── Notifications (commun à tous les rôles) ───────────────────────────────────
registry.registerPath({
  method: 'patch',
  path: '/notifications/{id}/read',
  tags: ['Notifications'],
  summary: 'Marquer une notification comme lue',
  description: 'Chacun ne peut marquer comme lue qu’une notification lui appartenant.',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Notification mise à jour.', NotificationDto),
    404: errorResponse('Notification introuvable.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/notifications/device-token',
  tags: ['Notifications'],
  summary: 'Enregistrer le token push (FCM) de l’appareil courant',
  description:
    'Upsert par token : si ce token était connu pour un autre compte (même ' +
    'appareil, reconnexion), il bascule simplement vers l’utilisateur courant.',
  security: bearerAuth,
  request: { body: jsonBody(registerDeviceTokenSchema) },
  responses: { 204: { description: 'Token enregistré.' } },
});

registry.registerPath({
  method: 'delete',
  path: '/notifications/device-token',
  tags: ['Notifications'],
  summary: 'Retirer un token push (déconnexion de cet appareil)',
  security: bearerAuth,
  request: { body: jsonBody(unregisterDeviceTokenSchema) },
  responses: { 204: { description: 'Token retiré (idempotent).' } },
});

// ── Self-service agent (app Agent terrain) ────────────────────────────────────
registry.registerPath({
  method: 'get',
  path: '/agent/me',
  tags: ['Agent · Self-service'],
  summary: 'Profil de l’agent connecté',
  security: bearerAuth,
  responses: { 200: jsonResponse('Profil.', AgentDto) },
});

registry.registerPath({
  method: 'patch',
  path: '/agent/me',
  tags: ['Agent · Self-service'],
  summary: 'Modifier son propre profil (nom, zone, quartier)',
  security: bearerAuth,
  request: { body: jsonBody(updateAgentProfileSchema) },
  responses: {
    200: jsonResponse('Profil mis à jour.', AgentDto),
    400: errorResponse('Aucun champ fourni.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/dashboard',
  tags: ['Agent · Self-service'],
  summary: 'KPI terrain (familles assignées uniquement)',
  security: bearerAuth,
  responses: { 200: jsonResponse('Tableau de bord agent.', AgentDashboardDto) },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/commissions',
  tags: ['Agent · Self-service'],
  summary: 'Historique des commissions sur cotisations collectées',
  description:
    'Uniquement les encaissements cash personnellement collectés par cet ' +
    'agent (`collected_by_agent_id`) — jamais un paiement mobile money en ' +
    'self-service.',
  security: bearerAuth,
  responses: { 200: jsonResponse('Commissions.', z.object({ data: z.array(AgentCommissionDto) })) },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/notifications',
  tags: ['Agent · Self-service'],
  summary: 'Notifications in-app de l’agent connecté',
  security: bearerAuth,
  responses: { 200: jsonResponse('Notifications (50 plus récentes).', z.object({ data: z.array(NotificationDto) })) },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/families',
  tags: ['Agent · Self-service'],
  summary: 'Familles assignées à cet agent',
  description: 'Filtre optionnel `?status` (ex. `lateOverdue` pour cibler les relances).',
  security: bearerAuth,
  request: { query: agentFamiliesQuerySchema },
  responses: { 200: jsonResponse('Familles.', z.object({ data: z.array(FamilyDto) })) },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/families/by-code/{code}',
  tags: ['Agent · Self-service'],
  summary: 'Identifier une famille par son code (scan QR)',
  description: 'Le QR affiché au client ne contient que ce code — le reste est re-fetché depuis le serveur.',
  security: bearerAuth,
  request: { params: familyCodeParamSchema },
  responses: {
    200: jsonResponse('Famille.', FamilyDto),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/agent/me/families',
  tags: ['Agent · Self-service'],
  summary: 'Enrôler une nouvelle famille',
  description: '`assigned_agent_id` est toujours l’agent authentifié, quelle que soit la valeur envoyée.',
  security: bearerAuth,
  request: { body: jsonBody(enrollFamilySchema) },
  responses: {
    201: jsonResponse('Famille enrôlée.', FamilyDto),
    400: errorResponse('Kit inconnu ou données invalides.'),
    409: errorResponse('Téléphone déjà utilisé.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/families/{id}',
  tags: ['Agent · Self-service'],
  summary: 'Détail d’une famille assignée',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Famille.', FamilyDto),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
  },
});

registry.registerPath({
  method: 'patch',
  path: '/agent/me/families/{id}',
  tags: ['Agent · Self-service'],
  summary: 'Modifier le profil d’une famille assignée (nom, ville, quartier)',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(updateFamilyProfileSchema) },
  responses: {
    200: jsonResponse('Famille mise à jour.', FamilyDto),
    400: errorResponse('Aucun champ fourni.'),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
  },
});

registry.registerPath({
  method: 'delete',
  path: '/agent/me/families/{id}',
  tags: ['Agent · Self-service'],
  summary: 'Archiver une famille assignée',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Famille archivée.', FamilyDto),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
    409: errorResponse('Famille déjà archivée.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/families/{id}/contributions',
  tags: ['Agent · Self-service'],
  summary: 'Historique des cotisations d’une famille assignée',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Cotisations.', z.object({ data: z.array(CollectionDto) })),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/families/{id}/ledger',
  tags: ['Agent · Self-service'],
  summary: 'Historique comptable complet d’une famille (équivalent "wallet transactions")',
  description: 'Cotisations confirmées et remboursements approuvés, journal `LedgerEntry` complet.',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Écritures.', z.object({ data: z.array(LedgerEntryDto) })),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/families/{id}/notifications',
  tags: ['Agent · Self-service'],
  summary: 'Notifications in-app d’une famille assignée',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Notifications (50 plus récentes).', z.object({ data: z.array(NotificationDto) })),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/contributions',
  tags: ['Agent · Self-service'],
  summary: 'Toutes les cotisations personnellement collectées par cet agent',
  security: bearerAuth,
  responses: { 200: jsonResponse('Cotisations.', z.object({ data: z.array(ContributionDto) })) },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/contributions/{id}',
  tags: ['Agent · Self-service'],
  summary: 'Détail d’une cotisation collectée par cet agent',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Cotisation.', ContributionDto),
    404: errorResponse('Cotisation introuvable ou non collectée par cet agent.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/agent/me/families/{id}/contributions',
  tags: ['Agent · Self-service'],
  summary: 'Encaisser une cotisation cash sur le terrain',
  description:
    '`collected_by_agent_id` est toujours l’agent authentifié, jamais fourni ' +
    'par le client. En-tête `X-Idempotency-Key` optionnel : rejouer la même ' +
    'clé (double-tap réseau) renvoie la cotisation déjà créée.',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(agentContributionSchema) },
  responses: {
    200: jsonResponse('Cotisation créée et créditée.', ContributionDto),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
    409: errorResponse('Aucun objectif actif à créditer.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/agent/me/families/{id}/remind',
  tags: ['Agent · Self-service'],
  summary: 'Relancer une famille en retard de paiement',
  description: 'Incrémente l’historique de relance et notifie le parent par WhatsApp.',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Relance envoyée.', z.object({ reminded: z.literal(true) })),
    404: errorResponse('Famille introuvable ou non assignée à cet agent.'),
    409: errorResponse('Cette famille n’est pas en retard de paiement.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/deliveries',
  tags: ['Agent · Self-service'],
  summary: 'Livraisons des familles assignées ("livraisons du jour")',
  description: 'Filtres optionnels `?date=YYYY-MM-DD` (passage prévu) et `?status`.',
  security: bearerAuth,
  request: { query: agentDeliveriesQuerySchema },
  responses: { 200: jsonResponse('Livraisons.', z.object({ data: z.array(DeliveryDto) })) },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/deliveries/{id}',
  tags: ['Agent · Self-service'],
  summary: 'Détail d’une livraison',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Livraison.', DeliveryDto),
    404: errorResponse('Livraison introuvable ou non assignée à cet agent.'),
  },
});

registry.registerPath({
  method: 'patch',
  path: '/agent/me/deliveries/{id}/status',
  tags: ['Agent · Self-service'],
  summary: 'Faire avancer la livraison d’un enfant',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(advanceStatusSchema) },
  responses: {
    200: jsonResponse('Livraison mise à jour.', DeliveryDto),
    404: errorResponse('Livraison introuvable ou non assignée à cet agent.'),
    422: errorResponse('Transition interdite (progression seule).'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/agent/me/deliveries/{id}/confirm',
  tags: ['Agent · Self-service'],
  summary: 'Confirmer la remise avec signature (terrain)',
  description:
    'Chemin alternatif à la confirmation self-service du parent — l’agent ' +
    'capture la signature sur son propre appareil au moment de la remise ' +
    'physique. Fonctionne quel que soit le statut précédent.',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(confirmByAgentSchema) },
  responses: {
    200: jsonResponse('Livraison confirmée.', DeliveryDto),
    404: errorResponse('Livraison introuvable ou non assignée à cet agent.'),
    409: errorResponse('Cette livraison a déjà été confirmée.'),
  },
});

registry.registerPath({
  method: 'patch',
  path: '/agent/me/deliveries/{id}/schedule',
  tags: ['Agent · Self-service'],
  summary: 'Planifier la date de passage d’une livraison',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(scheduleDeliverySchema) },
  responses: {
    200: jsonResponse('Livraison planifiée.', DeliveryDto),
    404: errorResponse('Livraison introuvable ou non assignée à cet agent.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/agent/me/reports/send',
  tags: ['Agent · Self-service'],
  summary: 'Générer un lien WhatsApp pré-rempli avec les KPI du mois',
  description: 'Aucun envoi automatique — retourne une URL `wa.me` que l’app ouvre elle-même.',
  security: bearerAuth,
  responses: { 200: jsonResponse('Lien généré.', SendReportResponseDto) },
});

registry.registerPath({
  method: 'get',
  path: '/agent/me/contact-director',
  tags: ['Agent · Self-service'],
  summary: 'Coordonnées du directeur',
  security: bearerAuth,
  responses: { 200: jsonResponse('Contact.', DirectorContactDto) },
});

registry.registerPath({
  method: 'post',
  path: '/admin/families/{id}/approve',
  tags: ['Admin · Familles'],
  summary: 'Valider un compte client en attente',
  description:
    '`assigned_agent_id` optionnel : une famille auto-inscrite (OTP) n’a ' +
    'sinon jamais d’agent. Voir `GET /admin/agents?zone=...` pour retrouver ' +
    'les agents de la ville de cette famille avant de valider.',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(approveFamilySchema) },
  responses: {
    200: jsonResponse('Compte validé (actif).', FamilyDto),
    400: errorResponse('Agent assigné inconnu ou inactif.'),
    404: errorResponse('Famille introuvable.'),
    409: errorResponse('Le compte n’est pas en attente.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/families/{id}/reject',
  tags: ['Admin · Familles'],
  summary: 'Rejeter un compte client en attente',
  description: 'Motif obligatoire, renvoyé au client sur son écran de statut.',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(rejectSchema) },
  responses: {
    200: jsonResponse('Compte rejeté.', FamilyDto),
    400: errorResponse('Motif manquant ou invalide.'),
    404: errorResponse('Famille introuvable.'),
    409: errorResponse('Le compte n’est pas en attente.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/agents',
  tags: ['Admin · Agents'],
  summary: 'Lister les agents',
  description: 'Filtre optionnel `?zone` (contient, insensible à la casse) — trouve les agents d’une ville donnée.',
  security: bearerAuth,
  request: { query: agentsQuerySchema },
  responses: {
    200: jsonResponse('Liste des agents (enveloppe `{ data }`).', z.object({ data: z.array(AgentDto) })),
    401: errorResponse('Authentification requise.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/agents/{id}',
  tags: ['Admin · Agents'],
  summary: 'Détail d’un agent',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Agent.', AgentDto),
    404: errorResponse('Agent introuvable.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/agents',
  tags: ['Admin · Agents'],
  summary: 'Créer un agent (actif immédiatement)',
  security: bearerAuth,
  request: { body: jsonBody(createAgentSchema) },
  responses: {
    201: jsonResponse('Agent créé.', AgentDto),
    400: errorResponse('Données invalides.'),
    401: errorResponse('Authentification requise.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
    409: errorResponse('Numéro de téléphone déjà utilisé.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/agents/{id}/suspend',
  tags: ['Admin · Agents'],
  summary: 'Suspendre un agent',
  description: 'Révoque immédiatement ses sessions ; motif consigné à l’audit.',
  security: bearerAuth,
  request: { params: idPathParam, body: { content: { 'application/json': { schema: suspendSchema } } } },
  responses: {
    200: jsonResponse('Agent suspendu.', AgentDto),
    401: errorResponse('Authentification requise.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
    404: errorResponse('Agent introuvable.'),
    409: errorResponse('Agent déjà suspendu.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/agents/{id}/reactivate',
  tags: ['Admin · Agents'],
  summary: 'Réactiver un agent suspendu',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Agent réactivé.', AgentDto),
    401: errorResponse('Authentification requise.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
    404: errorResponse('Agent introuvable.'),
    409: errorResponse('Agent déjà actif / transition invalide.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/audit-logs',
  tags: ['Admin · Audit'],
  summary: 'Consulter le journal d’audit',
  security: bearerAuth,
  request: { query: paginationParams },
  responses: {
    200: paginatedResponse('Entrées d’audit paginées (récentes d’abord).', AuditLogDto),
    401: errorResponse('Authentification requise.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/contributions',
  tags: ['Admin · Finances'],
  summary: 'Historique des cotisations, toutes familles confondues',
  description: 'Alimente le rapport « cotisations » de l’écran Rapports & exports.',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Cotisations.', z.object({ data: z.array(CollectionDto) })),
    401: errorResponse('Authentification requise.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

// ── Remboursements (écran ad_re) ──────────────────────────────────────────────
registry.registerPath({
  method: 'get',
  path: '/admin/refunds',
  tags: ['Admin · Remboursements'],
  summary: 'Demandes en attente + bilan du mois',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Demandes en attente et bilan mensuel.', RefundsResponse),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/refunds/{id}',
  tags: ['Admin · Remboursements'],
  summary: 'Détail d’une demande de remboursement',
  description: 'Fonctionne aussi pour une demande déjà traitée (historique).',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Remboursement.', RefundDetailDto),
    404: errorResponse('Demande introuvable.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/refunds/{id}/approve',
  tags: ['Admin · Remboursements'],
  summary: 'Approuver une demande de remboursement',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    204: { description: 'Demande approuvée.' },
    404: errorResponse('Demande introuvable.'),
    409: errorResponse('Demande déjà traitée.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/refunds/{id}/reject',
  tags: ['Admin · Remboursements'],
  summary: 'Rejeter une demande de remboursement',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    204: { description: 'Demande rejetée.' },
    404: errorResponse('Demande introuvable.'),
    409: errorResponse('Demande déjà traitée.'),
  },
});

// ── Catalogue · Saisons (contrat §3.7) ────────────────────────────────────────
registry.registerPath({
  method: 'get',
  path: '/admin/seasons',
  tags: ['Admin · Catalogue'],
  summary: 'Lister les saisons',
  security: bearerAuth,
  responses: {
    200: jsonResponse(
      'Saisons (récentes d’abord, enveloppe `{ data }`).',
      z.object({ data: z.array(SeasonDto) }),
    ),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/seasons',
  tags: ['Admin · Catalogue'],
  summary: 'Créer une saison',
  security: bearerAuth,
  request: { body: jsonBody(createSeasonSchema) },
  responses: {
    201: jsonResponse('Saison créée.', SeasonDto),
    400: errorResponse('Dates incohérentes / données invalides.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/seasons/{id}',
  tags: ['Admin · Catalogue'],
  summary: 'Détail d’une saison',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Saison.', SeasonDto),
    404: errorResponse('Saison introuvable.'),
  },
});

registry.registerPath({
  method: 'patch',
  path: '/admin/seasons/{id}',
  tags: ['Admin · Catalogue'],
  summary: 'Mettre à jour une saison',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(updateSeasonSchema) },
  responses: {
    200: jsonResponse('Saison mise à jour.', SeasonDto),
    400: errorResponse('Dates incohérentes.'),
    404: errorResponse('Saison introuvable.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/seasons/{id}/set-current',
  tags: ['Admin · Catalogue'],
  summary: 'Définir la saison courante (unique)',
  description: 'Démarque toute autre saison courante dans la même transaction.',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Saison désormais courante.', SeasonDto),
    404: errorResponse('Saison introuvable.'),
  },
});

// ── Catalogue · Kits (modèle Flutter Kit ; prix dérivé des fournitures) ──────
registry.registerPath({
  method: 'get',
  path: '/admin/kits',
  tags: ['Admin · Catalogue'],
  summary: 'Lister les kits (catalogue saison courante)',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Kits.', z.object({ data: z.array(KitDto) })),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/kits',
  tags: ['Admin · Catalogue'],
  summary: 'Créer un kit',
  security: bearerAuth,
  request: { body: jsonBody(createKitSchema) },
  responses: {
    201: jsonResponse('Kit créé.', KitDto),
    400: errorResponse('Aucune saison courante / articles invalides.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/kits/{id}',
  tags: ['Admin · Catalogue'],
  summary: 'Détail d’un kit',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Kit.', KitDto),
    404: errorResponse('Kit introuvable.'),
  },
});

registry.registerPath({
  method: 'put',
  path: '/admin/kits/{id}',
  tags: ['Admin · Catalogue'],
  summary: 'Modifier un kit (niveau, prix, articles)',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(updateKitSchema) },
  responses: {
    200: jsonResponse('Kit mis à jour.', KitDto),
    400: errorResponse('Articles invalides.'),
    404: errorResponse('Kit introuvable.'),
  },
});

registry.registerPath({
  method: 'delete',
  path: '/admin/kits/{id}',
  tags: ['Admin · Catalogue'],
  summary: 'Supprimer un kit',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    204: { description: 'Kit supprimé.' },
    404: errorResponse('Kit introuvable.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/kits/import',
  tags: ['Admin · Catalogue'],
  summary: 'Importer le catalogue depuis un fichier Excel fournisseur',
  description:
    'Groupe les lignes de l’onglet "Catalogue Complet (à plat)" par classe ' +
    'puis par variant (Basique/Essentiel/Premium) et fait un upsert par ' +
    '(classe, variant) pour la saison courante — jamais de suppression de ' +
    'kit existant.',
  security: bearerAuth,
  request: { body: jsonBody(importKitsSchema) },
  responses: {
    200: jsonResponse('Résumé de l’import.', ImportKitsSummaryDto),
    400: errorResponse('Fichier invalide, onglet/colonnes manquantes, aucune saison courante.'),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

// ── Catalogue · Fournitures (réutilisables, indépendantes des kits) ──────────
registry.registerPath({
  method: 'get',
  path: '/admin/supplies',
  tags: ['Admin · Catalogue'],
  summary: 'Lister les fournitures du catalogue',
  security: bearerAuth,
  responses: {
    200: jsonResponse('Fournitures.', z.object({ data: z.array(SupplyDto) })),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'post',
  path: '/admin/supplies',
  tags: ['Admin · Catalogue'],
  summary: 'Créer une fourniture',
  security: bearerAuth,
  request: { body: jsonBody(createSupplySchema) },
  responses: {
    201: jsonResponse('Fourniture créée.', SupplyDto),
    403: errorResponse('Réservé admin / mot de passe à changer.'),
  },
});

registry.registerPath({
  method: 'get',
  path: '/admin/supplies/{id}',
  tags: ['Admin · Catalogue'],
  summary: 'Détail d’une fourniture',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    200: jsonResponse('Fourniture.', SupplyDto),
    404: errorResponse('Fourniture introuvable.'),
  },
});

registry.registerPath({
  method: 'put',
  path: '/admin/supplies/{id}',
  tags: ['Admin · Catalogue'],
  summary: 'Modifier une fourniture',
  security: bearerAuth,
  request: { params: idPathParam, body: jsonBody(updateSupplySchema) },
  responses: {
    200: jsonResponse('Fourniture mise à jour.', SupplyDto),
    404: errorResponse('Fourniture introuvable.'),
  },
});

registry.registerPath({
  method: 'delete',
  path: '/admin/supplies/{id}',
  tags: ['Admin · Catalogue'],
  summary: 'Supprimer une fourniture',
  security: bearerAuth,
  request: { params: idPathParam },
  responses: {
    204: { description: 'Fourniture supprimée.' },
    404: errorResponse('Fourniture introuvable.'),
  },
});

// ── Paiements (Provider Pattern — LigdiCash) ──────────────────────────────────
registry.registerPath({
  method: 'post',
  path: '/payments/webhooks/ligdicash',
  tags: ['Paiements'],
  summary: 'Webhook LigdiCash (confirmation/échec d’un paiement mobile money)',
  description:
    'PUBLIC — pas de jeton EduPay (appelé directement par LigdiCash). ' +
    'Authenticité garantie par la signature du corps de requête (voir ' +
    '`LigdiCashProvider.verifyWebhook`), pas par un `Authorization: Bearer`. ' +
    '⚠️ Stub : la forme exacte du payload sera confirmée avec la doc LigdiCash.',
  responses: {
    204: { description: 'Événement traité (cotisation confirmée ou marquée en échec).' },
    401: errorResponse('Signature de webhook invalide.'),
    404: errorResponse('Aucune cotisation ne correspond à cette référence de transaction.'),
  },
});
