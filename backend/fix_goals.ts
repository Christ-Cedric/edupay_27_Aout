import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const families = await prisma.user.findMany({ where: { role: 'client' } });
  
  const season = await prisma.season.findFirst({ where: { isCurrent: true } });
  if (!season) {
     console.log("No active season found");
     return;
  }
  
  let count = 0;
  for (const f of families) {
    const goals = await prisma.savingsGoal.findMany({ where: { parentId: f.id } });
    if (goals.length === 0) {
      await prisma.savingsGoal.create({
        data: {
          parentId: f.id,
          seasonId: season.id,
          targetAmount: 25000,
          status: 'active',
          savedAmount: 0,
          name: 'Objectif par défaut (Script)',
          type: 'supplies'
        }
      });
      console.log(`Created default goal for family ${f.fullName}`);
      count++;
    }
  }
  console.log(`Fixed ${count} families by adding a default savings goal.`);
}
main().catch(console.error).finally(() => prisma.$disconnect());
