import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';
import { env } from '../src/config/env.js';
import { normalizePhone } from '../src/shared/util/phone.js';

const prisma = new PrismaClient();

/**
 * Seed idempotent :
 *  1. l'admin par défaut (contrat §2.1) ;
 *  2. un jeu de données de démonstration (saison courante, kits, agents,
 *     familles, une demande de remboursement) pour que l'app Admin ait des
 *     données réalistes à afficher pendant l'intégration.
 */
async function seedAdmin() {
  const phone = normalizePhone(env.SEED_ADMIN_PHONE);
  const existing = await prisma.user.findUnique({ where: { phone } });
  if (existing) {
    console.log(`ℹ️  Admin déjà présent (${phone}).`);
    return;
  }
  await prisma.user.create({
    data: {
      role: 'admin',
      status: 'active',
      fullName: env.SEED_ADMIN_NAME,
      phone,
      passwordHash: await bcrypt.hash(env.SEED_ADMIN_PASSWORD, 10),
    },
  });
  console.log(`✅ Admin seedé : ${phone}`);
}

async function seedDemo() {
  const existingSeason = await prisma.season.findFirst({ where: { label: '2025-2026' } });
  if (existingSeason) {
    console.log('ℹ️  Données de démo déjà présentes.');
    return;
  }

  const season = await prisma.season.create({
    data: {
      label: '2025-2026',
      launchDate: new Date('2025-06-24'),
      deliveryDeadline: new Date('2025-10-01'),
      enrollmentOpen: true,
      refundFee: 500,
      isCurrent: true,
    },
  });

  // Kits (prix saisi par l'admin ; articles en libellés).
  const kitsSpec = [
    { tier: 'basic' as const, name: 'Kit Basique', price: 18000, items: ['5 cahiers 96p', 'Trousse garnie', 'Ardoise'] },
    { tier: 'comfort' as const, name: 'Kit Intermédiaire', price: 25000, items: ['10 cahiers', 'Trousse garnie', 'Cartable', 'Blouse'] },
    { tier: 'complete' as const, name: 'Kit Premium', price: 32000, items: ['12 cahiers', 'Trousse complète', 'Cartable', 'Blouse', 'Chaussures'] },
  ];
  const kits = [];
  for (const k of kitsSpec) {
    kits.push(
      await prisma.kit.create({
        data: {
          seasonId: season.id,
          tier: k.tier,
          name: k.name,
          levelScope: k.tier,
          totalPrice: k.price,
          items: { createMany: { data: k.items.map((label) => ({ category: 'other', label, quantity: 1, unitPrice: 0 })) } },
        },
      }),
    );
  }

  const demoHash = await bcrypt.hash('Demo@1234', 10);

  const agentAli = await prisma.user.create({
    data: {
      role: 'agent', status: 'active', fullName: 'Konate Ali', phone: normalizePhone('+22670112233'),
      passwordHash: demoHash, mustChangePassword: false,
      agentProfile: { create: { zone: 'Koudougou - Secteurs 1 à 5', contractType: 'volunteer' } },
    },
  });
  await prisma.user.create({
    data: {
      role: 'agent', status: 'active', fullName: 'Sana Wendyam', phone: normalizePhone('+22670112255'),
      passwordHash: demoHash, mustChangePassword: false,
      agentProfile: { create: { zone: 'Ouagadougou - Centre', contractType: 'salaried' } },
    },
  });

  // Familles : actives (avec épargne) + en attente de validation.
  const families = [
    { name: 'Aminata Kabore', phone: '+22676123456', city: 'Koudougou', plan: 'weekly' as const, kit: 1, saved: 24700, status: 'active' as const },
    { name: 'Sawadogo Wendyam', phone: '+22670223344', city: 'Koudougou', plan: 'daily' as const, kit: 0, saved: 8100, status: 'active' as const },
    { name: 'Kabore Fatoumata', phone: '+22665889900', city: 'Ouagadougou', plan: 'monthly' as const, kit: 2, saved: 18500, status: 'active' as const },
    { name: 'Ouedraogo Marie', phone: '+22670456789', city: 'Koudougou', plan: 'weekly' as const, kit: 1, saved: 0, status: 'pendingValidation' as const },
    { name: 'Zongo Ibrahim', phone: '+22665445566', city: 'Ouagadougou', plan: 'daily' as const, kit: 0, saved: 0, status: 'pendingValidation' as const },
  ];

  let firstActiveFamilyId = '';
  for (const f of families) {
    const kit = kits[f.kit]!;
    const created = await prisma.user.create({
      data: {
        role: 'client', status: f.status, fullName: f.name, phone: normalizePhone(f.phone), city: f.city,
        passwordHash: demoHash, assignedAgentId: agentAli.id,
        subscription: { create: { frequency: f.plan, status: 'confirmed', confirmedAt: new Date() } },
        savingsGoals: { create: { type: 'supplies', name: kit.name, targetAmount: kit.totalPrice, savedAmount: f.saved, kitId: kit.id, seasonId: season.id } },
      },
    });
    if (f.status === 'active' && !firstActiveFamilyId) firstActiveFamilyId = created.id;
  }

  // Une demande de remboursement en attente (écran ad_re).
  await prisma.refund.create({
    data: { parentId: firstActiveFamilyId, amount: 24200, reason: 'Difficultés financières', status: 'requested' },
  });

  // Engins / Moyens de déplacement de démo.
  await prisma.transportVehicle.createMany({
    data: [
      {
        name: 'Moto Yamaha YBR 125',
        description: 'Moto solide et économe, idéale pour le transport des enfants et déplacements professionnels.',
        price: 650000,
        images: ['https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600'],
        isAvailable: true,
      },
      {
        name: 'Vélo Tout-Terrain (VTT) Junior',
        description: 'Vélo robuste équipé pour la piste, adapté aux élèves de collège et lycée.',
        price: 95000,
        images: ['https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=600'],
        isAvailable: true,
      },
      {
        name: 'Tricycle KAVAKI Cargo 200cc',
        description: 'Engin 3 roues grand volume pour le transport familial et marchandises.',
        price: 1200000,
        images: ['https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600'],
        isAvailable: true,
      },
    ],
  });

  console.log('✅ Données de démo seedées (saison, 3 kits, 2 agents, 5 familles, 1 remboursement, 3 engins).');
}

async function main() {
  await seedAdmin();
  await seedDemo();
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(() => void prisma.$disconnect());
