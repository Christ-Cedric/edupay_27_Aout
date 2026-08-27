const http = require('http');

async function request(path, method = 'GET', body = null, token = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: '127.0.0.1',
      port: 3000,
      path: `/api/v1${path}`,
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (token) options.headers['Authorization'] = `Bearer ${token}`;
    if (body) {
      body = JSON.stringify(body);
      options.headers['Content-Length'] = Buffer.byteLength(body);
    }
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (c) => data += c);
      res.on('end', () => resolve({ status: res.statusCode, data: data ? JSON.parse(data) : null }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function testE2E() {
  console.log('=== DÉBUT DU TEST DE BOUT EN BOUT ===');

  let phone = '+22654515907';
  let pass = 'w123L36E';
  console.log(`1. Login avec ${phone}...`);
  let loginRes = await request('/auth/login', 'POST', { phone, password: pass });
  if (loginRes.status !== 200) {
    console.log('Échec login avec +226. Essai sans...');
    phone = '54515907';
    loginRes = await request('/auth/login', 'POST', { phone, password: pass });
  }

  if (loginRes.status !== 200) {
    console.error('❌ Échec critique du Login:', loginRes);
    return;
  }
  const token = loginRes.data.access_token || loginRes.data.data?.access_token || loginRes.data.data?.accessToken;
  console.log('✅ Login réussi! Token obtenu.');

  console.log('\n2. Consultation de la famille avant paiement...');
  const famRes1 = await request('/parents/me/family', 'GET', null, token);
  const family1 = famRes1.data.data || famRes1.data;
  let activeGoalBefore = family1.savingsGoals?.find(g => g.status === 'active');
  
  if (!activeGoalBefore) {
    console.log(`   Aucun objectif actif. Assignation d'un kit au premier enfant...`);
    const childId = family1.children[0].id;
    // On doit d'abord récupérer les kits disponibles
    const { PrismaClient } = require('@prisma/client');
    const prisma = new PrismaClient();
    const kit = await prisma.kit.findFirst();
    await prisma.$disconnect();
    
    console.log(`   Assignation du kit ${kit.id} à l'enfant ${childId}`);
    await request(`/parents/me/children/${childId}/kit`, 'POST', { kitId: kit.id, customAddedItems: [], customRemovedItems: [] }, token);
    
    // Confirmer la souscription
    console.log(`   Confirmation de la souscription...`);
    await request(`/parents/me/subscription/confirm`, 'POST', { plan: 'weekly' }, token);
    
    // Recharger la famille
    const famResRefreshed = await request('/parents/me/family', 'GET', null, token);
    const familyRefreshed = famResRefreshed.data.data || famResRefreshed.data;
    activeGoalBefore = familyRefreshed.savingsGoals?.find(g => g.status === 'active');
    
    if (!activeGoalBefore) {
      console.error('❌ Toujours aucun objectif actif après assignation.');
      return;
    }
  }
  
  console.log(`   Objectif Actif: ${activeGoalBefore.name}, Épargné: ${activeGoalBefore.savedAmount} / ${activeGoalBefore.targetAmount} FCFA`);

  console.log('\n3. Envoi de la cotisation Orange Money (500 FCFA)...');
  const payRes = await request('/parents/me/contributions', 'POST', { amount: 500, method: 'orangeMoney' }, token);
  console.log('   Status HTTP:', payRes.status);
  console.log('   Réponse:', JSON.stringify(payRes.data, null, 2));

  console.log('\n4. Consultation de la famille après paiement...');
  const famRes2 = await request('/parents/me/family', 'GET', null, token);
  const family2 = famRes2.data.data || famRes2.data;
  const activeGoalAfter = family2.savingsGoals?.find(g => g.id === activeGoalBefore.id);
  console.log(`   Objectif Actif: ${activeGoalAfter.name}, Épargné: ${activeGoalAfter.savedAmount} / ${activeGoalAfter.targetAmount} FCFA`);

  if (activeGoalAfter.savedAmount === activeGoalBefore.savedAmount + 500) {
    console.log('\n✅ TEST DE BOUT EN BOUT RÉUSSI ! Le backend traite correctement les paiements Orange Money.');
  } else {
    console.log('\n❌ ÉCHEC : Le montant épargné n\'a pas augmenté correctement.');
  }
}

testE2E().catch(console.error);
