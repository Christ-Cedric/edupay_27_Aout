import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';
import type { KitTier, Prisma } from '@prisma/client';
import { prisma } from '../src/shared/prisma.js';
import { writeAudit } from '../src/shared/audit/audit.js';
import { currentSeasonId } from '../src/modules/kits/kits.service.js';

/**
 * Charge le vrai catalogue (28 classes × 3 variants) depuis
 * `edupay/assets/data/school_catalogue.json` — remplace les 3 kits
 * génériques placeholder du seed par le catalogue réel, pour que l'app agent
 * (déjà branchée sur `/catalog/kits`) et l'app client (à venir) affichent le
 * même prix/contenu pour un même enfant. Fichier source non dupliqué en
 * base : ce script est ré-exécutable (upsert par classe+tier) chaque fois
 * que le catalogue Excel officiel est régénéré.
 *
 * Usage : npx tsx scripts/import-catalogue-from-json.ts
 */

const __dirname = dirname(fileURLToPath(import.meta.url));
const CATALOGUE_PATH = resolve(__dirname, '../../edupay/assets/data/school_catalogue.json');

// Clés du JSON = noms exacts de l'enum Prisma `KitTier` (coïncidence voulue
// par le générateur `edupay/tools/generate_catalogue.py`, pas un mapping à
// maintenir ici).
const LEVEL_NAME: Record<KitTier, string> = {
  basic: 'Kit Basique',
  comfort: 'Kit Essentiel',
  complete: 'Kit Premium',
};

interface CatalogueItem {
  category: string;
  label: string;
  quantity: number;
  unitPrice: number;
}

interface CatalogueJson {
  levels: Record<
    string,
    {
      kits: Partial<Record<KitTier, { items: CatalogueItem[] }>>;
    }
  >;
}

async function main() {
  const raw = readFileSync(CATALOGUE_PATH, 'utf-8');
  const catalogue = JSON.parse(raw) as CatalogueJson;

  let created = 0;
  let updated = 0;

  const seasonId = await currentSeasonId();

  for (const [levelScope, level] of Object.entries(catalogue.levels)) {
    for (const [tier, kit] of Object.entries(level.kits) as [KitTier, { items: CatalogueItem[] }][]) {
      if (!kit || kit.items.length === 0) continue;

      const totalPrice = kit.items.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0);
      const itemsData: Prisma.KitItemCreateManyKitInput[] = kit.items.map((item) => ({
        category: item.category,
        label: item.label,
        quantity: item.quantity,
        unit: 'unité',
        unitPrice: item.unitPrice,
      }));

      const existing = await prisma.kit.findFirst({
        where: { seasonId, levelScope, tier },
        select: { id: true },
      });

      if (existing) {
        await prisma.kitItem.deleteMany({ where: { kitId: existing.id } });
        await prisma.kit.update({
          where: { id: existing.id },
          data: { totalPrice, items: { createMany: { data: itemsData } } },
        });
        updated += 1;
      } else {
        await prisma.kit.create({
          data: {
            seasonId,
            tier,
            name: LEVEL_NAME[tier],
            levelScope,
            totalPrice,
            items: { createMany: { data: itemsData } },
          },
        });
        created += 1;
      }
    }
  }

  await writeAudit(prisma, {
    actorId: 'system',
    action: 'kit.catalog_imported',
    entity: 'kit',
    after: { source: 'school_catalogue.json', created, updated },
  });

  // eslint-disable-next-line no-console
  console.log(`✔ Catalogue importé : ${created} kit(s) créé(s), ${updated} mis à jour.`);
}

main()
  .catch((err) => {
    // eslint-disable-next-line no-console
    console.error('Échec de l’import du catalogue :', err);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
