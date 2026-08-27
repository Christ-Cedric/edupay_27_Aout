import type { Prisma } from '@prisma/client';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { levelToTier, toKitDto } from './kits.serializer.js';
import type { CreateKitInput, KitItemInput, UpdateKitInput } from './kits.schemas.js';

const kitInclude = { items: true } satisfies Prisma.KitInclude;

/** Libellé FR par niveau (le schéma exige un `name`, non exposé à l'app). */
const LEVEL_NAME: Record<'basic' | 'intermediate' | 'premium', string> = {
  basic: 'Kit Basique',
  intermediate: 'Kit Intermédiaire',
  premium: 'Kit Premium',
};

function itemsToCreate(items: KitItemInput[]): Prisma.KitItemCreateManyKitInput[] {
  return items.map((item) => ({
    category: item.category,
    label: item.label,
    quantity: item.quantity,
    unit: item.unit,
    unitPrice: item.unit_price,
  }));
}

/** `Kit.totalPrice` n'est jamais saisi : toujours Σ(quantity × unit_price). */
function computeTotalPrice(items: KitItemInput[]): number {
  return items.reduce((sum, item) => sum + item.quantity * item.unit_price, 0);
}

export async function currentSeasonId(): Promise<string> {
  const season = await prisma.season.findFirst({ where: { isCurrent: true } });
  if (!season) {
    throw ApiError.badRequest('Aucune saison courante : définissez-en une avant de gérer les kits.');
  }
  return season.id;
}

async function getKitOrThrow(id: string) {
  const kit = await prisma.kit.findUnique({ where: { id }, include: kitInclude });
  if (!kit) throw ApiError.notFound('Kit introuvable.');
  return kit;
}

/** Catalogue de la saison courante (les 3 variants). `levelScope` filtre sur
 * la classe ciblée (ex. "CM2") — omis, renvoie tout le catalogue de la
 * saison (usage admin) ; fourni, ne renvoie que les kits de cette classe
 * (usage agent/client, qui n'ont besoin que du kit de l'enfant concerné). */
export async function listKits(levelScope?: string) {
  const seasonId = await prisma.season
    .findFirst({ where: { isCurrent: true }, select: { id: true } })
    .then((s) => s?.id);
  const kits = await prisma.kit.findMany({
    where: { ...(seasonId ? { seasonId } : {}), ...(levelScope ? { levelScope } : {}) },
    include: kitInclude,
    orderBy: { tier: 'asc' },
  });
  return kits.map(toKitDto);
}

export async function getKit(id: string) {
  return toKitDto(await getKitOrThrow(id));
}

export async function createKit(actorId: string, input: CreateKitInput) {
  const seasonId = await currentSeasonId();
  const totalPrice = computeTotalPrice(input.items);
  const kit = await prisma.$transaction(async (tx) => {
    const created = await tx.kit.create({
      data: {
        seasonId,
        tier: levelToTier(input.level),
        name: LEVEL_NAME[input.level],
        levelScope: input.level_scope,
        totalPrice,
        items: { createMany: { data: itemsToCreate(input.items) } },
      },
      include: kitInclude,
    });
    await writeAudit(tx, {
      actorId,
      action: 'kit.created',
      entity: 'kit',
      entityId: created.id,
      after: { level: input.level, levelScope: input.level_scope, price: totalPrice },
    });
    return created;
  });
  return toKitDto(kit);
}

/** Remplace le kit (PUT). `price` est toujours dérivé des fournitures. */
export async function updateKit(actorId: string, id: string, input: UpdateKitInput) {
  const existing = await getKitOrThrow(id);
  const replacingItems = input.items !== undefined;
  const totalPrice = replacingItems ? computeTotalPrice(input.items!) : undefined;

  const kit = await prisma.$transaction(async (tx) => {
    if (replacingItems) {
      await tx.kitItem.deleteMany({ where: { kitId: id } });
    }
    const u = await tx.kit.update({
      where: { id },
      data: {
        ...(input.level
          ? { tier: levelToTier(input.level), name: LEVEL_NAME[input.level] }
          : {}),
        ...(input.level_scope !== undefined ? { levelScope: input.level_scope } : {}),
        ...(totalPrice !== undefined ? { totalPrice } : {}),
        ...(replacingItems
          ? { items: { createMany: { data: itemsToCreate(input.items!) } } }
          : {}),
      },
      include: kitInclude,
    });
    await writeAudit(tx, {
      actorId,
      action: 'kit.updated',
      entity: 'kit',
      entityId: id,
      before: { price: existing.totalPrice, items_count: existing.items.length },
      after: { price: u.totalPrice, items_count: u.items.length },
    });
    return u;
  });
  return toKitDto(kit);
}

export async function deleteKit(actorId: string, id: string) {
  const existing = await getKitOrThrow(id);

  // Le client (écran Admin) fait déjà ce contrôle avant d'appeler l'API, mais
  // on le revalide côté serveur pour ne pas laisser une contrainte FK brute
  // remonter en 500 en cas de course (famille assignée entre les deux appels).
  const assignedCount = await prisma.savingsGoal.count({ where: { kitId: id } });
  if (assignedCount > 0) {
    throw ApiError.conflict(
      `Ce kit est assigné à ${assignedCount} enfant(s) — impossible de le supprimer.`,
    );
  }

  await prisma.$transaction(async (tx) => {
    await tx.kit.delete({ where: { id } });
    await writeAudit(tx, {
      actorId,
      action: 'kit.deleted',
      entity: 'kit',
      entityId: id,
      before: { level: existing.levelScope, price: existing.totalPrice },
    });
  });
}
