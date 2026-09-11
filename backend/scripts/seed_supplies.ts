import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const CATALOG_DATA = [
  { category: "Cahiers & Protège-cahiers", label: "Cahier de 100 pages", unitPrice: 350, unit: "Unité" },
  { category: "Cahiers & Protège-cahiers", label: "Cahier de 200 pages", unitPrice: 650, unit: "Unité" },
  { category: "Cahiers & Protège-cahiers", label: "Cahier de 300 pages", unitPrice: 950, unit: "Unité" },
  { category: "Cahiers & Protège-cahiers", label: "Cahier de TP", unitPrice: 500, unit: "Unité" },
  { category: "Cahiers & Protège-cahiers", label: "Protège cahier (Grand format)", unitPrice: 150, unit: "Unité" },
  { category: "Cahiers & Protège-cahiers", label: "Protège cahier (Petit format)", unitPrice: 100, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Stylo à bille Bleu", unitPrice: 100, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Stylo à bille Rouge", unitPrice: 100, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Stylo à bille Vert", unitPrice: 100, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Crayon à papier (HB)", unitPrice: 50, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Gomme blanche", unitPrice: 100, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Ensemble géométrique (Règle, équerre, compas)", unitPrice: 500, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Ardoise à craie", unitPrice: 300, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Boîte de craie blanche", unitPrice: 500, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Boîte de craie couleur", unitPrice: 500, unit: "Unité" },
  { category: "Matériel de traçage & d'écriture", label: "Boîte de crayons de couleur (12)", unitPrice: 600, unit: "Unité" },
  { category: "Sacs & Divers", label: "Sac au dos scolaire", unitPrice: 3500, unit: "Unité" },
  { category: "Sacs & Divers", label: "Gourde isotherme", unitPrice: 1500, unit: "Unité" },
  { category: "Sacs & Divers", label: "Tenue Kaki (Tissu au mètre)", unitPrice: 2000, unit: "Mètre" }
];

async function main() {
  await prisma.supply.deleteMany({});
  for (const item of CATALOG_DATA) {
    await prisma.supply.create({ data: item });
  }
  console.log('Supplies seeded successfully.');
}

main().catch(console.error).finally(() => prisma.$disconnect());
