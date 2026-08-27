import { OpenApiGeneratorV3 } from '@asteasolutions/zod-to-openapi';
import { registry } from './registry.js';
// Effets de bord : ces imports enregistrent composants et routes dans `registry`.
import './components.js';
import './paths.js';

/** Construit le document OpenAPI 3.0 à partir du registre zod. */
export function buildOpenApiDocument() {
  const generator = new OpenApiGeneratorV3(registry.definitions);
  return generator.generateDocument({
    openapi: '3.0.0',
    info: {
      title: 'EduPay API',
      version: '0.1.0',
      description:
        'API du monolithe EduPay (contrat inter-équipes v1). Périmètre couvert ' +
        'ici : Auth + module Administration/Agent. Toutes les routes sont ' +
        'préfixées par `/api/v1`. Erreurs au format unifié §1.1.',
    },
    servers: [{ url: '/api/v1', description: 'Base de l’API' }],
    tags: [
      { name: 'Système' },
      { name: 'Auth' },
      { name: 'Admin · Dashboard' },
      { name: 'Admin · Familles' },
      { name: 'Admin · Agents' },
      { name: 'Admin · Catalogue' },
      { name: 'Admin · Remboursements' },
      { name: 'Admin · Audit' },
      { name: 'Paiements' },
    ],
  });
}
