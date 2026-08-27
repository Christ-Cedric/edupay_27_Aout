import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({ select: { id: true, phone: true, role: true, fullName: true } });
  console.log('Utilisateurs en base :', users);
  const hash = await bcrypt.hash('admin123', 10);
  await prisma.user.updateMany({
    where: { phone: '+22676691911' },
    data: { passwordHash: hash },
  });
  console.log('Mot de passe de +22676691911 réinitialisé à : admin123');
}

main().finally(() => prisma.$disconnect());
