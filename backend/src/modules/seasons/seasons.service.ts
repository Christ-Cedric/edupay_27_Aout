import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { toSeasonDto } from './seasons.serializer.js';
import type { CreateSeasonInput, UpdateSeasonInput } from './seasons.schemas.js';

async function getSeasonOrThrow(id: string) {
  const season = await prisma.season.findUnique({ where: { id } });
  if (!season) throw ApiError.notFound('Saison introuvable.');
  return season;
}

export async function listSeasons() {
  const seasons = await prisma.season.findMany({ orderBy: { launchDate: 'desc' } });
  return seasons.map(toSeasonDto);
}

export async function getSeason(id: string) {
  return toSeasonDto(await getSeasonOrThrow(id));
}

export async function createSeason(actorId: string, input: CreateSeasonInput) {
  const season = await prisma.$transaction(async (tx) => {
    const created = await tx.season.create({
      data: {
        label: input.label,
        launchDate: input.launch_date,
        deliveryDeadline: input.delivery_deadline,
        enrollmentOpen: input.enrollment_open,
        refundFee: input.refund_fee,
      },
    });
    await writeAudit(tx, {
      actorId,
      action: 'season.created',
      entity: 'season',
      entityId: created.id,
      after: { label: created.label },
    });
    return created;
  });
  return toSeasonDto(season);
}

export async function updateSeason(actorId: string, id: string, input: UpdateSeasonInput) {
  const existing = await getSeasonOrThrow(id);

  // Valeurs effectives après fusion, pour revalider l'invariant de dates.
  const launchDate = input.launch_date ?? existing.launchDate;
  const deliveryDeadline = input.delivery_deadline ?? existing.deliveryDeadline;
  if (deliveryDeadline <= launchDate) {
    throw ApiError.badRequest('La date limite de livraison doit être postérieure au lancement.', [
      { field: 'delivery_deadline', issue: 'Doit être postérieure à launch_date.' },
    ]);
  }

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.season.update({
      where: { id },
      data: {
        label: input.label,
        launchDate: input.launch_date,
        deliveryDeadline: input.delivery_deadline,
        enrollmentOpen: input.enrollment_open,
        refundFee: input.refund_fee,
      },
    });
    await writeAudit(tx, {
      actorId,
      action: 'season.updated',
      entity: 'season',
      entityId: id,
      before: {
        label: existing.label,
        enrollmentOpen: existing.enrollmentOpen,
        refundFee: existing.refundFee,
      },
      after: { label: u.label, enrollmentOpen: u.enrollmentOpen, refundFee: u.refundFee },
    });
    return u;
  });
  return toSeasonDto(updated);
}

/**
 * Désigne LA saison courante. Invariant : au plus une saison `isCurrent`. On
 * démarque toutes les autres puis marque celle-ci, dans une seule transaction
 * (pas d'état intermédiaire à deux saisons courantes) — invariant renforcé en
 * base par un index unique partiel (voir schema.prisma, modèle `Season`).
 *
 * On refuse aussi de revenir sur une saison antérieure à la saison courante
 * (comparaison sur `launchDate`) : une fois avancé, le calendrier ne recule
 * pas — un retour en arrière ferait immédiatement disparaître de
 * l'affichage tous les kits/objectifs/paiements de la saison plus récente
 * (voir bug du 2026-08-06, où deux saisons `isCurrent` avaient déjà produit
 * ce symptôme).
 */
export async function setCurrentSeason(actorId: string, id: string) {
  const target = await getSeasonOrThrow(id);
  const active = await prisma.season.findFirst({ where: { isCurrent: true } });
  if (active && active.id !== id && target.launchDate < active.launchDate) {
    throw ApiError.badRequest('Impossible de revenir sur une saison antérieure à la saison courante.', [
      { field: 'id', issue: `Saison courante actuelle : "${active.label}".` },
    ]);
  }

  const updated = await prisma.$transaction(async (tx) => {
    await tx.season.updateMany({
      where: { isCurrent: true, id: { not: id } },
      data: { isCurrent: false },
    });
    const u = await tx.season.update({ where: { id }, data: { isCurrent: true } });
    await writeAudit(tx, {
      actorId,
      action: 'season.set_current',
      entity: 'season',
      entityId: id,
      after: { label: u.label, is_current: true },
    });
    return u;
  });
  return toSeasonDto(updated);
}
