import {
  OpenAPIRegistry,
  extendZodWithOpenApi,
} from '@asteasolutions/zod-to-openapi';
import { z } from 'zod';

// Doit s'exécuter avant tout appel à `.openapi(...)` sur un schéma zod. Ce
// module étant importé en premier par les autres fichiers `openapi/`, l'ordre
// est garanti.
extendZodWithOpenApi(z);

/** Registre unique alimenté par `components.ts` et `paths.ts`. */
export const registry = new OpenAPIRegistry();

// Sécurité : jeton d'accès JWT en Bearer (contrat §2).
registry.registerComponent('securitySchemes', 'bearerAuth', {
  type: 'http',
  scheme: 'bearer',
  bearerFormat: 'JWT',
});

/** À placer sur les routes protégées. */
export const bearerAuth = [{ bearerAuth: [] }];
