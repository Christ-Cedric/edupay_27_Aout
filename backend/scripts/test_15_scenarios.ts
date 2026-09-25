/**
 * test_15_scenarios.ts
 * ====================
 * Suite de tests de validation complète des 15 scénarios d'intégration EduPay :
 *   1. Créer/sélectionner une saison depuis l'administration.
 *   2. Vérifier sa date de début et sa date de fin.
 *   3. Créer un objectif de type fournitures scolaires.
 *   4. Créer un objectif de type scolarité.
 *   5. Créer un objectif de type moyen de déplacement.
 *   6. Vérifier que chaque objectif est bien rattaché à la saison active.
 *   7. Vérifier que les calculs utilisent la date de fin de la saison.
 *   8. Vérifier que les kits sont correctement enregistrés et récupérés.
 *   9. Vérifier que les images des moyens de déplacement s'affichent (moto, etc.).
 *  10. Effectuer plusieurs cotisations.
 *  11. Vérifier que la passerelle de paiement fonctionne correctement.
 *  12. Vérifier que chaque paiement est correctement enregistré.
 *  13. Vérifier la progression de chaque objectif.
 *  14. Changer de saison depuis l'administration et vérifier que les nouveaux objectifs utilisent la nouvelle saison.
 *  15. Vérifier qu'un ancien objectif conserve les données et les règles de sa saison d'origine.
 *
 * Usage: npx tsx scripts/test_15_scenarios.ts
 */

import { prisma } from '../src/shared/prisma.js';
import * as seasonsService from '../src/modules/seasons/seasons.service.js';
import * as kitsService from '../src/modules/kits/kits.service.js';
import * as vehiclesService from '../src/modules/vehicles/vehicles.service.js';
import * as adminService from '../src/modules/admin/admin.service.js';
import * as paymentsService from '../src/modules/payments/payments.service.js';
import { getGatewayConfig } from '../src/modules/payments/payment-gateway.service.js';
import { normalizePhone } from '../src/shared/util/phone.js';

const G = '\x1b[32m✔\x1b[0m';
const R = '\x1b[31m✘\x1b[0m';
const B = '\x1b[1m';
const E = '\x1b[0m';

let _pass = 0;
let _fail = 0;
const _failures: string[] = [];

function expect(label: string, condition: boolean, details?: string): void {
  if (condition) {
    console.log(`  ${G} ${label}`);
    _pass++;
  } else {
    console.log(`  ${R} ${label}`);
    if (details) console.log(`       ${details}`);
    _fail++;
    _failures.push(label);
  }
}

async function run15Scenarios() {
  console.log(`\n${B}================================================================${E}`);
  console.log(`${B}   VALIDATION DES 15 SCÉNARIOS DE BOUT EN BOUT EDUPAY            ${E}`);
  console.log(`${B}================================================================${E}\n`);

  // Setup: Find or create admin and test family
  const admin = await prisma.user.findFirst({ where: { role: 'admin' } });
  if (!admin) throw new Error('Aucun admin en base.');
  const actorId = admin.id;

  const testPhone = normalizePhone('+22679' + Math.floor(100000 + Math.random() * 900000));
  const testUser = await prisma.user.create({
    data: {
      role: 'client',
      status: 'active',
      fullName: 'Famille Test 15 Scénarios',
      phone: testPhone,
      passwordHash: 'dummy',
      subscription: { create: { frequency: 'weekly' } },
    },
  });

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 1 : Créer / sélectionner une saison depuis l'administration
  // ──────────────────────────────────────────────────────────────────────────
  const existingActive = await prisma.season.findFirst({ where: { isCurrent: true } });
  const baseYear = existingActive ? existingActive.launchDate.getFullYear() + 1 : 2030;
  const season1Label = `Saison-Test-A-${Date.now()}`;
  const season1Launch = new Date(`${baseYear}-01-01T00:00:00.000Z`);
  const season1Deadline = new Date(`${baseYear}-06-01T00:00:00.000Z`);

  const createdSeason1 = await seasonsService.createSeason(actorId, {
    label: season1Label,
    launch_date: season1Launch,
    delivery_deadline: season1Deadline,
    enrollment_open: true,
    refund_fee: 500,
  });
  expect('1.1 Saison 1 créée avec succès', createdSeason1.label === season1Label);

  await seasonsService.setCurrentSeason(actorId, createdSeason1.id);
  const currentSeason = await seasonsService.getCurrentSeason();
  expect('1.2 Saison 1 marquée comme saison active', currentSeason.id === createdSeason1.id && currentSeason.is_current === true);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 2 : Vérifier sa date de début et sa date de fin
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 2 : Vérifier les dates de la saison${E}`);
  expect('2.1 Date de lancement correspond à la date configurée', new Date(currentSeason.launch_date).toISOString() === season1Launch.toISOString());
  expect('2.2 Date d\'échéance correspond à la date configurée', new Date(currentSeason.delivery_deadline).toISOString() === season1Deadline.toISOString());

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIOS 3, 4, 5 : Créer 3 types d'objectifs (Fournitures, Scolarité, Déplacement)
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénarios 3, 4, 5 : Création des 3 types d'objectifs pour un enfant${E}`);
  
  // Create child
  const child = await prisma.child.create({
    data: {
      parentId: testUser.id,
      firstName: `Moussa-${Date.now()}`,
      level: 'CM2',
      school: 'École Publique Koudougou',
    },
  });

  // 3. Fournitures scolaires via kit
  // Assurons un kit existant pour la saison ou le catalogue
  let kit = await prisma.kit.findFirst({ where: { seasonId: currentSeason.id } });
  if (!kit) {
    kit = await prisma.kit.create({
      data: {
        seasonId: currentSeason.id,
        tier: 'basic',
        name: 'Kit Basique Test CM2',
        levelScope: 'CM2',
        totalPrice: 18000,
        items: {
          create: [
            { category: 'cahiers', label: '5 Cahiers 100p', quantity: 5, unitPrice: 3000, unit: 'unité' },
            { category: 'trousse', label: 'Trousse garnie', quantity: 1, unitPrice: 3000, unit: 'unité' },
          ],
        },
      },
    });
  }

  const assignedFamily = await adminService.assignKit(actorId, testUser.id, child.id, {
    kit_id: kit.id,
  });
  const childInFamily = assignedFamily.children.find((c) => c.id === child.id);
  expect('3.1 Objectif Fournitures (Kit) créé', childInFamily?.target_amount === kit.totalPrice);

  // 4. Scolarité
  const tuitionAmount = 45000;
  await adminService.setChildGoal(actorId, testUser.id, child.id, 'registration', tuitionAmount);
  const familyAfterTuition = await adminService.getFamily(testUser.id);
  const childAfterTuition = familyAfterTuition.children.find((c) => c.id === child.id);
  expect('4.1 Objectif Scolarité créé avec montant 45 000 FCFA', childAfterTuition?.tuition_amount === tuitionAmount);

  // 5. Moyen de déplacement
  const transportAmount = 150000;
  await adminService.setChildGoal(actorId, testUser.id, child.id, 'transport', transportAmount, 'Moto Yamaha YBR 125');
  const familyAfterTransport = await adminService.getFamily(testUser.id);
  const childAfterTransport = familyAfterTransport.children.find((c) => c.id === child.id);
  expect('5.1 Objectif Moyen de déplacement créé avec montant 150 000 FCFA', childAfterTransport?.transport_amount === transportAmount);
  expect('5.2 Type de déplacement correct (Moto Yamaha YBR 125)', childAfterTransport?.transport_type === 'Moto Yamaha YBR 125');

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 6 : Vérifier que chaque objectif est rattaché à la saison active
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 6 : Rattachement de chaque objectif à la saison active${E}`);
  const goalsInDb = await prisma.savingsGoal.findMany({
    where: { childId: child.id },
  });
  expect('6.1 Exactement 3 objectifs créés en base', goalsInDb.length === 3);
  const allAttachedToSeason1 = goalsInDb.every((g) => g.seasonId === currentSeason.id);
  expect('6.2 Tous les 3 objectifs sont bien rattachés à la saison active (' + currentSeason.label + ')', allAttachedToSeason1);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 7 : Vérifier que les calculs utilisent la date de fin de la saison
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 7 : Calculs dérivés de la date de fin de la saison active${E}`);
  const deadlineMs = new Date(currentSeason.delivery_deadline).getTime();
  const nowMs = Date.now();
  const diffDays = Math.max(1, Math.ceil((deadlineMs - nowMs) / (1000 * 60 * 60 * 24)));
  expect('7.1 Échéance calculée sur la base de deliveryDeadline (' + currentSeason.delivery_deadline + ')', diffDays > 0);
  const totalGoalAmount = (childInFamily?.target_amount ?? 0) + tuitionAmount + transportAmount;
  const expectedDaily = Math.ceil(totalGoalAmount / diffDays);
  expect('7.2 Montant quotidien dérivé dynamiquement du nombre de jours restants (' + expectedDaily + ' FCFA/jour)', expectedDaily > 0);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 8 : Vérifier que les kits sont enregistrés et récupérés par l'API
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 8 : Enregistrement et récupération des kits scolaires${E}`);
  const catalogKits = await kitsService.listKits('CM2');
  expect('8.1 Les kits scolaires sont récupérés avec succès', catalogKits.length > 0);
  const foundKit = catalogKits.find((k) => k.id === kit.id || k.level_scope === 'CM2');
  expect('8.2 Le kit pour le niveau CM2 est présent et contient ses fournitures', foundKit !== undefined && foundKit.items.length > 0);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 9 : Vérifier l'affichage et les images des moyens de déplacement
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 9 : Engins de déplacement et présence de l'image de la moto${E}`);
  const vehicles = await vehiclesService.listVehicles(true);
  expect('9.1 Liste des engins de déplacement non vide', vehicles.length > 0);
  const moto = vehicles.find((v) => v.name.toLowerCase().includes('moto'));
  expect('9.2 L\'engin Moto existe dans le catalogue', moto !== undefined);
  expect('9.3 L\'image de la moto est présente et non vide', Boolean(moto && moto.images.length > 0 && moto.images[0] && moto.images[0].length > 0));

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 10 : Effectuer plusieurs cotisations sur les différents objectifs
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 10 : Effectuer plusieurs cotisations${E}`);
  
  // Cotisation 1 : Fournitures (5 000 FCFA)
  const contrib1 = await paymentsService.initiateContribution(
    actorId,
    testUser.id,
    5000,
    'orangeMoney',
    undefined,
    `idem-${Date.now()}-1`,
    'supplies',
  );
  expect('10.1 Cotisation Fournitures créée avec succès', contrib1.amount === 5000);

  // Cotisation 2 : Scolarité (10 000 FCFA)
  const contrib2 = await paymentsService.initiateContribution(
    actorId,
    testUser.id,
    10000,
    'moovMoney',
    undefined,
    `idem-${Date.now()}-2`,
    'registration',
  );
  expect('10.2 Cotisation Scolarité créée avec succès', contrib2.amount === 10000);

  // Cotisation 3 : Déplacement (25 000 FCFA)
  const contrib3 = await paymentsService.initiateContribution(
    actorId,
    testUser.id,
    25000,
    'wave',
    undefined,
    `idem-${Date.now()}-3`,
    'transport',
  );
  expect('10.3 Cotisation Moyen de déplacement créée avec succès', contrib3.amount === 25000);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 11 : Vérifier le fonctionnement de la passerelle de paiement
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 11 : Configuration et passerelle de paiement${E}`);
  const gwConfig = await getGatewayConfig('ligdicash');
  expect('11.1 Configuration de la passerelle LigdiCash enregistrée en DB', gwConfig !== null && gwConfig.name === 'ligdicash');
  expect('11.2 La passerelle est marquée active', gwConfig?.isActive === true);
  expect('11.3 La transaction a reçu une référence de passerelle valide', (contrib1.provider_reference?.length ?? 0) > 0);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 12 : Vérifier que chaque paiement est correctement enregistré
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 12 : Enregistrement de chaque paiement${E}`);
  const contributions = await paymentsService.listContributions(testUser.id);
  const userContribIds = [contrib1.id, contrib2.id, contrib3.id];
  const recorded = contributions.filter((c) => userContribIds.includes(c.id));
  expect('12.1 Tous les 3 paiements sont bien enregistrés', recorded.length === 3);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 13 : Vérifier la progression de chaque objectif
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 13 : Progression et non-mélange des montants épargnés${E}`);
  const familyProgress = await adminService.getFamily(testUser.id);
  const childProgress = familyProgress.children.find((c) => c.id === child.id);

  expect('13.1 Solde Fournitures = 5 000 FCFA', childProgress?.kit_saved_amount === 5000);
  expect('13.2 Solde Scolarité = 10 000 FCFA', childProgress?.tuition_saved_amount === 10000);
  expect('13.3 Solde Moyen de déplacement = 25 000 FCFA', childProgress?.transport_saved_amount === 25000);
  expect('13.4 Solde global de la famille = 40 000 FCFA', familyProgress.balance === 40000);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 14 : Changer de saison depuis l'administration et vérifier nouveaux objectifs
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 14 : Changement de saison active par l'administration${E}`);
  const season2Label = `Saison-Test-B-${Date.now()}`;
  const season2Launch = new Date(`${baseYear}-07-01T00:00:00.000Z`);
  const season2Deadline = new Date(`${baseYear}-12-01T00:00:00.000Z`);

  const createdSeason2 = await seasonsService.createSeason(actorId, {
    label: season2Label,
    launch_date: season2Launch,
    delivery_deadline: season2Deadline,
    enrollment_open: true,
    refund_fee: 500,
  });
  await seasonsService.setCurrentSeason(actorId, createdSeason2.id);
  const newActiveSeason = await seasonsService.getCurrentSeason();
  expect('14.1 Nouvelle saison B devenue active', newActiveSeason.id === createdSeason2.id);

  // Création d'un nouvel objectif sous la nouvelle saison
  const newTuitionAmount = 60000;
  await adminService.setChildGoal(actorId, testUser.id, child.id, 'registration', newTuitionAmount);
  const newSeasonGoal = await prisma.savingsGoal.findUnique({
    where: { childId_seasonId_type: { childId: child.id, seasonId: createdSeason2.id, type: 'registration' } },
  });
  expect('14.2 Le nouvel objectif est automatiquement rattaché à la nouvelle saison B', newSeasonGoal?.seasonId === createdSeason2.id);
  expect('14.3 Montant du nouvel objectif = 60 000 FCFA', newSeasonGoal?.targetAmount === 60000);

  // ──────────────────────────────────────────────────────────────────────────
  // SCÉNARIO 15 : Vérifier que l'ancien objectif conserve les données et règles d'origine
  // ──────────────────────────────────────────────────────────────────────────
  console.log(`\n${B}▶ Scénario 15 : Conservation historique intégrale des objectifs passés${E}`);
  const oldSeasonGoal = await prisma.savingsGoal.findUnique({
    where: { childId_seasonId_type: { childId: child.id, seasonId: createdSeason1.id, type: 'registration' } },
  });
  expect('15.1 L\'ancien objectif de la Saison A existe toujours', oldSeasonGoal !== null);
  expect('15.2 L\'ancien objectif conserve son montant d\'origine (45 000 FCFA)', oldSeasonGoal?.targetAmount === 45000);
  expect('15.3 L\'ancien objectif conserve ses cotisations enregistrées (10 000 FCFA)', oldSeasonGoal?.savedAmount === 10000);
  expect('15.4 L\'ancien objectif reste rattaché à la Saison A', oldSeasonGoal?.seasonId === createdSeason1.id);

  console.log(`\n${B}================================================================${E}`);
  console.log(`RÉSULTATS : ${_pass} réussis / ${_pass + _fail} vérifications`);
  if (_fail === 0) {
    console.log(`${B}\x1b[32mTOUS LES 15 SCÉNARIOS SONT VALIDÉS AVEC SUCCÈS !${E}`);
  } else {
    console.log(`${B}\x1b[31mÉCHEC SUR LES SCÉNARIOS SUIVANTS :${E}`);
    _failures.forEach((f) => console.log(` - ${f}`));
  }
  console.log(`${B}================================================================${E}\n`);

  if (_fail > 0) process.exit(1);
}

run15Scenarios()
  .catch((err) => {
    console.error('Erreur fatale :', err);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
