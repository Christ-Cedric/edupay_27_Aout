import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const goals = await prisma.savingsGoal.findMany();
  console.log(`Total goals: ${goals.length}`);
  for (const g of goals) {
    console.log(`Goal ${g.id}: parent=${g.parentId}, child=${g.childId}, target=${g.targetAmount}, saved=${g.savedAmount}, status=${g.status}`);
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
