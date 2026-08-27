import type { Response } from 'express';

/** Réponses normalisées selon le contrat §1 (objet nu, listes enveloppées). */

export interface PageMeta {
  page: number;
  perPage: number;
  total: number;
}

export function ok(res: Response, data: unknown): void {
  res.status(200).json(data);
}

export function created(res: Response, data: unknown): void {
  res.status(201).json(data);
}

export function noContent(res: Response): void {
  res.status(204).send();
}

export function list(res: Response, data: unknown[], meta?: PageMeta): void {
  res.status(200).json(meta ? { data, meta } : { data });
}
