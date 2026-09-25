import type { Request, Response } from 'express';
import { list, ok } from '../../shared/http/respond.js';
import * as kitsService from '../kits/kits.service.js';
import * as suppliesService from '../supplies/supplies.service.js';
import * as seasonsService from '../seasons/seasons.service.js';

const FREQUENCIES = [
  { frequency: 'daily', label: 'Journalier' },
  { frequency: 'weekly', label: 'Hebdomadaire' },
  { frequency: 'monthly', label: 'Mensuel' },
] as const;

/** Catalogue de kits de la saison courante — lecture publique (§ contrat,
 * un prospect peut consulter les prix avant de s'inscrire). `?level_scope=`
 * restreint aux kits d'une classe précise (agent/client, qui ciblent un
 * enfant) ; omis, renvoie tout le catalogue (admin). */
export async function kitsHandler(req: Request, res: Response): Promise<void> {
  const levelScope = typeof req.query.level_scope === 'string' ? req.query.level_scope : undefined;
  list(res, await kitsService.listKits(levelScope));
}

/** Fournitures individuelles — utile pour un futur kit personnalisé côté
 * client (hors périmètre actuel : l'app Admin ne compose pas de kit "à la
 * carte" pour une famille, voir mémo projet). */
export async function articlesHandler(_req: Request, res: Response): Promise<void> {
  list(res, await suppliesService.listSupplies());
}

/** Fréquences de cotisation disponibles — pas de catalogue de "plans" en
 * base : le montant par échéance est toujours dérivé du prix des kits
 * choisis et de l'échéance de la saison, jamais un montant de base fixe. */
export async function plansHandler(_req: Request, res: Response): Promise<void> {
  list(res, [...FREQUENCIES]);
}

/** Saison courante active — consultation publique pour le calcul dynamique des échéances. */
export async function currentSeasonHandler(_req: Request, res: Response): Promise<void> {
  ok(res, await seasonsService.getCurrentSeason());
}
