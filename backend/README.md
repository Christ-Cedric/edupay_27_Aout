# EduPay — Backend

Backend partagé des deux apps EduPay (App Client + App Admin/Agent).
**Modular Monolith + Clean Architecture** — Node.js/Express + TypeScript,
PostgreSQL 16 (Prisma), Redis, JWT.

> Périmètre codé par **notre équipe** : module **Administration**, **Livraison**,
> **validation Paiements** + le socle commun (Auth, schéma). L'autre équipe
> branchera `/parents/*` et l'inscription OTP client sur le même monolithe.
> Contrat de référence : [`../docs/SHARED_API_CONTRACT.md`](../docs/SHARED_API_CONTRACT.md).

## Prérequis

- Node.js ≥ 20
- PostgreSQL 16 + Redis (via `docker compose up -d`, ou hébergés)

## Démarrage

```bash
cd backend
cp .env.example .env          # puis renseigner secrets + DATABASE_URL
npm install
npm run prisma:generate
npm run prisma:migrate        # crée les tables (nécessite PostgreSQL)
npm run db:seed               # crée l'admin par défaut
npm run dev                   # http://localhost:3000/api/v1
```

## Scripts

| Script | Rôle |
|---|---|
| `npm run dev` | Serveur en watch (tsx) |
| `npm run build` / `start` | Compilation TS puis exécution `dist/` |
| `npm run typecheck` | Vérification de types sans émission |
| `npm run prisma:migrate` | Migration de dev |
| `npm run db:seed` | Seed admin |
| `npm run openapi:export` | Export du spec OpenAPI en `openapi.json` (sans DB) |

## Documentation API (Swagger)

Générée **depuis les schémas zod** (via `@asteasolutions/zod-to-openapi`) — donc
toujours alignée sur la validation réelle des requêtes. Serveur démarré :

- **Swagger UI** : http://localhost:3000/api/v1/docs
- **Spec brut** : http://localhost:3000/api/v1/docs.json
- **Export fichier** : `npm run openapi:export` → `openapi.json` (partageable avec
  l'autre équipe, aucune connexion DB requise)

## Sécurité (socle)

- **Révocation immédiate** : `authenticate` relit le compte en base à chaque
  requête ; un compte suspendu/rejeté perd l'accès sans attendre l'expiration du
  JWT (≤ 15 min sinon). Le token n'atteste que l'identité.
- **MAJ des identifiants** : `PATCH /auth/me` (écran « Mon compte ») change
  téléphone et/ou mot de passe ; un changement de mot de passe révoque les autres
  sessions et renvoie une nouvelle paire de jetons.
- **Anti brute-force** : rate-limit sur `/auth/login` et `/auth/refresh`
  (`429 TOO_MANY_REQUESTS`).
- **Refresh tokens** : hashés + rotation, `jti` aléatoire (pas de collision même
  à deux émissions dans la même seconde).

## Périmètre : écrans de l'app Admin

Le backend est **calé sur les écrans Admin Flutter** (leurs `rest_*_data_source` +
modèles `domain/models`). Réponses JSON en `snake_case`, alignées champ pour
champ sur les modèles Dart (`Agent`, `Kit`, `Family`, `DashboardSummary`,
`RefundRequest`…).

> ⚠️ Plusieurs écrans Admin ne font **aucun appel réseau** — ils dérivent côté
> client de `/admin/families` ou `/admin/kits` : **Livraisons**, **Finances**,
> **Stats kits**. **Rapports** et **Paramètres saison** sont statiques. Aucun
> endpoint dédié n'est donc requis pour eux.

### Endpoints (adossés à un écran)

| Méthode | Route | Écran / modèle |
|---|---|---|
| GET | `/api/v1/health` · `/docs` · `/docs.json` | — |
| POST | `/api/v1/auth/login` · `refresh` · `logout` | Connexion (rate-limité) |
| GET · PATCH | `/api/v1/auth/me` | Profil · **Mon compte** (tél/mot de passe) |
| GET | `/api/v1/admin/dashboard` | Tableau de bord (`DashboardSummary`) |
| GET | `/api/v1/admin/families` | Familles (`Family[]`, `?search/status/city`) |
| GET | `/api/v1/admin/families/pending` | File de validation |
| POST | `/api/v1/admin/families` | Inscription directe |
| GET | `/api/v1/admin/families/:id` | Détail famille |
| GET | `/api/v1/admin/families/:id/contributions` | Historique cotisations (`Collection[]`) |
| POST | `/api/v1/admin/families/:id/incident` | Signaler un incident |
| POST | `/api/v1/admin/families/:id/approve` · `reject` | Validation |
| GET · POST | `/api/v1/admin/agents` | Agents (`Agent[]`, création) |
| GET · POST | `/api/v1/admin/kits` | Catalogue (`Kit[]`) |
| GET · PUT · DELETE | `/api/v1/admin/kits/:id` | Édition kit |
| GET | `/api/v1/admin/refunds` | Remboursements (`{pending, month_summary}`) |
| POST | `/api/v1/admin/refunds/:id/approve` · `reject` | Traitement |

**Endpoints dormants** (construits, pas encore adossés à un écran, gardés pour
plus tard) : `/admin/agents/:id/{suspend,reactivate}`, `/admin/seasons*`
(collection + set-current), `/admin/audit-logs`. L'écriture d'audit interne
(`writeAudit`) reste active sur toutes les mutations.

### Données de démo (`npm run db:seed`)
Saison courante 2025-2026, 3 kits (basic/intermediate/premium), 2 agents,
5 familles (3 actives, 2 en attente), 1 demande de remboursement.

## Structure

```
src/
  config/      env (validé par zod)
  shared/      prisma, logger, http (ApiError, respond), middleware (auth, erreur §1.1)
    openapi/   registry + composants + paths → doc Swagger dérivée des schémas zod
  modules/
    auth/      login / refresh / logout / me + JWT
    admin/     Administration (agents ; familles/finances/… à venir)
scripts/       export-openapi.ts (spec statique)
prisma/        schema.prisma (PROVISOIRE — points ouverts §7 marqués), seed
```

## À suivre

Endpoints restants de notre module (familles, finances, livraisons,
remboursements, saison, terrain agent) — voir contrat §5.3/§5.4. Les **7 points
ouverts** (§7) doivent être gelés avec l'autre équipe avant de figer le schéma.
