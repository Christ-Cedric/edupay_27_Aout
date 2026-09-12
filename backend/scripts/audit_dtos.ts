import { PrismaClient } from '@prisma/client';
import { getFamily } from '../src/modules/admin/admin.service.js';
import { listContributions } from '../src/modules/payments/payments.service.js';

const prisma = new PrismaClient();

async function main() {
  console.log('=== TEST GETFAMILY & LISTCONTRIBUTIONS ===\n');

  // Test for Romaric Rouamba
  const romaric = await prisma.user.findFirst({ where: { phone: '+22658841236' } });
  if (romaric) {
    console.log(`\n--- Test pour Romaric Rouamba (${romaric.id}) ---`);
    const familyDto = await getFamily(romaric.id);
    console.log('Family DTO (GET /parents/me/family):');
    console.log(JSON.stringify(familyDto, null, 2));

    const contributionsDto = await listContributions(romaric.id);
    console.log('\nContributions DTO (GET /parents/me/contributions):');
    console.log(JSON.stringify(contributionsDto, null, 2));
  }

  // Test for David Gambrié
  const david = await prisma.user.findFirst({ where: { phone: '+22658085421' } });
  if (david) {
    console.log(`\n--- Test pour David Gambrié (${david.id}) ---`);
    const familyDto = await getFamily(david.id);
    console.log('Family DTO (GET /parents/me/family):');
    console.log(JSON.stringify(familyDto, null, 2));
  }

  // Test for Ouedraogo celine
  const celine = await prisma.user.findFirst({ where: { phone: '+22672006904' } });
  if (celine) {
    console.log(`\n--- Test pour Ouedraogo celine (${celine.id}) ---`);
    const familyDto = await getFamily(celine.id);
    console.log('Family DTO (GET /parents/me/family):');
    console.log(JSON.stringify(familyDto, null, 2));

    const contributionsDto = await listContributions(celine.id);
    console.log('\nContributions DTO (GET /parents/me/contributions):');
    console.log(JSON.stringify(contributionsDto, null, 2));
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
