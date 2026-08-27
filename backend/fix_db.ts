import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const children = await prisma.child.findMany({ include: { savingsGoals: true } });
  let count = 0;
  for (const child of children) {
    if (child.savingsGoals.length === 0) {
      // Find a kit
      const kit = await prisma.kit.findFirst();
      if (!kit) continue;
      
      const season = await prisma.season.findFirst({ where: { status: 'active' } });
      if (!season) continue;

      await prisma.savingsGoal.create({
        data: {
          parentId: child.parentId,
          childId: child.id,
          seasonId: season.id,
          targetAmount: kit.price,
          status: 'active',
          savedAmount: 0
        }
      });
      count++;
    }
  }
  console.log(`Fixed ${count} children by adding a savings goal.`);
}
main().catch(console.error).finally(() => prisma.$disconnect());
