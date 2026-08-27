import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const season = await prisma.season.findFirst({ where: { isCurrent: true } });
  if (!season) { console.log("No current season"); return; }
  console.log(`Season: ${season.id} - ${season.label}`);
  const kits = await prisma.kit.findMany({ where: { seasonId: season.id } });
  for (const k of kits) {
    console.log(`Kit: id=${k.id} name="${k.name}" price=${k.price} totalPrice=${k.totalPrice}`);
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
