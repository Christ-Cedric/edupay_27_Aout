import { prisma } from '../../shared/prisma.js';
import { env } from '../../config/env.js';
import { ApiError } from '../../shared/http/api-error.js';
import type { ContributionMethod } from '@prisma/client';

export interface PaymentGatewayDto {
  id: string;
  name: string;
  display_name: string;
  is_active: boolean;
  is_sandbox: boolean;
  base_url: string | null;
  supported_methods: string[];
  created_at: string;
  updated_at: string;
}

export async function ensureDefaultGateways(): Promise<void> {
  const existing = await prisma.paymentGatewayConfig.findUnique({ where: { name: 'ligdicash' } });
  if (!existing) {
    const isSandboxDefault = env.PAYMENT_GATEWAY_SANDBOX ?? (env.NODE_ENV !== 'production' || !env.LIGDICASH_API_KEY);
    await prisma.paymentGatewayConfig.create({
      data: {
        name: 'ligdicash',
        displayName: 'LigdiCash (Orange Money / Moov Money / Wave)',
        isActive: true,
        isSandbox: isSandboxDefault,
        apiKey: env.LIGDICASH_API_KEY ?? null,
        authToken: env.LIGDICASH_AUTH_TOKEN ?? null,
        webhookSecret: env.LIGDICASH_WEBHOOK_SECRET ?? null,
        baseUrl: env.LIGDICASH_BASE_URL,
        supportedMethods: ['orangeMoney', 'moovMoney', 'wave'],
      },
    });
  }
}

export async function getGatewayConfig(name = 'ligdicash') {
  let config = await prisma.paymentGatewayConfig.findUnique({ where: { name } });
  if (!config) {
    await ensureDefaultGateways();
    config = await prisma.paymentGatewayConfig.findUnique({ where: { name } });
  }
  return config;
}

export async function listPaymentGateways(): Promise<PaymentGatewayDto[]> {
  await ensureDefaultGateways();
  const gateways = await prisma.paymentGatewayConfig.findMany({ orderBy: { createdAt: 'asc' } });
  return gateways.map((g) => ({
    id: g.id,
    name: g.name,
    display_name: g.displayName,
    is_active: g.isActive,
    is_sandbox: g.isSandbox,
    base_url: g.baseUrl,
    supported_methods: (g.supportedMethods as string[]) ?? ['orangeMoney', 'moovMoney', 'wave'],
    created_at: g.createdAt.toISOString(),
    updated_at: g.updatedAt.toISOString(),
  }));
}

export async function updatePaymentGateway(
  name: string,
  input: { is_active?: boolean; is_sandbox?: boolean; api_key?: string; auth_token?: string; webhook_secret?: string; base_url?: string }
): Promise<PaymentGatewayDto> {
  const existing = await getGatewayConfig(name);
  if (!existing) {
    throw ApiError.notFound(`Passerelle de paiement "${name}" introuvable.`);
  }

  const updated = await prisma.paymentGatewayConfig.update({
    where: { name },
    data: {
      ...(input.is_active !== undefined ? { isActive: input.is_active } : {}),
      ...(input.is_sandbox !== undefined ? { isSandbox: input.is_sandbox } : {}),
      ...(input.api_key !== undefined ? { apiKey: input.api_key } : {}),
      ...(input.auth_token !== undefined ? { authToken: input.auth_token } : {}),
      ...(input.webhook_secret !== undefined ? { webhookSecret: input.webhook_secret } : {}),
      ...(input.base_url !== undefined ? { baseUrl: input.base_url } : {}),
    },
  });

  return {
    id: updated.id,
    name: updated.name,
    display_name: updated.displayName,
    is_active: updated.isActive,
    is_sandbox: updated.isSandbox,
    base_url: updated.baseUrl,
    supported_methods: (updated.supportedMethods as string[]) ?? ['orangeMoney', 'moovMoney', 'wave'],
    created_at: updated.createdAt.toISOString(),
    updated_at: updated.updatedAt.toISOString(),
  };
}

export async function resolveActiveGateway(method: ContributionMethod) {
  if (method === 'cashAgent') return null;

  await ensureDefaultGateways();
  const gateways = await prisma.paymentGatewayConfig.findMany({ where: { isActive: true } });

  const matching = gateways.find((g) => {
    const methods = (g.supportedMethods as string[]) ?? [];
    return methods.includes(method);
  });

  if (!matching) {
    throw ApiError.serviceUnavailable(
      `Aucune passerelle de paiement active n'est configurée pour le moyen de paiement "${method}". ` +
      `Vérifiez les passerelles dans l'administration ou contactez l'administrateur.`
    );
  }

  return matching;
}
