import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const families = await prisma.user.findMany({ where: { role: 'client' } });
  for (const f of families) {
    if (f.reference?.includes('BAN-2026')) {
       console.log(`Found: ${f.id} - ${f.fullName} - ${f.reference}`);
    }
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
