import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const families = await prisma.user.findMany({ where: { role: 'client' } });
  for (const f of families) {
    const goals = await prisma.savingsGoal.findMany({ where: { parentId: f.id } });
    console.log(`Family ${f.id} (${f.fullName}): ${goals.length} goals`);
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
