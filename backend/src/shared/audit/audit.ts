import { Prisma } from '@prisma/client';

/**
 * Journal d'audit immuable (contrat §3.11). Volontairement SANS clé étrangère
 * sur `actorId`/`entityId` : une entrée d'audit doit survivre à la suppression
 * du compte concerné et ne jamais être effacée par cascade. Append-only : aucun
 * update/delete applicatif.
 */

/** Actions traçées — union fermée pour éviter les fautes de frappe. */
export type AuditAction =
  | 'agent.created'
  | 'user.suspended'
  | 'user.reactivated'
  | 'client.approved'
  | 'client.rejected'
  | 'family.enrolled'
  | 'family.incident_reported'
  | 'family.profile_updated'
  | 'child.added'
  | 'child.updated'
  | 'child.removed'
  | 'child.goal_added'
  | 'child.goal_updated'
  | 'child.kit_assigned'
  | 'child.kit_changed'
  | 'season.created'
  | 'season.updated'
  | 'season.set_current'
  | 'kit.created'
  | 'kit.updated'
  | 'kit.active_changed'
  | 'kit.deleted'
  | 'kit.catalog_imported'
  | 'supply.created'
  | 'supply.updated'
  | 'supply.deleted'
  | 'refund.approved'
  | 'refund.rejected'
  | 'refund.requested'
  | 'contribution.initiated'
  | 'contribution.confirmed'
  | 'contribution.failed'
  | 'delivery.location_sent'
  | 'delivery.receipt_confirmed'
  | 'delivery.issue_reported'
  | 'delivery.status_advanced'
  | 'delivery.scheduled'
  | 'delivery.confirmed_by_agent'
  | 'goal.completed'
  | 'commission.credited'
  | 'family.reminded'
  | 'family.archived'
  | 'family.agent_reassigned'
  | 'subscription.confirmed';

export interface AuditInput {
  actorId: string;
  action: AuditAction;
  entity: string;
  entityId?: string;
  before?: Prisma.InputJsonValue;
  after?: Prisma.InputJsonValue;
}

// Accepte le client Prisma principal OU un client de transaction : l'audit doit
// pouvoir être écrit dans la même transaction que l'action qu'il trace.
type Db = Prisma.TransactionClient;

/** Écrit une entrée d'audit. À appeler DANS la transaction de l'action. */
export function writeAudit(db: Db, input: AuditInput) {
  return db.auditLog.create({
    data: {
      actorId: input.actorId,
      action: input.action,
      entity: input.entity,
      entityId: input.entityId,
      before: input.before ?? Prisma.JsonNull,
      after: input.after ?? Prisma.JsonNull,
    },
  });
}
