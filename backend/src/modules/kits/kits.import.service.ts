import ExcelJS from 'exceljs';
import type { Prisma } from '@prisma/client';
import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { currentSeasonId } from './kits.service.js';

/**
 * Les 28 classes/séries réelles du catalogue fournisseur — mêmes libellés
 * que `SchoolLevel` côté Flutter (school_level.dart). Dupliqué ici (pas de
 * types partagés entre les deux stacks) uniquement pour signaler en
 * avertissement toute valeur de colonne "Niveau" qui ne correspondrait à
 * aucune classe connue, plutôt que de l'importer silencieusement.
 */
const KNOWN_SCHOOL_LEVELS = new Set([
  'Petite Section',
  'Moyenne Section',
  'Grande Section',
  'CP1',
  'CP2',
  'CE1',
  'CE2',
  'CM1',
  'CM2',
  '6ème',
  '5ème',
  '4ème',
  '3ème',
  '2nde A',
  '2nde C/D',
  '1ère A',
  '1ère C',
  '1ère D',
  'Terminale A1',
  'Terminale A2',
  'Terminale C',
  'Terminale D',
  '2nde G2',
  '2nde F',
  '1ère G2',
  '1ère F',
  'Terminale G2',
  'Terminale F',
]);

const SHEET_NAME = 'Catalogue Complet (à plat)';

type Variant = 'basic' | 'intermediate' | 'premium';

const VARIANT_COLUMNS: Record<Variant, string> = {
  basic: 'Kit Basique (Oui/Non)',
  intermediate: 'Kit Essentiel (Oui/Non)',
  premium: 'Kit Premium (Oui/Non)',
};

const LEVEL_NAME: Record<Variant, string> = {
  basic: 'Kit Basique',
  intermediate: 'Kit Essentiel',
  premium: 'Kit Premium',
};

const TIER_BY_VARIANT: Record<Variant, 'basic' | 'comfort' | 'complete'> = {
  basic: 'basic',
  intermediate: 'comfort',
  premium: 'complete',
};

interface ParsedItem {
  category: string;
  label: string;
  quantity: number;
  unit: string;
  unitPrice: number;
}

export interface ImportSummary {
  created: number;
  updated: number;
  warnings: string[];
}

function cellText(row: ExcelJS.Row, index: number): string {
  const value = row.getCell(index).value;
  if (value === null || value === undefined) return '';
  if (typeof value === 'object' && 'text' in value) return String((value as { text: unknown }).text);
  return String(value).trim();
}

function cellNumber(row: ExcelJS.Row, index: number): number {
  const value = row.getCell(index).value;
  const n = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(n) ? n : 0;
}

/**
 * Parse le seul onglet "à plat" du fichier (les onglets par cycle ont des
 * en-têtes fusionnés et des lignes de sous-total, pas faits pour être lus
 * par une machine). Colonnes fixes (contrat du fichier fournisseur) :
 * Cycle | Niveau | Type d'enseignement | Série/Filière | Catégorie d'article
 * | Article | Quantité | Unité | Kit Basique (Oui/Non) | Kit Essentiel
 * (Oui/Non) | Kit Premium (Oui/Non) | Prix unitaire estimé (FCFA) | ... | Note.
 */
export async function importKitsCatalog(
  actorId: string,
  fileBase64: string,
): Promise<ImportSummary> {
  const buffer = Buffer.from(fileBase64, 'base64');
  const workbook = new ExcelJS.Workbook();
  try {
    // exceljs embarque ses propres types `Buffer`, désynchronisés de la
    // version de @types/node du projet — cast sans risque (mêmes octets).
    await workbook.xlsx.load(buffer as never);
  } catch {
    throw ApiError.badRequest('Fichier Excel invalide ou corrompu.');
  }

  const sheet = workbook.getWorksheet(SHEET_NAME);
  if (!sheet) {
    throw ApiError.badRequest(
      `Onglet "${SHEET_NAME}" introuvable dans le fichier.`,
    );
  }

  const header = sheet.getRow(1);
  const columnIndex = new Map<string, number>();
  header.eachCell((cell, colNumber) => {
    columnIndex.set(String(cell.value).trim(), colNumber);
  });

  const required = [
    'Niveau',
    "Catégorie d'article",
    'Article',
    'Quantité',
    'Unité',
    'Prix unitaire estimé (FCFA)',
    VARIANT_COLUMNS.basic,
    VARIANT_COLUMNS.intermediate,
    VARIANT_COLUMNS.premium,
  ];
  const missing = required.filter((col) => !columnIndex.has(col));
  if (missing.length > 0) {
    throw ApiError.badRequest(
      `Colonnes manquantes dans le fichier : ${missing.join(', ')}.`,
    );
  }

  const noteCol = columnIndex.get('Note');
  const niveauCol = columnIndex.get('Niveau')!;
  const categoryCol = columnIndex.get("Catégorie d'article")!;
  const labelCol = columnIndex.get('Article')!;
  const quantityCol = columnIndex.get('Quantité')!;
  const unitCol = columnIndex.get('Unité')!;
  const priceCol = columnIndex.get('Prix unitaire estimé (FCFA)')!;

  // groupes[niveau][variant] = fournitures de ce kit.
  const groups = new Map<string, Record<Variant, ParsedItem[]>>();
  const unknownLevels = new Set<string>();
  // Fournitures uniques (par libellé) rencontrées dans le fichier — sert à
  // peupler le catalogue de fournitures réutilisable (`Supply`) en plus des
  // kits eux-mêmes, le fichier étant la source la plus naturelle pour ça.
  const uniqueSupplies = new Map<string, ParsedItem>();

  sheet.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;
    const niveau = cellText(row, niveauCol);
    const label = cellText(row, labelCol);
    if (!niveau || !label) return; // ligne vide (fin de feuille).

    if (!KNOWN_SCHOOL_LEVELS.has(niveau)) {
      unknownLevels.add(niveau);
      return; // pas de classe reconnue : jamais importé, toujours signalé.
    }

    const note = noteCol ? cellText(row, noteCol) : '';
    const item: ParsedItem = {
      category: cellText(row, categoryCol) || 'Autre',
      label: note ? `${label} (à valider)` : label,
      quantity: Math.max(1, Math.round(cellNumber(row, quantityCol)) || 1),
      unit: cellText(row, unitCol) || 'unité',
      unitPrice: Math.max(0, Math.round(cellNumber(row, priceCol))),
    };
    uniqueSupplies.set(item.label, item);

    if (!groups.has(niveau)) {
      groups.set(niveau, { basic: [], intermediate: [], premium: [] });
    }
    const group = groups.get(niveau)!;
    for (const variant of Object.keys(VARIANT_COLUMNS) as Variant[]) {
      const included = cellText(row, columnIndex.get(VARIANT_COLUMNS[variant])!);
      if (included.toLowerCase() === 'oui') {
        group[variant].push(item);
      }
    }
  });

  const warnings = [...unknownLevels].map(
    (level) => `Classe non reconnue ignorée : "${level}".`,
  );

  let created = 0;
  let updated = 0;

  await prisma.$transaction(async (tx) => {
    const seasonId = await currentSeasonId();

    for (const [levelScope, byVariant] of groups) {
      for (const variant of Object.keys(VARIANT_COLUMNS) as Variant[]) {
        const items = byVariant[variant];
        if (items.length === 0) continue;

        const totalPrice = items.reduce(
          (sum, item) => sum + item.quantity * item.unitPrice,
          0,
        );
        const itemsData: Prisma.KitItemCreateManyKitInput[] = items.map((item) => ({
          category: item.category,
          label: item.label,
          quantity: item.quantity,
          unit: item.unit,
          unitPrice: item.unitPrice,
        }));

        const existing = await tx.kit.findFirst({
          where: { seasonId, levelScope, tier: TIER_BY_VARIANT[variant] },
          select: { id: true },
        });

        if (existing) {
          await tx.kitItem.deleteMany({ where: { kitId: existing.id } });
          await tx.kit.update({
            where: { id: existing.id },
            data: {
              totalPrice,
              items: { createMany: { data: itemsData } },
            },
          });
          updated += 1;
        } else {
          await tx.kit.create({
            data: {
              seasonId,
              tier: TIER_BY_VARIANT[variant],
              name: LEVEL_NAME[variant],
              levelScope,
              totalPrice,
              items: { createMany: { data: itemsData } },
            },
          });
          created += 1;
        }
      }
    }

    for (const supply of uniqueSupplies.values()) {
      const existing = await tx.supply.findFirst({ where: { label: supply.label } });
      if (existing) {
        await tx.supply.update({
          where: { id: existing.id },
          data: { category: supply.category, unit: supply.unit, unitPrice: supply.unitPrice },
        });
      } else {
        await tx.supply.create({
          data: {
            category: supply.category,
            label: supply.label,
            unit: supply.unit,
            unitPrice: supply.unitPrice,
          },
        });
      }
    }

    await writeAudit(tx, {
      actorId,
      action: 'kit.catalog_imported',
      entity: 'kit',
      after: { created, updated, warnings_count: warnings.length, supplies_seen: uniqueSupplies.size },
    });
  });

  return { created, updated, warnings };
}
