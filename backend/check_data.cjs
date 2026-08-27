const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  // Only check contributions
  try {
    const count = await prisma.contribution.count();
    console.log('Nombre total de contributions:', count);
    
    if (count > 0) {
      const contributions = await prisma.contribution.findMany({
        orderBy: { createdAt: 'desc' },
        take: 10,
      });
      console.log('\n=== CONTRIBUTIONS (10 dernières) ===');
      for (const c of contributions) {
        console.log(`  ID: ${c.id}`);
        console.log(`    Amount: ${c.amount} FCFA`);
        console.log(`    Method: ${c.method}`);
        console.log(`    Status: ${c.status}`);
        console.log(`    Reference: ${c.reference}`);
        console.log(`    ParentId: ${c.parentId}`);
        console.log(`    Created: ${c.createdAt}`);
        console.log(`    Confirmed: ${c.confirmedAt}`);
        console.log('    ---');
      }
    } else {
      console.log('\n*** AUCUNE CONTRIBUTION EN BASE DE DONNÉES ***');
      console.log('Les paiements du frontend ne sont PAS enregistrés côté serveur!');
    }
    
    // Check savings goals
    const goals = await prisma.savingsGoal.findMany({
      where: { status: 'active' },
      select: { id: true, name: true, targetAmount: true, savedAmount: true, parentId: true, childId: true, status: true }
    });
    console.log('\n=== OBJECTIFS D\'EPARGNE ACTIFS ===');
    for (const g of goals) {
      console.log(`  ${g.name}: ${g.savedAmount}/${g.targetAmount} FCFA (parent: ${g.parentId}, child: ${g.childId})`);
    }
    
  } catch (e) {
    console.log('ERREUR:', e.message);
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
