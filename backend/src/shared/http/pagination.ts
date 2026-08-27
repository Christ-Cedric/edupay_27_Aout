import { z } from 'zod';
import type { PageMeta } from './respond.js';

/** Bornes de pagination — protègent la DB d'un `perPage` abusif. */
const MAX_PER_PAGE = 100;

/**
 * Schéma de query commun aux listes. `coerce` car les query params sont des
 * strings. `perPage` plafonné pour éviter qu'un client demande 1e9 lignes.
 */
export const paginationQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  perPage: z.coerce.number().int().positive().max(MAX_PER_PAGE).default(20),
  search: z.string().trim().min(1).max(100).optional(),
});

export type PaginationQuery = z.infer<typeof paginationQuerySchema>;

/** Traduit page/perPage en `skip`/`take` Prisma. */
export function toPrismaRange(q: Pick<PaginationQuery, 'page' | 'perPage'>) {
  return { skip: (q.page - 1) * q.perPage, take: q.perPage };
}

/** Construit la métadonnée de pagination renvoyée au client. */
export function buildMeta(
  q: Pick<PaginationQuery, 'page' | 'perPage'>,
  total: number,
): PageMeta {
  return { page: q.page, perPage: q.perPage, total };
}
