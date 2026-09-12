import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('=== AUDIT BASE DE DONNEES EDUPAY ===\n');

  // 1. Users count by role
  const users = await prisma.user.findMany({
    select: {
      id: true,
      role: true,
      fullName: true,
      phone: true,
      status: true,
      city: true,
      district: true,
      familyCode: true,
      assignedAgentId: true,
      createdAt: true,
      _count: {
        select: {
          children: true,
          savingsGoals: true,
          contributions: true,
          sessions: true,
          refreshTokens: true,
        },
      },
    },
  });

  console.log(`Total utilisateurs: ${users.length}`);
  console.log('Détail des utilisateurs :');
  for (const u of users) {
    console.log(`- [${u.role}] ID: ${u.id} | Nom: ${u.fullName} | Phone: ${u.phone} | Statut: ${u.status} | Code Famille: ${u.familyCode} | Agent assigné: ${u.assignedAgentId}`);
    console.log(`  Enfants: ${u._count.children}, Objectifs: ${u._count.savingsGoals}, Cotisations: ${u._count.contributions}, Sessions: ${u._count.sessions}`);
  }

  // 2. Details of clients
  const clients = await prisma.user.findMany({
    where: { role: 'client' },
    include: {
      assignedAgent: { select: { id: true, fullName: true, phone: true } },
      subscription: true,
      children: {
        include: {
          savingsGoals: true,
        },
      },
      savingsGoals: true,
      contributions: {
        include: {
          allocations: true,
        },
      },
    },
  });

  console.log('\n=== DETAIL DES CLIENTS (ROLE CLIENT) ===');
  for (const c of clients) {
    console.log(`\nClient: ${c.fullName} (${c.phone}) - ID: ${c.id}`);
    console.log(`  Statut: ${c.status}, Code Famille: ${c.familyCode}`);
    console.log(`  Souscription:`, c.subscription ? `Fréquence: ${c.subscription.frequency}, Statut: ${c.subscription.status}` : 'AUCUNE');
    console.log(`  Agent assigné:`, c.assignedAgent ? `${c.assignedAgent.fullName} (${c.assignedAgent.phone})` : 'AUCUN');
    console.log(`  Nombre d\'enfants: ${c.children.length}`);
    for (const ch of c.children) {
      console.log(`    * Enfant: ${ch.firstName} (Classe: ${ch.level}, Ecole: ${ch.school}) - ID: ${ch.id}`);
      for (const g of ch.savingsGoals) {
        console.log(`      - Goal: type=${g.type}, nom=${g.name}, target=${g.targetAmount}, saved=${g.savedAmount}, status=${g.status}, seasonId=${g.seasonId}`);
      }
    }
    console.log(`  Objectifs globaux/sans enfant: ${c.savingsGoals.filter(g => !g.childId).length}`);
    for (const g of c.savingsGoals.filter(g => !g.childId)) {
      console.log(`    - Goal hors enfant: type=${g.type}, target=${g.targetAmount}, saved=${g.savedAmount}`);
    }
    console.log(`  Nombre de cotisations: ${c.contributions.length}`);
    for (const ct of c.contributions) {
      console.log(`    * Cotisation: montant=${ct.amount}, méthode=${ct.method}, statut=${ct.status}, ref=${ct.reference}, créé le=${ct.createdAt}`);
      console.log(`      Allocations:`, ct.allocations.map(a => `amount=${a.amount} goalId=${a.savingsGoalId}`).join(', '));
    }
  }

  // 3. Seasons check
  const seasons = await prisma.season.findMany();
  console.log('\n=== SAISONS ===');
  for (const s of seasons) {
    console.log(`- Saison ${s.label}: isCurrent=${s.isCurrent}, ID=${s.id}`);
  }

  // 4. OtpCodes
  const otps = await prisma.otpCode.findMany({
    orderBy: { createdAt: 'desc' },
    take: 10,
  });
  console.log('\n=== DERNIERS CODES OTP ===');
  for (const o of otps) {
    console.log(`- OTP pour ${o.phone}: purpose=${o.purpose}, attempts=${o.attempts}, consumedAt=${o.consumedAt}, expiresAt=${o.expiresAt}`);
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
