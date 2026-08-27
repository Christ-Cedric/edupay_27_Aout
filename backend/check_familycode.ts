import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const families = await prisma.user.findMany({ where: { role: 'client' } });
  for (const f of families) {
    console.log(`${f.fullName}: familyCode="${f.familyCode}", assignedAgentId="${f.assignedAgentId}"`);
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
