import { randomBytes } from 'node:crypto';
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

function generateFamilyCode(city: string | null): string {
  const prefix = (city ?? 'GEN').replace(/[^a-zA-Z]/g, '').slice(0, 3).toUpperCase() || 'GEN';
  const year = new Date().getFullYear();
  const suffix = randomBytes(2).toString('hex').toUpperCase();
  return `${prefix}-${year}-${suffix}`;
}

async function main() {
  // ── 1. Corriger familyCode null ──────────────────────────────────────────
  const noCodeFamilies = await prisma.user.findMany({
    where: { role: 'client', familyCode: null },
  });
  console.log(`Familles sans code: ${noCodeFamilies.length}`);
  for (const f of noCodeFamilies) {
    const code = generateFamilyCode(f.city);
    await prisma.user.update({ where: { id: f.id }, data: { familyCode: code } });
    console.log(`  -> ${f.fullName} : code généré => ${code}`);
  }

  // ── 2. Corriger familles sans objectif d'épargne actif ───────────────────
  const season = await prisma.season.findFirst({ where: { isCurrent: true } });
  if (!season) { console.log('Aucune saison courante trouvée.'); return; }

  const allFamilies = await prisma.user.findMany({ where: { role: 'client' } });
  let fixedGoals = 0;
  for (const f of allFamilies) {
    const goals = await prisma.savingsGoal.findMany({ where: { parentId: f.id, status: 'active' } });
    if (goals.length === 0) {
      await prisma.savingsGoal.create({
        data: {
          parentId: f.id,
          seasonId: season.id,
          targetAmount: 25000,
          savedAmount: 0,
          name: 'Objectif principal',
          type: 'supplies',
          status: 'active',
        },
      });
      console.log(`  -> Objectif créé pour: ${f.fullName}`);
      fixedGoals++;
    }
  }
  console.log(`\nTerminé. ${noCodeFamilies.length} codes générés, ${fixedGoals} objectifs créés.`);
}

main().catch(console.error).finally(() => prisma.$disconnect());
