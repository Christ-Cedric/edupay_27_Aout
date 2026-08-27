import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const families = await prisma.user.findMany({ where: { role: 'client' } });
  let noGoalFamilies = [];
  for (const f of families) {
    const goals = await prisma.savingsGoal.findMany({ where: { parentId: f.id, status: 'active' } });
    if (goals.length === 0) {
      noGoalFamilies.push(f.fullName);
    } else {
      console.log(`${f.fullName} HAS ${goals.length} active goals. Capacities: ${goals.map(g => g.targetAmount - g.savedAmount)}`);
    }
  }
  console.log(`Families without active goals: ${noGoalFamilies.join(', ')}`);
}
main().catch(console.error).finally(() => prisma.$disconnect());
