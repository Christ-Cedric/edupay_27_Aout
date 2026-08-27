import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    where: { role: 'client' },
    include: {
      children: true,
      savingsGoals: true,
      contributions: { include: { allocations: true } },
    },
  });

  for (const u of users) {
    console.log(`\nClient: ${u.fullName} (${u.phone}, ID: ${u.id})`);
    console.log(`Enfants (${u.children.length}):`, u.children.map(c => ({ id: c.id, name: c.firstName, class: c.level })));
    console.log(`Objectifs (${u.savingsGoals.length}):`, u.savingsGoals.map(g => ({ id: g.id, childId: g.childId, target: g.targetAmount, saved: g.savedAmount, status: g.status })));
    console.log(`Cotisations (${u.contributions.length}):`, u.contributions.map(c => ({ id: c.id, amount: c.amount, status: c.status, allocs: c.allocations })));
  }
}

main().finally(() => prisma.$disconnect());
