import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  // Vérifier que tout est bon maintenant
  const families = await prisma.user.findMany({ where: { role: 'client' } });
  let ok = 0, noCode = 0, noGoal = 0;
  for (const f of families) {
    const goals = await prisma.savingsGoal.findMany({ where: { parentId: f.id, status: 'active' } });
    const hasCode = f.familyCode !== null && f.familyCode !== '';
    const hasGoal = goals.length > 0;
    if (!hasCode) noCode++;
    if (!hasGoal) noGoal++;
    if (hasCode && hasGoal) ok++;
    console.log(`${hasCode ? '✓' : '✗'} Code | ${hasGoal ? '✓' : '✗'} Objectif | ${f.fullName} (${f.familyCode}) -> cap: ${goals.map(g => g.targetAmount - g.savedAmount).join(', ') || 'AUCUN'}`);
  }
  console.log(`\n==> ${ok}/${families.length} familles PRÊTES au scan. Problèmes: ${noCode} sans code, ${noGoal} sans objectif.`);
}
main().catch(console.error).finally(() => prisma.$disconnect());
