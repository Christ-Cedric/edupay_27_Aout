import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './shared/logger.js';
import { prisma } from './shared/prisma.js';

const app = createApp();

// Écoute sur toutes les interfaces : accessible en local (localhost) ET depuis
// le LAN (téléphone/émulateur) via l'IP courante de la machine, qui change au
// gré du DHCP — un bind sur une IP fixe casse dès qu'elle change.
const server = app.listen(env.PORT, '0.0.0.0', () => {
  logger.info(`EduPay backend démarré sur http://localhost:${env.PORT}/api/v1`);
});

async function shutdown(signal: string): Promise<void> {
  logger.info(`Signal ${signal} reçu, arrêt en cours...`);
  server.close();
  await prisma.$disconnect();
  process.exit(0);
}

process.on('SIGINT', () => void shutdown('SIGINT'));
process.on('SIGTERM', () => void shutdown('SIGTERM'));
