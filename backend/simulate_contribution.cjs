// Test direct de la création de cotisation via le service (bypasse l'auth)
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  // Trouver le parent "cmt4ifmgs0019tm9kksx6rocl" (celui qui teste l'app)
  const parentId = 'cmt4ifmgs0019tm9kksx6rocl';
  
  const parent = await prisma.user.findFirst({ where: { id: parentId, role: 'client' } });
  console.log('=== Parent trouvé ===');
  console.log('  ID:', parent?.id);
  console.log('  Nom:', parent?.fullName);
  console.log('  Phone:', parent?.phone);
  console.log('  Status:', parent?.status);
  
  // Vérifier ses objectifs d'épargne actifs
  const goals = await prisma.savingsGoal.findMany({
    where: { parentId, status: 'active' },
    include: { child: { select: { firstName: true } } }
  });
  console.log('\n=== Objectifs d\'épargne actifs ===');
  let totalCapacity = 0;
  for (const g of goals) {
    const remaining = g.targetAmount - g.savedAmount;
    totalCapacity += remaining;
    console.log(`  ${g.name} (enfant: ${g.child?.firstName || 'N/A'}): ${g.savedAmount}/${g.targetAmount} FCFA, reste: ${remaining} FCFA`);
  }
  console.log(`  Capacité totale de financement: ${totalCapacity} FCFA`);
  
  // Vérifier les enfants
  const children = await prisma.child.findMany({ where: { parentId } });
  console.log('\n=== Enfants ===');
  for (const c of children) {
    console.log(`  ${c.firstName} (${c.level}), ID: ${c.id}`);
  }

  // Vérifier ses contributions existantes
  const contribs = await prisma.contribution.findMany({ where: { parentId } });
  console.log('\n=== Contributions existantes ===');
  console.log(`  Nombre: ${contribs.length}`);
  for (const c of contribs) {
    console.log(`  ${c.reference}: ${c.amount} FCFA (${c.method}, ${c.status})`);
  }

  // === SIMULATION DE CE QUI SE PASSE QUAND L'APP MOBILE ENVOIE UNE COTISATION ===
  console.log('\n=== SIMULATION: POST /parents/me/contributions ===');
  console.log('  Body envoyé par l\'app: { amount: 100, method: "orangeMoney" }');
  
  if (!parent) {
    console.log('  ❌ Parent introuvable');
    return;
  }
  if (parent.status === 'pendingValidation') {
    console.log('  ❌ BLOQUÉ: Compte en attente de validation !');
    return;
  }
  if (parent.status !== 'active') {
    console.log(`  ❌ BLOQUÉ: Statut du compte = "${parent.status}" (doit être "active")`);
    return;
  }
  
  if (totalCapacity <= 0) {
    console.log('  ❌ BLOQUÉ: Aucun objectif d\'épargne actif à créditer !');
    console.log('  C\'est la raison pour laquelle les cotisations ne sont pas enregistrées.');
    return;
  }
  
  console.log(`  ✅ Le parent a un statut actif et ${totalCapacity} FCFA de capacité restante`);
  console.log('  Le paiement devrait fonctionner côté serveur');
}

main().catch(console.error).finally(() => prisma.$disconnect());
