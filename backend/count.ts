import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const families = await prisma.user.findMany({ where: { role: 'client' }, include: { children: true } });
  for (const f of families) {
     console.log(`${f.fullName}: ${f.children.length} children`);
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
