import { writeFileSync } from 'node:fs';
import { buildOpenApiDocument } from '../src/shared/openapi/document.js';

// Exporte le spec OpenAPI en fichier statique (partage inter-équipes, CI,
// génération de clients). N'ouvre aucune connexion : pas besoin de DB.
const out = process.argv[2] ?? 'openapi.json';
writeFileSync(out, JSON.stringify(buildOpenApiDocument(), null, 2));
// eslint-disable-next-line no-console
console.log(`✔ OpenAPI exporté vers ${out}`);
