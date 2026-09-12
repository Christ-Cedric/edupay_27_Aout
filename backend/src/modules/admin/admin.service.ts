import bcrypt from 'bcryptjs';
import { randomBytes } from 'node:crypto';
import { Prisma } from '@prisma/client';
import type { ContributionMethod } from '@prisma/client';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { normalizePhone } from '../../shared/util/phone.js';
import { toPrismaRange } from '../../shared/http/pagination.js';
import type { PaginationQuery } from '../../shared/http/pagination.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { currentSeasonId } from '../kits/kits.service.js';
import { assertKitChangeAllowed } from '../delivery/delivery.service.js';
import * as notificationsService from '../notifications/notifications.service.js';
import type {
  AddChildInput,
  AdminFamiliesQuery,
  AssignKitInput,
  CreateAgentInput,
  EnrollFamilyInput,
  UpdateChildInput,
  UpdateFamilyProfileInput,
} from './admin.schemas.js';

// Include partagé pour toutes les lectures d'agent : profil + nombre de clients
// rattachés (relation AgentClients).
const agentInclude = {
  agentProfile: true,
  _count: { select: { clients: true } },
} satisfies Prisma.UserInclude;

type AgentRow = Prisma.UserGetPayload<{ include: typeof agentInclude }>;

/** Enum Prisma (volunteer/salaried) → modèle app (volunteer/paid) et retour. */
function contractToApi(c: 'volunteer' | 'salaried'): 'volunteer' | 'paid' {
  return c === 'salaried' ? 'paid' : 'volunteer';
}
function contractFromApi(c: 'volunteer' | 'paid'): 'volunteer' | 'salaried' {
  return c === 'paid' ? 'salaried' : 'volunteer';
}

/**
 * DTO agent aligné sur le modèle Flutter `Agent`. `client_count` = familles
 * rattachées. `commission` = commission d'inscription cumulée (proxy :
 * client_count × commission_par_inscription) — la part « sur collecte » sera
 * ajoutée avec le module Paiements. Montant en FCFA.
 */
function toAgentDto(agent: AgentRow) {
  const perEnrollment = agent.agentProfile?.commissionPerEnrollment ?? 0;
  const clientCount = agent._count.clients;
  return {
    id: agent.id,
    full_name: agent.fullName,
    phone: agent.phone,
    zone: agent.agentProfile?.zone ?? '',
    district: agent.agentProfile?.district ?? null,
    client_count: clientCount,
    commission: clientCount * perEnrollment,
    contract_type: contractToApi(agent.agentProfile?.contractType ?? 'volunteer'),
    // Un agent n'est jamais pendingValidation/rejected (créé actif par
    // l'admin) — seul le binaire actif/suspendu est pertinent côté app.
    status: agent.status === 'suspended' ? 'suspended' : 'active',
  };
}

/** Recherche insensible à la casse sur nom + téléphone. */
function nameOrPhoneFilter(search?: string): Prisma.UserWhereInput {
  if (!search) return {};
  return {
    OR: [
      { fullName: { contains: search, mode: 'insensitive' } },
      { phone: { contains: search } },
    ],
  };
}

/** Liste complète des agents (catalogue restreint → pas de pagination ; le
 * modèle Flutter attend une simple `List<Agent>`). `zone` (optionnel) filtre
 * en « contient » insensible à la casse — sert à retrouver les agents d'une
 * ville donnée au moment de valider une famille (voir `approveFamily`). */
export async function listAgents(query: { zone?: string } = {}) {
  const agents = await prisma.user.findMany({
    where: {
      role: 'agent',
      ...(query.zone ? { agentProfile: { zone: { contains: query.zone, mode: 'insensitive' } } } : {}),
    },
    include: agentInclude,
    orderBy: { createdAt: 'desc' },
  });
  return agents.map(toAgentDto);
}

/** Mot de passe temporaire lisible, à communiquer à l'agent (usage unique). */
function generateTempPassword(): string {
  return randomBytes(6).toString('base64url'); // ~8 caractères
}

/**
 * Crée un compte agent (contrat §2.1/§5.4) : l'agent est actif immédiatement
 * (créé par l'admin, pas d'auto-inscription), avec obligation de changer son
 * mot de passe au premier login.
 */
export async function createAgent(actorId: string, input: CreateAgentInput) {
  const phone = normalizePhone(input.phone);
  const existing = await prisma.user.findUnique({ where: { phone } });
  if (existing) {
    throw ApiError.conflict('Ce numéro de téléphone est déjà utilisé.');
  }

  // Mot de passe fourni par l'admin, sinon généré et renvoyé une seule fois.
  const generated = input.password === undefined;
  const plainPassword = input.password ?? generateTempPassword();
  const passwordHash = await bcrypt.hash(plainPassword, 10);

  const agent = await prisma.$transaction(async (tx) => {
    const created = await tx.user.create({
      data: {
        role: 'agent',
        status: 'active',
        fullName: input.full_name,
        phone,
        passwordHash,
        mustChangePassword: true,
        agentProfile: {
          create: {
            zone: input.zone,
            district: input.district ?? null,
            contractType: contractFromApi(input.contract_type),
          },
        },
      },
      include: agentInclude,
    });
    await writeAudit(tx, {
      actorId,
      action: 'agent.created',
      entity: 'user',
      entityId: created.id,
      after: { role: 'agent', phone, fullName: input.full_name, zone: input.zone },
    });
    return created;
  });

  const dto = toAgentDto(agent);
  // Le mot de passe temporaire n'est exposé qu'à la création, jamais relu.
  return generated ? { ...dto, temporary_password: plainPassword } : dto;
}

/** Charge un agent par id, 404 sinon (ne matche jamais un admin/client). */
async function getAgentOrThrow(agentId: string) {
  const agent = await prisma.user.findFirst({
    where: { id: agentId, role: 'agent' },
    include: agentInclude,
  });
  if (!agent) throw ApiError.notFound('Agent introuvable.');
  return agent;
}

/** Détail d'un agent (écran détail agent). */
export async function getAgent(agentId: string) {
  return toAgentDto(await getAgentOrThrow(agentId));
}

/**
 * Suspend un agent : bloque le login ET révoque toutes ses sessions actives.
 * Couplé à la revalidation en base dans `authenticate`, l'agent perd l'accès
 * immédiatement. La raison est conservée dans le journal d'audit.
 */
export async function suspendAgent(actorId: string, agentId: string, reason?: string) {
  const agent = await getAgentOrThrow(agentId);
  if (agent.status === 'suspended') {
    throw ApiError.conflict('Cet agent est déjà suspendu.');
  }

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.user.update({
      where: { id: agentId },
      data: { status: 'suspended' },
      include: agentInclude,
    });
    await tx.refreshToken.updateMany({
      where: { userId: agentId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    await writeAudit(tx, {
      actorId,
      action: 'user.suspended',
      entity: 'user',
      entityId: agentId,
      before: { status: agent.status },
      after: { status: 'suspended', reason: reason ?? null },
    });
    return u;
  });
  return toAgentDto(updated);
}

/** Réactive un agent suspendu (retour à `active`). */
export async function reactivateAgent(actorId: string, agentId: string) {
  const agent = await getAgentOrThrow(agentId);
  if (agent.status === 'active') {
    throw ApiError.conflict('Cet agent est déjà actif.');
  }
  if (agent.status !== 'suspended') {
    throw ApiError.conflict('Seul un agent suspendu peut être réactivé.');
  }

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.user.update({
      where: { id: agentId },
      data: { status: 'active' },
      include: agentInclude,
    });
    await writeAudit(tx, {
      actorId,
      action: 'user.reactivated',
      entity: 'user',
      entityId: agentId,
      before: { status: agent.status },
      after: { status: 'active' },
    });
    return u;
  });
  return toAgentDto(updated);
}

export async function listAuditLogs(query: PaginationQuery) {
  const [total, logs] = await prisma.$transaction([
    prisma.auditLog.count(),
    prisma.auditLog.findMany({
      orderBy: { createdAt: 'desc' },
      ...toPrismaRange(query),
    }),
  ]);

  // Résolution best-effort des noms d'acteurs (pas de FK sur l'audit) — une
  // seule requête pour la page courante, jamais de N+1.
  const actorIds = [...new Set(logs.map((l) => l.actorId))];
  const actors = await prisma.user.findMany({
    where: { id: { in: actorIds } },
    select: { id: true, fullName: true },
  });
  const actorName = new Map(actors.map((a) => [a.id, a.fullName]));

  const rows = logs.map((l) => ({
    id: l.id,
    actor_id: l.actorId,
    actor_name: actorName.get(l.actorId) ?? null,
    action: l.action,
    entity: l.entity,
    entity_id: l.entityId,
    before: l.before,
    after: l.after,
    created_at: l.createdAt.toISOString(),
  }));

  return { rows, total };
}

/**
 * Tableau de bord admin — aligné sur le modèle Flutter `DashboardSummary`.
 * Agrégats calculés en base (jamais de valeurs codées en dur). `collectionRate`
 * ∈ [0,1]. `overduePayments` compte les familles en retard au sens de
 * `isFamilyLate` (prorata objectif/saison, pas un module Paiements complet).
 */
export async function dashboardStats() {
  // Chargée d'abord (hors transaction) : l'agrégat de cotisations ci-dessous
  // doit être filtré sur cette saison, pas toutes saisons confondues (un
  // objectif soldé l'an dernier n'a aucun lien avec l'année en cours).
  const currentSeasonRow = await prisma.season.findFirst({ where: { isCurrent: true } });
  const seasonFilter = currentSeasonRow ? { seasonId: currentSeasonRow.id } : {};

  const [
    activeAgents,
    activeFamilies,
    pendingFamilies,
    goalsAgg,
    pendingDeliveries,
    activeFamilyRows,
  ] = await prisma.$transaction([
    prisma.user.count({ where: { role: 'agent', status: 'active' } }),
    prisma.user.count({ where: { role: 'client', status: 'active' } }),
    prisma.user.count({ where: { role: 'client', status: 'pendingValidation' } }),
    prisma.savingsGoal.aggregate({
      where: seasonFilter,
      _sum: { savedAmount: true, targetAmount: true },
    }),
    prisma.delivery.count({
      where: { status: { notIn: ['delivered', 'receiptConfirmed'] } },
    }),
    prisma.user.findMany({ where: { role: 'client', status: 'active' }, include: familyInclude }),
  ]);

  const totalCollected = goalsAgg._sum.savedAmount ?? 0;
  const totalTarget = goalsAgg._sum.targetAmount ?? 0;
  const collectionRate = totalTarget === 0 ? 0 : totalCollected / totalTarget;
  const currentSeason = toCurrentSeason(currentSeasonRow);
  const overduePayments = activeFamilyRows.filter((f) => isFamilyLate(f, currentSeason)).length;

  // Alertes dérivées de l'état réel (motif `.nt` du prototype). `code` est un
  // identifiant stable (indépendant du texte affiché) que le client utilise
  // pour router vers le bon écran au tap — voir `DashboardAlertKind` côté Flutter.
  const alerts: {
    code: string;
    title: string;
    subtitle: string;
    severity: 'danger' | 'warning' | 'info';
  }[] = [];
  if (overduePayments > 0) {
    alerts.push({
      code: 'overdue_payments',
      title: `${overduePayments} famille(s) en retard de cotisation`,
      subtitle: 'Action requise - relancer les agents',
      severity: 'danger',
    });
  }
  if (pendingFamilies > 0) {
    alerts.push({
      code: 'pending_validation',
      title: 'Comptes à valider',
      subtitle: `${pendingFamilies} famille(s) en attente de validation`,
      severity: 'warning',
    });
  }
  if (pendingDeliveries > 0) {
    alerts.push({
      code: 'pending_deliveries',
      title: 'Livraisons en attente',
      subtitle: `${pendingDeliveries} kit(s) à livrer`,
      severity: 'info',
    });
  }
  alerts.push({
    code: 'season_progress',
    title: 'Avancement de la saison',
    subtitle: `Collecte à ${Math.round(collectionRate * 100)}% de l'objectif`,
    severity: 'info',
  });

  return {
    season: currentSeasonRow?.label ?? '',
    active_families: activeFamilies,
    total_collected: totalCollected,
    collection_rate: collectionRate,
    overdue_payments: overduePayments,
    active_agents: activeAgents,
    pending_deliveries: pendingDeliveries,
    alerts,
  };
}

// Include partagé pour assembler le modèle Flutter `Family` (dénormalisé) à
// partir du schéma normalisé : abonnement (plan), enfants (indépendants de
// toute saison), objectifs (solde/cible/kit — un par enfant et par saison,
// voir `toFamilyDto`), dernière livraison, agent référent.
const familyInclude = {
  subscription: { select: { frequency: true } },
  assignedAgent: { select: { fullName: true } },
  children: { select: { id: true, firstName: true, level: true, school: true } },
  savingsGoals: {
    select: {
      id: true,
      type: true,
      name: true,
      status: true,
      childId: true,
      seasonId: true,
      savedAmount: true,
      targetAmount: true,
      kitId: true,
      customAddedItems: true,
      customRemovedItems: true,
    },
  },
  deliveries: { select: { status: true }, orderBy: { createdAt: 'desc' }, take: 1 },
} satisfies Prisma.UserInclude;

type FamilyRow = Prisma.UserGetPayload<{ include: typeof familyInclude }>;

/** Saison courante, forme minimale utilisée par le calcul d'impayés et le
 * scoping des objectifs — `null` si aucune saison n'est marquée courante. */
type CurrentSeason = { id: string; launchDate: Date; deliveryDeadline: Date } | null;

function toCurrentSeason(
  season: { id: string; launchDate: Date; deliveryDeadline: Date } | null,
): CurrentSeason {
  if (!season) return null;
  return { id: season.id, launchDate: season.launchDate, deliveryDeadline: season.deliveryDeadline };
}

async function getCurrentSeason(): Promise<CurrentSeason> {
  const season = await prisma.season.findFirst({ where: { isCurrent: true } });
  return toCurrentSeason(season);
}

/** Durée d'une période de cotisation, alignée sur la fréquence du plan. */
const PERIOD_LENGTH_DAYS: Record<'daily' | 'weekly' | 'monthly', number> = {
  daily: 1,
  weekly: 7,
  monthly: 30,
};

const MS_PER_DAY = 24 * 60 * 60 * 1000;

/** Objectifs de la famille pour la saison [currentSeason] uniquement — les
 * saisons passées n'ont aucun lien avec la cotisation en cours. */
function goalsForCurrentSeason(f: FamilyRow, currentSeason: CurrentSeason) {
  if (!currentSeason) return [];
  return f.savingsGoals.filter((g) => g.seasonId === currentSeason.id);
}

/**
 * Une famille est en retard quand son solde de la saison en cours n'a pas
 * suivi le rythme "juste part" de son plan, calculé au prorata de l'objectif
 * de cette saison sur sa durée — pas un seuil de jours fixe. L'horloge part
 * du lancement de la saison (ou de l'inscription de la famille si elle a
 * rejoint après coup), jamais de sa date d'inscription d'origine : une
 * famille inscrite il y a 2 saisons ne doit pas être jugée en retard dès
 * qu'un kit lui est choisi pour la nouvelle saison. Ex. plan hebdomadaire :
 * montant attendu par semaine = objectif × 7 / durée_totale_saison_en_jours ;
 * l'attendu à date = ce montant × nombre de semaines complètes écoulées
 * (plafonné à l'objectif). Aucun objectif cette saison → jamais en retard.
 */
function isFamilyLate(f: FamilyRow, currentSeason: CurrentSeason): boolean {
  if (!currentSeason) return false;
  const currentGoals = goalsForCurrentSeason(f, currentSeason);
  const targetAmount = currentGoals.reduce((sum, g) => sum + g.targetAmount, 0);
  if (targetAmount === 0) return false;
  const balance = currentGoals.reduce((sum, g) => sum + g.savedAmount, 0);

  const periodStart =
    f.createdAt > currentSeason.launchDate ? f.createdAt : currentSeason.launchDate;
  const totalDurationDays = (currentSeason.deliveryDeadline.getTime() - periodStart.getTime()) / MS_PER_DAY;
  if (totalDurationDays <= 0) return false;

  const periodLengthDays = PERIOD_LENGTH_DAYS[f.subscription?.frequency ?? 'weekly'];
  const perPeriodAmount = (targetAmount * periodLengthDays) / totalDurationDays;

  const daysSincePeriodStart = (Date.now() - periodStart.getTime()) / MS_PER_DAY;
  const elapsedPeriods = Math.floor(daysSincePeriodStart / periodLengthDays);
  const expectedSoFar = Math.min(targetAmount, perPeriodAmount * elapsedPeriods);

  return balance < expectedSoFar;
}

/** Statut compte (schéma) → statut famille (app). `lateOverdue` est dérivé du
 * rythme de cotisation attendu (voir `isFamilyLate`), pas un statut de compte. */
function toFamilyStatus(
  f: FamilyRow,
  currentSeason: CurrentSeason,
): 'pendingValidation' | 'active' | 'rejected' | 'lateOverdue' {
  if (f.status === 'pendingValidation') return 'pendingValidation';
  if (f.status === 'rejected' || f.status === 'suspended') return 'rejected';
  return isFamilyLate(f, currentSeason) ? 'lateOverdue' : 'active';
}

function toAppDeliveryStatus(
  s: 'preparation' | 'shipped' | 'outForDelivery' | 'delivered' | 'receiptConfirmed' | undefined,
): 'pending' | 'inProgress' | 'delivered' {
  if (s === 'shipped' || s === 'outForDelivery') return 'inProgress';
  if (s === 'delivered' || s === 'receiptConfirmed') return 'delivered';
  return 'pending';
}

function toFamilyDto(f: FamilyRow, currentSeason: CurrentSeason) {
  const currentGoals = goalsForCurrentSeason(f, currentSeason);
  const balance = currentGoals.reduce((sum, g) => sum + g.savedAmount, 0);
  const targetAmount = currentGoals.reduce((sum, g) => sum + g.targetAmount, 0);
  const goalsByChildId = new Map<string, typeof currentGoals>();
  for (const g of currentGoals) {
    if (g.childId) {
      const list = goalsByChildId.get(g.childId) ?? [];
      list.push(g);
      goalsByChildId.set(g.childId, list);
    }
  }

  // Tous les enfants de la famille (indépendant de la saison) — un enfant
  // sans objectif pour la saison en cours est un état normal (kit pas
  // encore choisi cette saison), pas un enfant "invisible".
  const children = f.children.map((c) => {
    const goals = goalsByChildId.get(c.id) ?? [];
    const suppliesGoal = goals.find((g) => g.type === 'supplies');
    const schoolingGoal = goals.find((g) => g.type === 'registration');
    const transportGoal = goals.find((g) => g.type === 'transport');

    return {
      id: c.id,
      first_name: c.firstName,
      level: c.level,
      school: c.school,
      kit_id: suppliesGoal?.kitId ?? null,
      target_amount: suppliesGoal?.targetAmount ?? null,
      saved_amount: suppliesGoal?.savedAmount ?? null,
      // Personnalisation propre à cet enfant (voir `assignKit`) — jamais un
      // changement du `Kit` partagé, juste ce qui a été ajouté/retiré pour lui.
      custom_added_items: suppliesGoal?.customAddedItems ?? null,
      custom_removed_items: suppliesGoal?.customRemovedItems ?? null,
      kit_saved_amount: suppliesGoal?.savedAmount ?? null,
      tuition_amount: schoolingGoal?.targetAmount ?? null,
      tuition_saved_amount: schoolingGoal?.savedAmount ?? null,
      transport_amount: transportGoal?.targetAmount ?? null,
      transport_saved_amount: transportGoal?.savedAmount ?? null,
      transport_type: transportGoal?.name ?? null,
      schooling_goal: schoolingGoal
        ? {
            id: schoolingGoal.id,
            target_amount: schoolingGoal.targetAmount,
            saved_amount: schoolingGoal.savedAmount,
            status: schoolingGoal.status,
            plan_frequency: (schoolingGoal.customAddedItems as any)?.frequency,
            plan_capacity: (schoolingGoal.customAddedItems as any)?.capacity,
          }
        : null,
      transport_goal: transportGoal
        ? {
            id: transportGoal.id,
            target_amount: transportGoal.targetAmount,
            saved_amount: transportGoal.savedAmount,
            status: transportGoal.status,
            name: transportGoal.name,
            plan_frequency: (transportGoal.customAddedItems as any)?.frequency,
            plan_capacity: (transportGoal.customAddedItems as any)?.capacity,
          }
        : null,
    };
  });
  return {
    id: f.id,
    full_name: f.fullName,
    phone: f.phone,
    city: f.city ?? '',
    district: f.district,
    plan: f.subscription?.frequency ?? 'weekly',
    balance,
    target_amount: targetAmount,
    children,
    status: toFamilyStatus(f, currentSeason),
    delivery_status: toAppDeliveryStatus(f.deliveries[0]?.status),
    registered_at: f.createdAt.toISOString(),
    assigned_agent_name: f.assignedAgent?.fullName ?? null,
    rejection_reason: f.rejectionReason,
    // Identification terrain rapide (QR agent) — posé seulement à la
    // validation, `null` tant que le compte est `pendingValidation`.
    family_code: f.familyCode ?? null,
  };
}

/**
 * Génère le code famille (identification terrain rapide, QR agent) au
 * moment de la validation admin — jamais avant, jamais modifiable ensuite.
 * `<3 lettres ville>-<année>-<4 hex aléatoires>` : suffixe aléatoire plutôt
 * qu'un compteur séquentiel pour éviter toute violation de contrainte
 * unique en cas de validations concurrentes (même choix que
 * `generateReference` dans `payments.service.ts`).
 */
function generateFamilyCode(city: string | null): string {
  const prefix = (city ?? 'GEN').replace(/[^a-zA-Z]/g, '').slice(0, 3).toUpperCase() || 'GEN';
  const year = new Date().getFullYear();
  const suffix = randomBytes(2).toString('hex').toUpperCase();
  return `${prefix}-${year}-${suffix}`;
}

/** Filtre statut famille → statut compte (statuts mappables au compte). */
const FAMILY_TO_USER_STATUS = {
  pendingValidation: 'pendingValidation',
  active: 'active',
  rejected: 'rejected',
} as const;

export async function listFamilies(query: AdminFamiliesQuery) {
  const currentSeason = await getCurrentSeason();

  // `lateOverdue` n'est pas une colonne (dérivé du rythme de cotisation, voir
  // `isFamilyLate`) et ne peut concerner que des comptes actifs — on filtre
  // en base sur `active` puis on affine en JS après coup. Les autres statuts
  // restent filtrables directement en base.
  const accountStatus =
    query.status && query.status !== 'lateOverdue'
      ? FAMILY_TO_USER_STATUS[query.status]
      : query.status === 'lateOverdue'
        ? 'active'
        : undefined;

  const where: Prisma.UserWhereInput = {
    role: 'client',
    ...(accountStatus ? { status: accountStatus } : {}),
    ...(query.city ? { city: { equals: query.city, mode: 'insensitive' } } : {}),
    ...(query.assignedAgentId ? { assignedAgentId: query.assignedAgentId } : {}),
    ...nameOrPhoneFilter(query.search),
  };

  const families = await prisma.user.findMany({
    where,
    include: familyInclude,
    orderBy: { createdAt: 'desc' },
  });
  const dtos = families.map((f) => toFamilyDto(f, currentSeason));
  return query.status === 'lateOverdue'
    ? dtos.filter((f) => f.status === 'lateOverdue')
    : dtos;
}

/** File d'attente de validation (`/admin/families/pending`). */
export async function listPendingFamilies() {
  const [families, currentSeason] = await Promise.all([
    prisma.user.findMany({
      where: { role: 'client', status: 'pendingValidation' },
      include: familyInclude,
      orderBy: { createdAt: 'asc' },
    }),
    getCurrentSeason(),
  ]);
  // Toujours `pendingValidation` ici (jamais `lateOverdue`), mais la saison
  // reste nécessaire pour afficher correctement les enfants/kits déjà
  // choisis par cette famille en attente de validation.
  return families.map((f) => toFamilyDto(f, currentSeason));
}

async function getFamilyRowOrThrow(clientId: string) {
  const client = await prisma.user.findFirst({
    where: { id: clientId, role: 'client' },
    include: familyInclude,
  });
  if (!client) throw ApiError.notFound('Famille introuvable.');
  return client;
}

export async function getFamily(clientId: string) {
  const [client, currentSeason] = await Promise.all([
    getFamilyRowOrThrow(clientId),
    getCurrentSeason(),
  ]);
  return toFamilyDto(client, currentSeason);
}

/** Existence légère d'un client (sans charger tout le dossier). */
async function assertClientExists(clientId: string) {
  const client = await prisma.user.findFirst({
    where: { id: clientId, role: 'client' },
    select: { id: true },
  });
  if (!client) throw ApiError.notFound('Famille introuvable.');
}

/** Méthode de cotisation (schéma) → mode de collecte (app). */
function methodToMode(m: ContributionMethod): 'cash' | 'orangeMoney' | 'moovMoney' | 'wave' {
  if (m === 'orangeMoney') return 'orangeMoney';
  if (m === 'moovMoney') return 'moovMoney';
  if (m === 'wave') return 'wave';
  return 'cash';
}

/**
 * Historique des cotisations d'une famille (dossier famille → « Historique
 * cotisations », modèle Flutter `Collection`). Vide tant qu'aucune cotisation
 * n'existe (module Paiements à venir).
 */
export async function listFamilyContributions(clientId: string) {
  await assertClientExists(clientId);
  const contributions = await prisma.contribution.findMany({
    where: { parentId: clientId },
    include: {
      parent: { select: { fullName: true } },
      allocations: {
        include: {
          savingsGoal: {
            select: { type: true, name: true, child: { select: { firstName: true } } },
          },
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  const agentIds = [
    ...new Set(contributions.map((c) => c.collectedByAgentId).filter((x): x is string => !!x)),
  ];
  const agents = agentIds.length
    ? await prisma.user.findMany({ where: { id: { in: agentIds } }, select: { id: true, fullName: true } })
    : [];
  const agentName = new Map(agents.map((a) => [a.id, a.fullName]));

  return contributions.map((c) => {
    const distinctTypes = [...new Set(c.allocations.map((a) => a.savingsGoal.type))];
    const resolvedGoalType = c.targetGoalType ?? (distinctTypes.length === 1 ? distinctTypes[0] : null);

    return {
      id: c.id,
      family_id: c.parentId,
      family_name: c.parent.fullName,
      agent_name: c.collectedByAgentId ? agentName.get(c.collectedByAgentId) ?? null : null,
      amount: c.amount,
      mode: methodToMode(c.method),
      collected_at: c.createdAt.toISOString(),
      receipt_number: c.reference,
      target_goal_type: resolvedGoalType,
      allocations: c.allocations.map((a) => ({
        goal_type: a.savingsGoal.type,
        amount: a.amount,
        child_name: a.savingsGoal.child?.firstName ?? null,
        goal_name: a.savingsGoal.name,
      })),
    };
  });
}

/**
 * Historique des cotisations toutes familles confondues (rapport « cotisations »,
 * écran Rapports & exports) — même forme que `listFamilyContributions`, sans
 * filtre `parentId`.
 */
export async function listAllContributions() {
  const contributions = await prisma.contribution.findMany({
    include: {
      parent: { select: { fullName: true } },
      allocations: {
        include: {
          savingsGoal: {
            select: { type: true, name: true, child: { select: { firstName: true } } },
          },
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  const agentIds = [
    ...new Set(contributions.map((c) => c.collectedByAgentId).filter((x): x is string => !!x)),
  ];
  const agents = agentIds.length
    ? await prisma.user.findMany({ where: { id: { in: agentIds } }, select: { id: true, fullName: true } })
    : [];
  const agentName = new Map(agents.map((a) => [a.id, a.fullName]));

  return contributions.map((c) => {
    const distinctTypes = [...new Set(c.allocations.map((a) => a.savingsGoal.type))];
    const resolvedGoalType = c.targetGoalType ?? (distinctTypes.length === 1 ? distinctTypes[0] : null);

    return {
      id: c.id,
      family_id: c.parentId,
      family_name: c.parent.fullName,
      agent_name: c.collectedByAgentId ? agentName.get(c.collectedByAgentId) ?? null : null,
      amount: c.amount,
      mode: methodToMode(c.method),
      collected_at: c.createdAt.toISOString(),
      receipt_number: c.reference,
      target_goal_type: resolvedGoalType,
      allocations: c.allocations.map((a) => ({
        goal_type: a.savingsGoal.type,
        amount: a.amount,
        child_name: a.savingsGoal.child?.firstName ?? null,
        goal_name: a.savingsGoal.name,
      })),
    };
  });
}

/** Signale un incident sur un dossier famille → tracé au journal d'audit. */
export async function reportFamilyIncident(actorId: string, clientId: string, note: string) {
  await assertClientExists(clientId);
  await prisma.$transaction(async (tx) => {
    await writeAudit(tx, {
      actorId,
      action: 'family.incident_reported',
      entity: 'user',
      entityId: clientId,
      after: { note },
    });
  });
}

/**
 * Inscription directe (écran `ad_in`) : le client passe actif immédiatement
 * (pas d'OTP, à la différence de l'auto-inscription cliente). Crée l'abonnement
 * (plan) et l'objectif d'épargne ciblant le kit (cible = prix du kit).
 */
export async function enrollFamily(actorId: string, input: EnrollFamilyInput) {
  const phone = normalizePhone(input.phone);
  const existing = await prisma.user.findUnique({ where: { phone } });
  if (existing) throw ApiError.conflict('Ce numéro de téléphone est déjà utilisé.');

  const currentSeason = await getCurrentSeason();

  // Validation des kits enfants
  const kits = await prisma.kit.findMany({
    where: { id: { in: input.children.map((c) => c.kit_id) } },
  });
  const kitById = new Map(kits.map((k) => [k.id, k]));
  for (const child of input.children) {
    const kit = kitById.get(child.kit_id);
    if (!kit) {
      throw ApiError.badRequest('Kit inconnu.', [{ field: 'kit_id', issue: 'Introuvable.' }]);
    }
    if (!currentSeason || kit.seasonId !== currentSeason.id) {
      throw ApiError.badRequest("Ce kit n'appartient pas \u00e0 la saison en cours.", [
        { field: 'kit_id', issue: 'Kit hors saison courante.' },
      ]);
    }
  }

  // Validation du kit famille direct (sans enfant) si fourni
  let familyKit: Awaited<ReturnType<typeof prisma.kit.findUnique>> | null = null;
  if (input.family_kit_id) {
    familyKit = await prisma.kit.findUnique({ where: { id: input.family_kit_id } });
    if (!familyKit) {
      throw ApiError.badRequest('Kit famille inconnu.', [{ field: 'family_kit_id', issue: 'Introuvable.' }]);
    }
    if (!currentSeason || familyKit.seasonId !== currentSeason.id) {
      throw ApiError.badRequest("Ce kit n'appartient pas \u00e0 la saison en cours.", [
        { field: 'family_kit_id', issue: 'Kit hors saison courante.' },
      ]);
    }
  }

  if (input.assigned_agent_id) {
    const agent = await prisma.user.findFirst({
      where: { id: input.assigned_agent_id, role: 'agent' },
      select: { id: true },
    });
    if (!agent) {
      throw ApiError.badRequest('Agent assigné inconnu.', [
        { field: 'assigned_agent_id', issue: 'Aucun agent avec cet id.' },
      ]);
    }
  }

  // Le client définira son mot de passe via le parcours OTP (app Client) ;
  // ici un secret aléatoire non communicable empêche tout login prématuré.
  const passwordHash = await bcrypt.hash(randomBytes(24).toString('base64url'), 10);

  const client = await prisma.$transaction(async (tx) => {
    const created = await tx.user.create({
      data: {
        role: 'client',
        status: 'active',
        fullName: input.full_name,
        phone,
        city: input.city ?? null,
        district: input.district ?? null,
        passwordHash,
        // Actif immédiatement (pas de passage par `approveFamily`) : le
        // code famille (identification terrain rapide, QR agent) est donc
        // généré ici, au même titre que là-bas — chaque famille en obtient
        // un dès qu'elle devient active, quel que soit le chemin emprunté.
        familyCode: generateFamilyCode(input.city ?? null),
        assignedAgentId: input.assigned_agent_id ?? null,
        subscription: { create: { frequency: input.plan, status: 'confirmed', confirmedAt: new Date() } },
      },
    });

    // Un `Child` + un `SavingsGoal` par enfant — l'objectif famille agrégé
    // (§348 `toFamilyDto`) est la somme de ces goals, calculée automatiquement.
    for (const childInput of input.children) {
      const kit = kitById.get(childInput.kit_id)!;
      const child = await tx.child.create({
        data: {
          parentId: created.id,
          firstName: childInput.first_name,
          level: childInput.level ?? '',
          school: childInput.school ?? '',
        },
      });
      await tx.savingsGoal.create({
        data: {
          parentId: created.id,
          childId: child.id,
          type: 'supplies',
          name: kit.name,
          targetAmount: kit.totalPrice,
          kitId: kit.id,
          seasonId: kit.seasonId,
        },
      });
    }

    await writeAudit(tx, {
      actorId,
      action: 'family.enrolled',
      entity: 'user',
      entityId: created.id,
      after: {
        fullName: input.full_name,
        phone,
        plan: input.plan,
        children: input.children.map((c) => ({ firstName: c.first_name, kitId: c.kit_id })),
      },
    });
    return tx.user.findUniqueOrThrow({ where: { id: created.id }, include: familyInclude });
  });
  return toFamilyDto(client, currentSeason);
}

/** Enfant + vérification qu'il appartient bien à cette famille, ou 404. */
async function getChildOrThrow(clientId: string, childId: string) {
  const child = await prisma.child.findFirst({ where: { id: childId, parentId: clientId } });
  if (!child) throw ApiError.notFound('Enfant introuvable.');
  return child;
}

/**
 * Ajoute un enfant à une famille existante — jamais de kit ici (choix
 * séparé, par saison, voir `assignKit`). Un enfant sans objectif pour la
 * saison en cours est un état normal, pas une erreur.
 */
export async function addChild(actorId: string, clientId: string, input: AddChildInput) {
  await assertClientExists(clientId);
  await prisma.$transaction(async (tx) => {
    const created = await tx.child.create({
      data: {
        parentId: clientId,
        firstName: input.first_name,
        level: input.level ?? '',
        school: input.school ?? '',
      },
    });
    await writeAudit(tx, {
      actorId,
      action: 'child.added',
      entity: 'child',
      entityId: created.id,
      after: { firstName: created.firstName, parentId: clientId },
    });
  });
  notifyFamilyActedByOther(actorId, clientId, `${input.first_name} a été ajouté(e) à votre dossier EduPay.`);
  return getFamily(clientId);
}

/** Notifie la famille quand une action est faite EN SON NOM par un tiers
 * (agent/admin) plutôt que par elle-même — `actorId !== clientId` suffit :
 * le self-service (`parents.controller.ts`) appelle toujours ces fonctions
 * avec `actorId === clientId === req.auth.userId`. */
function notifyFamilyActedByOther(actorId: string, clientId: string, body: string): void {
  if (actorId === clientId) return;
  notificationsService.notify(clientId, 'family_updated_by_agent', 'Mise à jour de votre dossier', body).catch(() => {});
}

/** Change la classe/école d'un enfant (chaque saison, l'enfant change de classe). */
export async function updateChild(
  actorId: string,
  clientId: string,
  childId: string,
  input: UpdateChildInput,
) {
  const existing = await getChildOrThrow(clientId, childId);
  await prisma.$transaction(async (tx) => {
    const updated = await tx.child.update({
      where: { id: childId },
      data: { level: input.level, school: input.school },
    });
    await writeAudit(tx, {
      actorId,
      action: 'child.updated',
      entity: 'child',
      entityId: childId,
      before: { level: existing.level, school: existing.school },
      after: { level: updated.level, school: updated.school },
    });
  });
  return getFamily(clientId);
}

/** Retire un enfant — refusé (409) s'il a déjà au moins un objectif
 * d'épargne (historique de cotisation à préserver, même soldé/passé). */
export async function removeChild(actorId: string, clientId: string, childId: string) {
  await getChildOrThrow(clientId, childId);
  const goalCount = await prisma.savingsGoal.count({ where: { childId } });
  if (goalCount > 0) {
    throw ApiError.conflict(
      'Impossible de retirer cet enfant : il a déjà un historique de cotisation.',
    );
  }
  await prisma.$transaction(async (tx) => {
    await tx.child.delete({ where: { id: childId } });
    await writeAudit(tx, {
      actorId,
      action: 'child.removed',
      entity: 'child',
      entityId: childId,
      before: { parentId: clientId },
    });
  });
  return getFamily(clientId);
}

/**
 * Choisit ou change le kit d'un enfant POUR LA SAISON EN COURS — crée
 * l'objectif d'épargne s'il n'existe pas encore pour (cet enfant, cette
 * saison), sinon le fait évoluer vers le nouveau kit (le solde déjà cotisé
 * cette saison est conservé, seuls le kit et l'objectif changent).
 */
export async function assignKit(
  actorId: string,
  clientId: string,
  childId: string,
  input: AssignKitInput,
) {
  await getChildOrThrow(clientId, childId);
  await assertKitChangeAllowed(childId);
  const seasonId = await currentSeasonId();

  let effectiveTargetAmount = 0;
  let kitId: string | null = null;
  let kitName = 'Kit Personnalisé';
  let customAddedItems: any = Prisma.JsonNull;
  let customRemovedItems: any = Prisma.JsonNull;

  const child = await prisma.child.findUnique({
    where: { id: childId },
    select: { level: true },
  });

  if (input.custom && input.items) {
    for (const item of input.items) {
      effectiveTargetAmount += item.quantity * item.price;
    }
    customAddedItems = input.items;
    kitName = 'Kit Personnalisé';
  } else if (input.kit_id) {
    const kit = await prisma.kit.findUnique({ where: { id: input.kit_id }, include: { items: true } });
    if (!kit) {
      throw ApiError.badRequest('Kit inconnu.', [{ field: 'kit_id', issue: 'Introuvable.' }]);
    }
    if (kit.seasonId !== seasonId) {
      throw ApiError.badRequest("Ce kit n'appartient pas à la saison en cours.", [
        { field: 'kit_id', issue: 'Kit hors saison courante.' },
      ]);
    }
    kitId = kit.id;
    kitName = kit.name;

    // Personnalisation propre à CET enfant — ne modifie jamais `kit`/`kit.items`
    // en base, seulement le prix effectif de son `SavingsGoal` (voir doc du
    // champ `customAddedItems`/`customRemovedItems` sur le modèle Prisma).
    let removedSubtotal = 0;
    if (input.removed_items?.length) {
      for (const removed of input.removed_items) {
        const match = kit.items.find((i) => i.category === removed.category && i.label === removed.label);
        if (!match) {
          throw ApiError.badRequest('Fourniture à retirer introuvable dans ce kit.', [
            { field: 'removed_items', issue: `${removed.category} / ${removed.label} absent du kit.` },
          ]);
        }
        removedSubtotal += match.quantity * match.unitPrice;
      }
    }

    let addedSubtotal = 0;
    if (input.added_items?.length) {
      const supplyIds = input.added_items.map((i) => i.supply_id);
      const supplies = await prisma.supply.findMany({ where: { id: { in: supplyIds } } });
      const supplyById = new Map(supplies.map((s) => [s.id, s]));
      for (const added of input.added_items) {
        const supply = supplyById.get(added.supply_id);
        if (!supply) {
          throw ApiError.badRequest('Fourniture à ajouter introuvable au catalogue.', [
            { field: 'added_items', issue: `supply_id ${added.supply_id} inconnu.` },
          ]);
        }
        addedSubtotal += added.quantity * supply.unitPrice;
      }
    }
    effectiveTargetAmount = kit.totalPrice + addedSubtotal - removedSubtotal;
    customAddedItems = input.added_items ?? Prisma.JsonNull;
    customRemovedItems = input.removed_items ?? Prisma.JsonNull;
  } else {
    throw ApiError.badRequest('Paramètres invalides.', [{ field: 'kit_id', issue: 'kit_id ou custom requis.' }]);
  }

  const existingGoal = await prisma.savingsGoal.findUnique({
    where: { childId_seasonId_type: { childId, seasonId, type: 'supplies' } },
  });

  // Décision produit (2026-07-28) : un enfant n'est JAMAIS refusé, même une
  // fois la souscription confirmée et des cotisations déjà versées — le prix
  // du kit s'ajoute à l'objectif restant et le montant par échéance se
  // recalcule automatiquement (`computeTotals`/`previewAddChild`, jamais
  // stocké en dur — voir `subscriptions.service.ts`). `POST
  // /parents/me/children/preview` reste disponible pour PRÉVENIR le parent
  // du nouveau montant avant qu'il n'ajoute réellement l'enfant, mais rien
  // ne bloque l'écriture elle-même.

  await prisma.$transaction(async (tx) => {
    if (input.custom && input.items) {
      kitId = await upsertCustomKit(
        tx,
        seasonId,
        childId,
        effectiveTargetAmount,
        input.items,
        child?.level ?? 'CP1',
        existingGoal?.id,
        existingGoal?.kitId,
      );
    }

    if (existingGoal) {
      await tx.savingsGoal.update({
        where: { id: existingGoal.id },
        data: {
          kitId,
          name: kitName,
          targetAmount: effectiveTargetAmount,
          customAddedItems,
          customRemovedItems,
        },
      });
      await writeAudit(tx, {
        actorId,
        action: 'child.kit_changed',
        entity: 'savings_goal',
        entityId: existingGoal.id,
        before: { kitId: existingGoal.kitId },
        after: { kitId },
      });
    } else {
      const created = await tx.savingsGoal.create({
        data: {
          parentId: clientId,
          childId,
          type: 'supplies',
          name: kitName,
          targetAmount: effectiveTargetAmount,
          kitId,
          seasonId,
          customAddedItems,
          customRemovedItems,
        },
      });
      await writeAudit(tx, {
        actorId,
        action: 'child.kit_assigned',
        entity: 'savings_goal',
        entityId: created.id,
        after: { kitId, childId },
      });
    }
  });
  notifyFamilyActedByOther(
    actorId,
    clientId,
    `Le kit "${kitName}" a été ${existingGoal ? 'modifié' : 'choisi'} pour un de vos enfants.`,
  );
  return getFamily(clientId);
}

/**
 * Définit ou met à jour un objectif d'épargne annexe (Scolarité, Transport) pour un enfant.
 */
export async function setChildGoal(
  actorId: string,
  clientId: string,
  childId: string,
  type: 'registration' | 'transport',
  amount: number,
  name?: string,
  planDetails?: { frequency: string; capacity: number }
) {
  await getChildOrThrow(clientId, childId);
  const seasonId = await currentSeasonId();

  const existingGoal = await prisma.savingsGoal.findUnique({
    where: { childId_seasonId_type: { childId, seasonId, type } },
  });

  await prisma.$transaction(async (tx) => {
    if (existingGoal) {
      await tx.savingsGoal.update({
        where: { id: existingGoal.id },
        data: { 
          targetAmount: amount, 
          ...(name ? { name } : {}),
          ...(planDetails ? { customAddedItems: planDetails as any } : {})
        },
      });
      await writeAudit(tx, {
        actorId,
        action: 'child.goal_updated',
        entity: 'savings_goal',
        entityId: existingGoal.id,
        before: { targetAmount: existingGoal.targetAmount },
        after: { targetAmount: amount, planDetails },
      });
    } else {
      const created = await tx.savingsGoal.create({
        data: {
          parentId: clientId,
          childId,
          type,
          name: name ?? (type === 'registration' ? 'Scolarité' : 'Transport'),
          targetAmount: amount,
          seasonId,
          customAddedItems: planDetails ? (planDetails as any) : null,
        },
      });
      await writeAudit(tx, {
        actorId,
        action: 'child.goal_added',
        entity: 'savings_goal',
        entityId: created.id,
        after: { targetAmount: amount, childId, planDetails },
      });
    }
  });

  notifyFamilyActedByOther(
    actorId,
    clientId,
    `L'objectif de ${type === 'registration' ? 'scolarité' : 'transport'} a été ${existingGoal ? 'mis à jour' : 'créé'} pour un de vos enfants.`
  );

  return getFamily(clientId);
}

/**
 * Valide un compte client en attente (contrat §2 — validation admin) :
 * `pendingValidation → active`. Idempotence refusée explicitement (409).
 *
 * `assignedAgentId` (optionnel) comble le trou identifié en simulation :
 * une famille auto-inscrite (OTP) n'a jamais d'agent tant que personne ne
 * la lui assigne — la validation est le point naturel pour le faire,
 * l'admin ayant déjà la ville de la famille sous les yeux pour choisir un
 * agent de la même zone (`GET /admin/agents?zone=...`). Optionnel : une
 * famille peut rester sans agent (100% self-service) si l'admin le décide.
 */
export async function approveFamily(actorId: string, clientId: string, assignedAgentId?: string) {
  const client = await getFamilyRowOrThrow(clientId);
  if (client.status !== 'pendingValidation') {
    throw ApiError.conflict('Seul un compte en attente peut être validé.');
  }

  let agentName: string | null = null;
  if (assignedAgentId) {
    const agent = await prisma.user.findFirst({
      where: { id: assignedAgentId, role: 'agent', status: 'active' },
      select: { fullName: true },
    });
    if (!agent) {
      throw ApiError.badRequest('Agent assigné inconnu ou inactif.', [
        { field: 'assigned_agent_id', issue: 'Aucun agent actif avec cet id.' },
      ]);
    }
    agentName = agent.fullName;
  }

  await prisma.$transaction(async (tx) => {
    await tx.user.update({
      where: { id: clientId },
      data: {
        status: 'active',
        rejectionReason: null,
        familyCode: generateFamilyCode(client.city),
        ...(assignedAgentId ? { assignedAgentId } : {}),
      },
    });
    await writeAudit(tx, {
      actorId,
      action: 'client.approved',
      entity: 'user',
      entityId: clientId,
      before: { status: client.status },
      after: { status: 'active', assignedAgentId: assignedAgentId ?? null },
    });
  });

  notificationsService
    .notify(
      clientId,
      'account_approved',
      'Compte validé',
      'Votre compte EduPay a été validé — vous pouvez maintenant utiliser l’application.',
    )
    .catch(() => {});
  if (agentName) {
    notificationsService
      .notify(
        clientId,
        'agent_assigned',
        'Agent assigné',
        `${agentName} est désormais votre agent référent EduPay.`,
      )
      .catch(() => {});
    notificationsService
      .notify(
        assignedAgentId!,
        'family_assigned_to_agent',
        'Nouvelle famille assignée',
        `${client.fullName} vous a été assignée comme famille référente.`,
      )
      .catch(() => {});
  }

  return getFamily(clientId);
}

/**
 * Rejette un compte client en attente : `pendingValidation → rejected`, motif
 * conservé (renvoyé au client) et sessions éventuelles révoquées.
 */
export async function rejectFamily(actorId: string, clientId: string, reason: string) {
  const client = await getFamilyRowOrThrow(clientId);
  if (client.status !== 'pendingValidation') {
    throw ApiError.conflict('Seul un compte en attente peut être rejeté.');
  }
  await prisma.$transaction(async (tx) => {
    await tx.user.update({
      where: { id: clientId },
      data: { status: 'rejected', rejectionReason: reason },
    });
    await tx.refreshToken.updateMany({
      where: { userId: clientId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    await writeAudit(tx, {
      actorId,
      action: 'client.rejected',
      entity: 'user',
      entityId: clientId,
      before: { status: client.status },
      after: { status: 'rejected', reason },
    });
  });

  notificationsService
    .notify(clientId, 'account_rejected', 'Inscription rejetée', `Votre inscription EduPay a été rejetée : ${reason}`)
    .catch(() => {});

  return getFamily(clientId);
}

/**
 * Modifie les champs de base d'une famille (nom, ville, quartier) — action
 * admin/agent « pour » la famille, distincte de `PATCH /parents/me` (la
 * famille modifie son propre profil) et de `PATCH /auth/me` (téléphone/mot
 * de passe, jamais touchés ici).
 */
export async function updateFamilyProfile(actorId: string, clientId: string, input: UpdateFamilyProfileInput) {
  await assertClientExists(clientId);
  if (Object.keys(input).length === 0) {
    throw ApiError.badRequest('Aucun champ fourni.');
  }

  const data: Prisma.UserUpdateInput = {};
  if (input.full_name !== undefined) data.fullName = input.full_name;
  if (input.city !== undefined) data.city = input.city;
  if (input.district !== undefined) data.district = input.district;

  await prisma.$transaction(async (tx) => {
    await tx.user.update({ where: { id: clientId }, data });
    await writeAudit(tx, {
      actorId,
      action: 'family.profile_updated',
      entity: 'user',
      entityId: clientId,
      after: input,
    });
  });
  return getFamily(clientId);
}

/**
 * Archive une famille — équivalent le plus proche disponible dans
 * `UserStatus` (pas de valeur "archived" dédiée) : bascule sur `suspended`,
 * qui bloque déjà tout mouvement d'argent (`payments.service.ts`) et toute
 * progression de livraison (`delivery.service.ts`) via les gardes déjà en
 * place, et révoque ses sessions actives. Pas de réactivation dans ce
 * chantier (gap déjà connu pour les comptes suspendus, non résolu).
 */
export async function archiveFamily(actorId: string, clientId: string) {
  const client = await getFamilyRowOrThrow(clientId);
  if (client.status === 'suspended') {
    throw ApiError.conflict('Cette famille est déjà archivée.');
  }

  await prisma.$transaction(async (tx) => {
    await tx.user.update({ where: { id: clientId }, data: { status: 'suspended' } });
    await tx.refreshToken.updateMany({
      where: { userId: clientId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    await writeAudit(tx, {
      actorId,
      action: 'family.archived',
      entity: 'user',
      entityId: clientId,
      before: { status: client.status },
      after: { status: 'suspended' },
    });
  });

  notificationsService
    .notify(
      clientId,
      'family_archived',
      'Compte suspendu',
      'Votre compte EduPay a été suspendu. Contactez votre agent ou l’administration pour plus d’informations.',
    )
    .catch(() => {});

  return getFamily(clientId);
}

/**
 * Assigne/réassigne/désassigne l'agent référent d'une famille EXISTANTE —
 * comble le trou identifié en simulation : jusqu'ici seule la validation
 * d'un compte en attente (`approveFamily`) ou l'enrôlement direct
 * permettaient de poser un agent, jamais un changement après coup (agent
 * muté, parti, zone changée). `agentId: null` désassigne explicitement.
 */
export async function reassignAgent(actorId: string, clientId: string, agentId: string | null) {
  const client = await getFamilyRowOrThrow(clientId);

  let agentName: string | null = null;
  if (agentId) {
    const agent = await prisma.user.findFirst({
      where: { id: agentId, role: 'agent', status: 'active' },
      select: { fullName: true },
    });
    if (!agent) {
      throw ApiError.badRequest('Agent assigné inconnu ou inactif.', [
        { field: 'assigned_agent_id', issue: 'Aucun agent actif avec cet id.' },
      ]);
    }
    agentName = agent.fullName;
  }

  await prisma.$transaction(async (tx) => {
    await tx.user.update({ where: { id: clientId }, data: { assignedAgentId: agentId } });
    await writeAudit(tx, {
      actorId,
      action: 'family.agent_reassigned',
      entity: 'user',
      entityId: clientId,
      before: { assignedAgentId: client.assignedAgentId },
      after: { assignedAgentId: agentId },
    });
  });

  // Ne notifie que si l'assignation change réellement quelque chose (évite
  // un message creux si l'admin repose le même agent sans le changer).
  if (client.assignedAgentId !== agentId) {
    notificationsService
      .notify(
        clientId,
        'agent_assigned',
        agentName ? 'Agent assigné' : 'Agent désassigné',
        agentName
          ? `${agentName} est désormais votre agent référent EduPay.`
          : 'Aucun agent ne vous est plus assigné pour le moment.',
      )
      .catch(() => {});
    if (agentId) {
      notificationsService
        .notify(
          agentId,
          'family_assigned_to_agent',
          'Nouvelle famille assignée',
          `${client.fullName} vous a été assignée comme famille référente.`,
        )
        .catch(() => {});
    }
  }

  return getFamily(clientId);
}

/** Historique comptable complet d'une famille (contributions confirmées +
 * remboursements approuvés) — équivalent "wallet transactions" : le journal
 * `LedgerEntry` est déjà alimenté par `payments.service.ts` et
 * `refunds.service.ts`, jamais exposé par une route jusqu'ici. */
export async function listFamilyLedger(clientId: string) {
  await assertClientExists(clientId);
  const entries = await prisma.ledgerEntry.findMany({
    where: { parentId: clientId },
    orderBy: { createdAt: 'desc' },
  });
  return entries.map((e) => ({
    id: e.id,
    entry_type: e.entryType,
    amount: e.amount,
    reference: e.reference,
    created_at: e.createdAt.toISOString(),
  }));
}

/**
 * Materialise un kit personnalisé (sans enfant) pour une saison donnée —
 * utilisé par `assignKit` pour les cas où le parent choisit des fournitures
 * spécifiques plutôt qu'un kit prédéfini. Le prix total du kit est recalculé
 * à chaque appel en fonction des fournitures ajoutées/retirées.
 *
 * Crée ou met à jour en fonction de l'existence d'un `existingKitId` :
 * - si fourni, le kit est mis à jour (nom, périmètre, prix total) ;
 * - sinon, un nouveau kit est créé.
 *
 * Les éléments du kit (fournitures) sont remplacés en bloc : suppression de
 * l'ancien contenu puis ajout du nouveau. Les quantités et prix unitaires
 * sont ceux fournis par le parent dans `input.items`.
 */
async function upsertCustomKit(
  tx: Prisma.TransactionClient,
  seasonId: string,
  childId: string,
  targetAmount: number,
  items: Array<{ name: string; quantity: number; price: number }>,
  levelScope: string,
  existingGoalId?: string,
  existingKitId?: string | null,
): Promise<string> {
  let kitId = existingKitId;
  const kitName = 'Kit Personnalisé';

  if (!kitId) {
    const created = await tx.kit.create({
      data: {
        tier: 'basic',
        name: kitName,
        levelScope: levelScope.trim() || 'CP1',
        totalPrice: targetAmount,
        seasonId,
        isActive: true,
      },
    });
    kitId = created.id;
  } else {
    await tx.kit.update({
      where: { id: kitId },
      data: {
        name: kitName,
        levelScope: levelScope.trim() || 'CP1',
        totalPrice: targetAmount,
      },
    });
  }

  await tx.kitItem.deleteMany({ where: { kitId } });
  if (items.length > 0) {
    await tx.kitItem.createMany({
      data: items.map((item) => ({
        kitId,
        category: 'Personnalisé',
        label: item.name,
        quantity: item.quantity,
        unit: 'unité',
        unitPrice: item.price,
      })),
    });
  }

  if (existingGoalId) {
    await tx.savingsGoal.update({
      where: { id: existingGoalId },
      data: { kitId },
    });
  }

  return kitId;
}

/** Assign a location and/or agent to a specific delivery. */
export async function assignDeliveryLocation(
  actorId: string,
  deliveryId: string,
  input: { lat?: number; lng?: number; address?: string; assigned_agent_id?: string },
) {
  const delivery = await prisma.delivery.findUnique({ where: { id: deliveryId } });
  if (!delivery) throw ApiError.notFound('Livraison introuvable.');

  const data: Prisma.DeliveryUpdateInput = {};
  if (input.lat !== undefined) data.locationLat = input.lat;
  if (input.lng !== undefined) data.locationLng = input.lng;
  if (input.address !== undefined) data.address = input.address;
  if (input.assigned_agent_id !== undefined) data.assignedAgentId = input.assigned_agent_id;

  if (Object.keys(data).length === 0) return delivery;

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.delivery.update({ where: { id: deliveryId }, data });
    await writeAudit(tx, {
      actorId,
      action: 'delivery.assigned',
      entity: 'delivery',
      entityId: deliveryId,
      after: input,
    });
    return u;
  });

  return updated;
}
