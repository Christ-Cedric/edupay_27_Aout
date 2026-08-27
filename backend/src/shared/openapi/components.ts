import { z } from 'zod';
import { registry } from './registry.js';

/**
 * Schémas de RÉPONSE (documentation). Les corps de REQUÊTE, eux, réutilisent
 * directement les schémas zod des modules — source de vérité unique. Ces DTO
 * reflètent les serializers (`auth.serializer.ts`, `toAgentDto`) en snake_case.
 */

export const UserDto = registry.register(
  'UserDto',
  z
    .object({
      id: z.string().uuid(),
      role: z.enum(['admin', 'agent', 'client']),
      full_name: z.string(),
      phone: z.string(),
      status: z.enum(['pendingValidation', 'active', 'rejected', 'suspended']),
      city: z.string().nullable(),
      district: z.string().nullable(),
      must_change_password: z.boolean(),
      rejection_reason: z.string().nullable(),
    })
    .openapi('UserDto', {
      example: {
        id: '3f2a1c8e-0b6d-4e2a-9c11-7a8b9d0e1f23',
        role: 'admin',
        full_name: 'DERRA Bassirou',
        phone: '+22676691911',
        status: 'active',
        city: null,
        district: null,
        must_change_password: false,
        rejection_reason: null,
      },
    }),
);

export const SessionDto = registry.register(
  'SessionDto',
  z
    .object({
      access_token: z.string(),
      refresh_token: z.string(),
      user: UserDto,
    })
    .openapi('SessionDto'),
);

export const OtpRequestResponseDto = registry.register(
  'OtpRequestResponseDto',
  z
    .object({
      dev_code: z.string().optional().openapi({
        description: 'Présent uniquement si OTP_DEV_EXPOSE=true (dev/test).',
      }),
    })
    .openapi('OtpRequestResponseDto'),
);

export const OtpVerifyResponseDto = registry.register(
  'OtpVerifyResponseDto',
  z
    .object({
      registration_token: z.string().openapi({
        description: 'Jeton de portée à usage unique pour POST /auth/register (15 min).',
      }),
    })
    .openapi('OtpVerifyResponseDto'),
);

export const AgentDto = registry.register(
  'AgentDto',
  z
    .object({
      id: z.string(),
      full_name: z.string(),
      phone: z.string(),
      zone: z.string(),
      district: z.string().nullable(),
      client_count: z.number().int(),
      commission: z.number().int().openapi({ description: 'Commission cumulée (FCFA).' }),
      contract_type: z.enum(['volunteer', 'paid']),
      status: z.enum(['active', 'suspended']),
      temporary_password: z
        .string()
        .optional()
        .openapi({ description: 'Présent uniquement à la création si généré côté serveur.' }),
    })
    .openapi('AgentDto'),
);

export const FamilyChildDto = registry.register(
  'FamilyChildDto',
  z
    .object({
      id: z.string(),
      first_name: z.string(),
      level: z.string().openapi({ description: 'Niveau scolaire (ex. "CM2") — "" si non renseigné.' }),
      school: z.string().openapi({ description: 'Nom de l\'école — "" si non renseigné.' }),
      kit_id: z.string().nullable().openapi({
        description: 'Kit choisi pour la saison en cours — `null` si aucun kit choisi cette saison.',
      }),
      target_amount: z.number().int().nullable().openapi({
        description: 'Prix du kit de cet enfant pour la saison en cours (FCFA) — `null` si pas de kit.',
      }),
      saved_amount: z.number().int().nullable(),
    })
    .openapi('FamilyChildDto'),
);

export const FamilyDto = registry.register(
  'FamilyDto',
  z
    .object({
      id: z.string(),
      full_name: z.string(),
      phone: z.string(),
      city: z.string(),
      plan: z.enum(['daily', 'weekly', 'monthly']),
      balance: z.number().int().openapi({ description: 'Épargné à ce jour, tous enfants confondus (FCFA).' }),
      target_amount: z
        .number()
        .int()
        .openapi({ description: 'Objectif = somme des kits de chaque enfant (FCFA).' }),
      children: z
        .array(FamilyChildDto)
        .openapi({ description: 'Un kit par enfant (§7 #2 du contrat) ; children.length = children_count.' }),
      status: z.enum(['pendingValidation', 'active', 'lateOverdue', 'rejected']),
      delivery_status: z.enum(['pending', 'inProgress', 'delivered']),
      registered_at: z.string().datetime(),
      assigned_agent_name: z.string().nullable(),
      rejection_reason: z.string().nullable(),
      district: z.string().nullable().openapi({ description: 'Quartier libre, saisi à l\'inscription (optionnel).' }),
      family_code: z.string().nullable().openapi({
        description: 'Identification terrain rapide (QR agent) — posé à la validation admin, `null` avant.',
      }),
    })
    .openapi('FamilyDto'),
);

export const DashboardDto = registry.register(
  'DashboardDto',
  z
    .object({
      season: z.string().openapi({ description: 'Libellé saison courante ("" si aucune).' }),
      active_families: z.number().int(),
      total_collected: z.number().int().openapi({ description: 'Épargne cumulée (FCFA).' }),
      collection_rate: z.number().openapi({ description: 'Ratio ∈ [0,1].' }),
      overdue_payments: z.number().int(),
      active_agents: z.number().int(),
      pending_deliveries: z.number().int(),
      alerts: z.array(
        z.object({
          code: z.string().openapi({
            description:
              'Identifiant stable (pending_validation, overdue_payments, pending_deliveries, season_progress) — sert au client à router au tap, indépendant du texte affiché.',
          }),
          title: z.string(),
          subtitle: z.string(),
          severity: z.enum(['danger', 'warning', 'info']),
        }),
      ),
    })
    .openapi('DashboardDto'),
);

export const SeasonDto = registry.register(
  'SeasonDto',
  z
    .object({
      id: z.string(),
      label: z.string(),
      launch_date: z.string().datetime(),
      delivery_deadline: z.string().datetime(),
      enrollment_open: z.boolean(),
      refund_fee: z.number().int(),
      is_current: z.boolean(),
    })
    .openapi('SeasonDto'),
);

export const KitItemDto = registry.register(
  'KitItemDto',
  z
    .object({
      category: z.string().openapi({ description: 'Catégorie libre (ex. "Cahiers & Écriture").' }),
      label: z.string(),
      quantity: z.number().int(),
      unit: z.string().openapi({ description: 'Ex. "unité", "boîte", "lot", "paire".' }),
      unit_price: z.number().int().openapi({ description: 'Prix unitaire (FCFA).' }),
    })
    .openapi('KitItemDto'),
);

export const KitDto = registry.register(
  'KitDto',
  z
    .object({
      id: z.string(),
      level: z.enum(['basic', 'intermediate', 'premium']).openapi({
        description: 'Variant selon le budget de la famille (pas la classe).',
      }),
      level_scope: z.string().openapi({ description: 'Classe ciblée (ex. "CM2").' }),
      price: z.number().int().openapi({
        description: 'Toujours Σ(quantity × unit_price) sur les fournitures — jamais saisi.',
      }),
      items: z.array(KitItemDto),
    })
    .openapi('KitDto'),
);

export const SupplyDto = registry.register(
  'SupplyDto',
  z
    .object({
      id: z.string(),
      category: z.string().openapi({ description: 'Catégorie libre (ex. "Cahiers & Écriture").' }),
      label: z.string(),
      unit: z.string().openapi({ description: 'Ex. "unité", "boîte", "lot", "paire".' }),
      unit_price: z.number().int().openapi({ description: 'Prix unitaire (FCFA).' }),
    })
    .openapi('SupplyDto'),
);

export const ImportKitsSummaryDto = registry.register(
  'ImportKitsSummaryDto',
  z
    .object({
      created: z.number().int().openapi({ description: 'Nouveaux kits créés.' }),
      updated: z.number().int().openapi({
        description: 'Kits existants (même classe + variant) remplacés.',
      }),
      warnings: z.array(z.string()).openapi({
        description: 'Classes du fichier non reconnues — jamais importées silencieusement.',
      }),
    })
    .openapi('ImportKitsSummaryDto'),
);

export const CollectionDto = registry.register(
  'CollectionDto',
  z
    .object({
      id: z.string(),
      family_id: z.string(),
      family_name: z.string(),
      agent_name: z.string().nullable(),
      amount: z.number().int(),
      mode: z.enum(['cash', 'orangeMoney', 'moovMoney', 'wave']),
      collected_at: z.string().datetime(),
      receipt_number: z.string(),
    })
    .openapi('CollectionDto'),
);

export const RefundRequestDto = registry.register(
  'RefundRequestDto',
  z
    .object({
      id: z.string(),
      reference: z.string().openapi({ example: 'RMB-2026-0A1B2C' }),
      family_name: z.string(),
      amount: z.number().int(),
      reason: z.string(),
    })
    .openapi('RefundRequestDto'),
);

export const RefundDetailDto = registry.register(
  'RefundDetailDto',
  z
    .object({
      id: z.string(),
      reference: z.string(),
      family_name: z.string(),
      amount: z.number().int(),
      reason: z.string(),
      status: z.enum(['requested', 'processing', 'approved', 'rejected', 'refunded']),
      processed_by_admin_name: z.string().nullable(),
      created_at: z.string().datetime(),
    })
    .openapi('RefundDetailDto'),
);

export const RefundMonthSummaryDto = registry.register(
  'RefundMonthSummaryDto',
  z
    .object({
      approved_count: z.number().int(),
      approved_amount: z.number().int(),
      fees_retained: z.number().int(),
    })
    .openapi('RefundMonthSummaryDto'),
);

export const RefundsResponse = registry.register(
  'RefundsResponse',
  z
    .object({
      pending: z.array(RefundRequestDto),
      month_summary: RefundMonthSummaryDto,
    })
    .openapi('RefundsResponse'),
);

export const SelfRefundDto = registry.register(
  'SelfRefundDto',
  z
    .object({
      id: z.string(),
      reference: z.string(),
      amount: z.number().int().openapi({
        description: 'Toujours calculé serveur : solde disponible − frais de la saison courante.',
      }),
      reason: z.string(),
      status: z.enum(['requested', 'processing', 'approved', 'rejected', 'refunded']),
      created_at: z.string().datetime(),
    })
    .openapi('SelfRefundDto'),
);

export const ContributionDto = registry.register(
  'ContributionDto',
  z
    .object({
      id: z.string(),
      parent_id: z.string(),
      amount: z.number().int(),
      method: z.enum(['orangeMoney', 'moovMoney', 'wave', 'cashAgent']),
      reference: z.string(),
      status: z.enum(['pendingValidation', 'confirmed', 'failed']),
      collected_by_agent_id: z.string().nullable(),
      provider: z.string().nullable().openapi({ description: 'ex. "ligdicash" ; null pour le cash.' }),
      provider_reference: z.string().nullable(),
      created_at: z.string().datetime(),
      confirmed_at: z.string().datetime().nullable(),
    })
    .openapi('ContributionDto'),
);

export const DeliveryIssueDto = registry.register(
  'DeliveryIssueDto',
  z
    .object({
      id: z.string(),
      type: z.enum(['not_received', 'missing_item', 'damaged_item', 'late_delivery', 'other']),
      description: z.string(),
      photo_url: z.string().nullable(),
      status: z.enum(['open', 'resolved']),
      created_at: z.string().datetime(),
    })
    .openapi('DeliveryIssueDto'),
);

export const DeliveryDto = registry.register(
  'DeliveryDto',
  z
    .object({
      id: z.string(),
      child_id: z.string().nullable(),
      kit_id: z.string(),
      status: z.enum(['preparation', 'shipped', 'out_for_delivery', 'delivered', 'receipt_confirmed']).openapi({
        description: 'Kit par enfant (§7 #2) : une livraison = un kit = un enfant.',
      }),
      location: z
        .object({ lat: z.number(), lng: z.number(), address: z.string() })
        .nullable(),
      signed_at: z.string().datetime().nullable(),
      scheduled_at: z.string().datetime().nullable().openapi({
        description: 'Date de passage prévue (planification agent — "livraisons du jour").',
      }),
      signature: z.string().nullable().openapi({
        description: 'Signature capturée par l\'agent sur son appareil (base64) — voir POST .../confirm.',
      }),
      issues: z.array(DeliveryIssueDto),
    })
    .openapi('DeliveryDto'),
);

export const NotificationDto = registry.register(
  'NotificationDto',
  z
    .object({
      id: z.string(),
      type: z.string().openapi({ example: 'contribution_received' }),
      title: z.string(),
      body: z.string(),
      channel: z.enum(['push', 'sms', 'whatsapp', 'in_app']),
      read_at: z.string().datetime().nullable(),
      sent_at: z.string().datetime().nullable().openapi({
        description: 'Horodatage de l\'envoi réel sur `channel` — `null` tant que non tenté.',
      }),
      error: z.string().nullable().openapi({
        description: 'Raison de l\'échec d\'envoi WhatsApp (ex. non configuré) — `null` si envoyé ou non tenté.',
      }),
      push_sent_at: z.string().datetime().nullable().openapi({
        description: 'Horodatage de l\'envoi push FCM (canal séparé, tenté en plus de `channel`) — `null` tant que non tenté.',
      }),
      push_error: z.string().nullable().openapi({
        description: 'Raison de l\'échec push (ex. Firebase non configuré, aucun appareil enregistré).',
      }),
      created_at: z.string().datetime(),
    })
    .openapi('NotificationDto'),
);

export const AgentCommissionDto = registry.register(
  'AgentCommissionDto',
  z
    .object({
      id: z.string(),
      contribution_id: z.string(),
      amount: z.number().int().openapi({ description: 'Commission créditée (FCFA).' }),
      rate_bps: z.number().int().openapi({ description: 'Taux appliqué, en points de base (200 = 2 %).' }),
      contribution_amount: z.number().int(),
      method: z.enum(['orangeMoney', 'moovMoney', 'wave', 'cashAgent']),
      created_at: z.string().datetime(),
    })
    .openapi('AgentCommissionDto'),
);

export const AgentDashboardDto = registry.register(
  'AgentDashboardDto',
  z
    .object({
      active_clients: z.number().int(),
      new_this_month: z.number().int(),
      collected_this_month: z.number().int(),
      late_count: z.number().int(),
      commissions: z.object({
        this_month: z.number().int(),
        last_month: z.number().int(),
        total_season: z.number().int(),
      }),
    })
    .openapi('AgentDashboardDto'),
);

export const DirectorContactDto = registry.register(
  'DirectorContactDto',
  z
    .object({
      whatsapp_url: z.string().nullable(),
      phone_number: z.string().nullable(),
    })
    .openapi('DirectorContactDto'),
);

export const ActiveSessionDto = registry.register(
  'ActiveSessionDto',
  z
    .object({
      id: z.string(),
      device: z.string().nullable().openapi({ description: 'User-Agent capturé à la connexion.' }),
      ip: z.string().nullable(),
      last_used_at: z.string().datetime(),
      created_at: z.string().datetime(),
    })
    .openapi('ActiveSessionDto'),
);

export const AddChildPreviewDto = registry.register(
  'AddChildPreviewDto',
  z
    .object({
      current_goal: z.number().int(),
      new_goal: z.number().int(),
      saved_amount: z.number().int(),
      remaining: z.number().int(),
      remaining_periods: z.number().int(),
      current_per_period: z.number().int(),
      new_per_period: z.number().int(),
      increase_ratio: z.number().nullable(),
      feasible: z.boolean().openapi({
        description:
          'Purement informatif — un ajout n’est JAMAIS refusé à l’écriture, même si `feasible: false` ici ' +
          '(le montant par échéance est juste recalculé, plus élevé). Sert à avertir le parent avant qu’il ne confirme.',
      }),
      requires_revision: z.boolean().openapi({
        description: 'true si la souscription est déjà confirmée (un ajout avant confirmation est toujours simple).',
      }),
      warnings: z.array(z.string()),
      rejection_code: z.string().nullable().openapi({
        description: 'Raison de l’avertissement (ex. UNAFFORDABLE_PLAN) — indicatif, n’empêche jamais l’ajout.',
      }),
    })
    .openapi('AddChildPreviewDto'),
);

export const SubscriptionConfirmationDto = registry.register(
  'SubscriptionConfirmationDto',
  z
    .object({
      id: z.string(),
      frequency: z.enum(['daily', 'weekly', 'monthly']),
      status: z.enum(['draft', 'confirmed']),
      confirmed_at: z.string().datetime().nullable(),
      total_goal: z.number().int(),
      per_period_amount: z.number().int(),
      remaining_periods: z.number().int(),
    })
    .openapi('SubscriptionConfirmationDto'),
);

export const LedgerEntryDto = registry.register(
  'LedgerEntryDto',
  z
    .object({
      id: z.string(),
      entry_type: z.string().openapi({ example: 'contribution_confirmed' }),
      amount: z.number().int().openapi({ description: 'Signé : positif = cotisation, négatif = remboursement.' }),
      reference: z.string(),
      created_at: z.string().datetime(),
    })
    .openapi('LedgerEntryDto'),
);

export const SendReportResponseDto = registry.register(
  'SendReportResponseDto',
  z
    .object({
      whatsapp_url: z.string().nullable().openapi({
        description: '`null` si WHATSAPP_DIRECTOR_NUMBER n\'est pas configuré.',
      }),
    })
    .openapi('SendReportResponseDto'),
);

export const AuditLogDto = registry.register(
  'AuditLogDto',
  z
    .object({
      id: z.string(),
      actor_id: z.string(),
      actor_name: z.string().nullable(),
      action: z.string().openapi({ example: 'user.suspended' }),
      entity: z.string().openapi({ example: 'user' }),
      entity_id: z.string().nullable(),
      before: z.unknown().nullable(),
      after: z.unknown().nullable(),
      created_at: z.string().datetime(),
    })
    .openapi('AuditLogDto'),
);

/** Métadonnée de pagination (contrat §1). */
export const PageMeta = registry.register(
  'PageMeta',
  z
    .object({
      page: z.number().int(),
      perPage: z.number().int(),
      total: z.number().int(),
    })
    .openapi('PageMeta'),
);

/** Enveloppe d'erreur unifiée — contrat §1.1. */
export const ErrorResponse = registry.register(
  'ErrorResponse',
  z
    .object({
      error: z.object({
        code: z.string(),
        message: z.string(),
        details: z
          .array(z.record(z.string(), z.unknown()))
          .openapi({ description: 'Détails contextuels (ex. erreurs de champ).' }),
      }),
    })
    .openapi('ErrorResponse', {
      example: {
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Données invalides.',
          details: [{ field: 'phone', issue: 'String must contain at least 8 character(s)' }],
        },
      },
    }),
);

/** Réponse d'erreur prête à brancher dans `responses` d'un path. */
export function errorResponse(description: string) {
  return {
    description,
    content: { 'application/json': { schema: ErrorResponse } },
  };
}

/** Réponse JSON de succès à partir d'un schéma. */
export function jsonResponse(description: string, schema: z.ZodTypeAny) {
  return {
    description,
    content: { 'application/json': { schema } },
  };
}

/** Réponse liste paginée `{ data: [...], meta }` (contrat §1). */
export function paginatedResponse(description: string, itemSchema: z.ZodTypeAny) {
  return jsonResponse(
    description,
    z.object({ data: z.array(itemSchema), meta: PageMeta }),
  );
}
