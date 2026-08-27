import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const children = await prisma.child.findMany({ where: { kitId: { not: null } } });
  console.log(`Found ${children.length} children with kitId`);
  const goals = await prisma.savingsGoal.findMany({ where: { status: 'active' } });
  console.log(`Found ${goals.length} active goals`);
}
main().catch(console.error).finally(() => prisma.$disconnect());
