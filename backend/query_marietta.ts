import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const marietta = await prisma.user.findFirst({ where: { fullName: 'Marietta Ouattara' }, include: { children: true } });
  if (marietta) {
    console.log(`Marietta has ${marietta.children.length} children.`);
    if (marietta.children.length > 0) {
       console.log(marietta.children);
    }
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
