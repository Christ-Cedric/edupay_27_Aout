# EduPay — Contrat d'API & de données partagé

> **Source de vérité unique** pour le backend commun aux **deux apps Flutter** (App Client/Parent et App Admin/Agent) et aux **deux équipes**.
> Tant qu'un point n'est pas tranché ici, il ne doit PAS être codé côté backend.
>
> - Statut : **PROPOSITION v0.1** — à valider conjointement par les deux équipes.
> - Les points marqués **🔲 À TRANCHER** attendent une décision commune.
> - Stack cible : Node.js + Express, Modular Monolith + Clean Architecture, PostgreSQL 16, Prisma, Redis, JWT, REST.

---

## 0. Pourquoi ce document

Aujourd'hui chaque équipe a modélisé sa moitié séparément, et les deux divergent déjà (casse JSON, schéma de tokens, routes, année scolaire, kit par enfant vs par famille). Le backend étant **partagé**, ces choix ne peuvent pas coexister. Ce document réconcilie tout en **un seul contrat** que les deux frontends et le backend respectent.

Règle d'or : **le backend est la source de vérité des montants et des règles métier.** Les apps affichent et déclarent, le backend calcule et valide (répartition prorata, échéances, recalcul des kits, validation des paiements).

---

## 1. Conventions transversales

| Sujet | Décision |
|---|---|
| Préfixe | `/api/v1` |
| Casse JSON (fil) | **`snake_case`** (ex. `full_name`, `saved_amount`, `kit_id`). Dart reste en `camelCase` via `fromJson`/`toJson`. |
| Réponse liste | Enveloppe `{ "data": [ ... ], "meta": { "page", "per_page", "total" } }` |
| Réponse objet | L'objet directement (`{ "id": ..., ... }`) |
| Dates | ISO 8601 UTC (`2026-10-01T00:00:00Z`) |
| Montants | **Entiers en FCFA/XOF** (jamais de décimales — arrondi métier au multiple de 50) |
| Devise | `"XOF"` |
| Auth header | `Authorization: Bearer <access_token>` |
| Idempotence | Les `POST` de paiement/encaissement acceptent un header `Idempotency-Key` (évite le double débit sur retry réseau 3G) |

### 1.1 Format d'erreur unifié (repris de l'app Client, §"8.4")

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Le numéro de téléphone est invalide.",
    "details": [
      { "field": "phone", "issue": "format" }
    ]
  }
}
```

Codes normalisés : `VALIDATION_ERROR` (400), `UNAUTHENTICATED` (401), `TOKEN_EXPIRED` (401),
`FORBIDDEN` (403), `NOT_FOUND` (404), `CONFLICT` (409), `ACCOUNT_PENDING_VALIDATION` (403),
`RATE_LIMITED` (429), `SERVER_ERROR` (500).

### 1.2 Pagination

Query params `?page=1&per_page=20`. Défaut `per_page=20`, max `100`.

---

## 2. Authentification & rôles

### 2.1 Rôles

`client` (parent), `agent` (terrain), `admin` (fondateur/gestionnaire).
Un même endpoint peut être ouvert à plusieurs rôles avec des données filtrées par le scope du token.

> **L'OTP concerne EXCLUSIVEMENT l'auto-inscription du client.** L'admin et l'agent ne passent jamais par l'OTP :
> - **Admin** : compte seedé par défaut à l'installation du backend (pas de création via l'app).
> - **Agent** : créé par l'admin, se connecte directement par téléphone + mot de passe.
> - **Client** : seul rôle à s'auto-inscrire → OTP obligatoire pour prouver la possession du numéro.

### 2.2 Schéma de tokens (aligné sur l'app Client, plus complet)

- **`access_token`** : JWT court (~15 min). Claims : `sub` (user_id), `role`, `status`, `exp`.
- **`refresh_token`** : long (~30 j), rotation à chaque usage, stocké hashé côté serveur.
- **`registration_token`** : temporaire, émis après vérification OTP, autorise uniquement `POST /auth/register`.

> ⚠️ L'app Admin/Agent actuelle utilise un token unique sans refresh → **doit adopter ce schéma access+refresh**.

### 2.3 Flux d'inscription Client (OTP)

```
POST /auth/otp/request   { phone }                         → 200 (code envoyé par SMS)
POST /auth/otp/verify    { phone, code }                   → { registration_token }
POST /auth/register      { full_name, city, district,      → { access_token, refresh_token, user }
                           password }   (Bearer: registration_token)
```

Le compte client est créé avec **`status = pending_validation`** (cf. §6.4).

### 2.4 Flux Agent & Admin

- **Agent** : PAS d'auto-inscription. Créé par l'admin (`POST /admin/agents`), reçoit ses accès par SMS, se connecte par `POST /auth/login`. Doit changer son mot de passe au 1er login (`must_change_password = true`).
- **Admin** : compte(s) seedé(s).
- **Connexion commune (agent + admin + client existant)** :

```
POST /auth/login    { phone, password }   → { access_token, refresh_token, user }
POST /auth/refresh  { refresh_token }      → { access_token, refresh_token }
POST /auth/logout   { refresh_token }      → 204
```

> 🔲 **À TRANCHER** : le cahier des charges mentionne aussi un **PIN 4 chiffres** (F-05) en plus du mot de passe. Décision : mot de passe seul, ou PIN optionnel en second facteur/déverrouillage local ? Recommandation : **mot de passe** comme identifiant serveur, **PIN** = déverrouillage local côté app uniquement (pas un secret backend).

---

## 3. Modèle de données unifié (schéma logique)

Décrit ici en langage neutre ; deviendra le `schema.prisma`. Toutes les clés sont `snake_case`, PK = `id` (UUID/cuid).

### 3.1 `user`
| champ | type | notes |
|---|---|---|
| id | id | |
| role | enum | `client` \| `agent` \| `admin` |
| full_name | string | |
| phone | string | **unique**, format +226… normalisé |
| password_hash | string | |
| status | enum | `pending_validation` \| `active` \| `rejected` \| `suspended` |
| city | string? | |
| district | string? | |
| must_change_password | bool | agents créés par l'admin |
| rejection_reason | string? | si `rejected` (cf. validation) |
| assigned_agent_id | id? | pour un client : son agent référent |
| created_at / updated_at | datetime | |

### 3.2 `agent_profile` (extension 1-1 de `user` role=agent)
| champ | type | notes |
|---|---|---|
| user_id | id | FK unique |
| zone | string | ex. « Koudougou — Secteurs 1 à 5 » |
| contract_type | enum | `volunteer` \| `salaried` |
| commission_per_enrollment | int | défaut 200 FCFA |
| commission_rate_bps | int | 200 = 2 % (points de base) |

### 3.3 `child`
| champ | type | notes |
|---|---|---|
| id | id | **id stable** (l'app Client utilise aujourd'hui le prénom → à corriger) |
| parent_id | id | FK user(client) |
| first_name | string | |
| level | enum/string | Maternelle → Terminale |
| school | string | |
| photo_url | string? | |
| created_at | datetime | |

### 3.4 `savings_goal` (⭐ moteur générique — exigence non-négociable)
Une « enveloppe » d'épargne. En V1 : type `supplies` (fournitures) rattaché à un enfant. Extensible (`registration`, `exam`, `transport`, `canteen`, `uniform`) **sans changement de code**.
| champ | type | notes |
|---|---|---|
| id | id | |
| parent_id | id | |
| child_id | id? | null pour un objectif au niveau foyer |
| type | enum | `supplies` (V1) + extensions futures |
| name | string | ex. « Fournitures Fatoumata » |
| target_amount | int | = prix du kit sélectionné (pour `supplies`) |
| saved_amount | int | dérivé de la somme des allocations (source de vérité = ledger) |
| kit_id | id? | pour `supplies` : kit choisi |
| status | enum | `active` \| `completed` \| `cancelled` |
| season_id | id | |

> Le montant cible d'un objectif `supplies` est **piloté par le kit** (§3.6). Changer de kit recalcule `target_amount` sans perdre `saved_amount` (cf. §6.3).

### 3.5 `subscription`
La préférence de cotisation du parent (fréquence), séparée du montant (BUSINESS_RULES étape 1).
| champ | type | notes |
|---|---|---|
| id | id | |
| parent_id | id | |
| frequency | enum | `daily` \| `weekly` \| `monthly` |
| status | enum | `draft` \| `confirmed` |
| confirmed_at | datetime? | |

### 3.6 `kit` & `kit_item` (catalogue admin, recalcul temps réel)
`kit`
| champ | type | notes |
|---|---|---|
| id | id | identifiant **partagé** entre les deux apps |
| tier | enum | `basic` \| `comfort` \| `complete` |
| name | string | « Kit Essentiel/Confort/Complet+ » |
| level_scope | string | niveau scolaire ciblé |
| total_price | int | **saisi par l'admin** (l'app ne le calcule pas) |
| season_id | id | |
| is_active | bool | |

`kit_item` (lignes d'articles)
| champ | type | notes |
|---|---|---|
| id | id | |
| kit_id | id | |
| category | enum | `notebooks` \| `books` \| `pens` \| `uniforms` \| `accessories` \| `other` |
| label | string | |
| quantity | int | |
| unit_price | int | |

> 🔲 **À TRANCHER** : kit **par famille** (modèle actuel Admin/Agent) vs **par enfant** avec possibilité de kit **personnalisé** (modèle Client). Recommandation : **par enfant** (le modèle Client est le plus riche et colle au cahier). L'Admin/Agent doit s'aligner : un dossier famille agrège les kits de ses enfants.

### 3.7 `season` (paramètres de saison — admin)
| champ | type | notes |
|---|---|---|
| id | id | |
| label | string | 🔲 **À TRANCHER** : `2025-2026` (cahier/Admin) vs `2026-2027` (code Client) |
| launch_date | date | |
| delivery_deadline | date | ex. 1er octobre — pilote le calcul des échéances |
| enrollment_open | bool | |
| refund_fee | int | 500 FCFA |
| is_current | bool | |

### 3.8 `contribution` (une cotisation encaissée) + `contribution_allocation`
`contribution`
| champ | type | notes |
|---|---|---|
| id | id | |
| parent_id | id | |
| amount | int | montant global versé |
| method | enum | `orange_money` \| `moov_money` \| `cash_agent` |
| reference | string | n° reçu (ex. `EP-RC-2026-0149`) ou réf. Mobile Money |
| status | enum | `pending_validation` \| `confirmed` \| `failed` |
| collected_by_agent_id | id? | si encaissée par un agent |
| proof_url | string? | capture d'écran / preuve (Phase A) |
| created_at | datetime | |
| confirmed_at | datetime? | |

`contribution_allocation` (répartition prorata — BUSINESS_RULES étape 5)
| champ | type | notes |
|---|---|---|
| id | id | |
| contribution_id | id | |
| child_id | id | |
| savings_goal_id | id | |
| amount | int | part prorata pour cet enfant |

### 3.9 `delivery` & `delivery_issue`
`delivery`
| champ | type | notes |
|---|---|---|
| id | id | |
| parent_id | id | |
| child_id | id? | |
| kit_id | id | |
| status | enum | `preparation` \| `shipped` \| `out_for_delivery` \| `delivered` \| `receipt_confirmed` |
| assigned_agent_id | id? | |
| location_lat / location_lng / address | | épingle envoyée **par le parent** |
| delivery_note_no | string? | ex. `BL-2026-0048` |
| signed_at | datetime? | signature à la réception |

`delivery_issue`
| champ | type | notes |
|---|---|---|
| id | id | |
| delivery_id | id | |
| type | enum | `not_received` \| `missing_item` \| `damaged_item` \| `late_delivery` \| `other` |
| description | string | |
| photo_url | string? | |
| status | enum | `open` \| `resolved` |

### 3.10 `refund`
| champ | type | notes |
|---|---|---|
| id | id | |
| parent_id | id | |
| amount | int | total cotisé − frais (500) |
| reason | string | |
| status | enum | `requested` \| `processing` \| `approved` \| `rejected` \| `refunded` |
| processed_by_admin_id | id? | |

### 3.11 `ledger_entry` (journal comptable immuable) & `audit_log`
- **`ledger_entry`** : append-only, chaque mouvement d'argent (cotisation confirmée, remboursement). Jamais d'`UPDATE`/`DELETE`. Source de vérité de `saved_amount`.
- **`audit_log`** : chaque action sensible horodatée (validation paiement, approbation remboursement, changement de kit, création agent) avec `actor_id`, `action`, `entity`, `before`/`after`.

### 3.12 `notification`
| champ | type | notes |
|---|---|---|
| id / user_id / type / title / body / channel(`push`\|`sms`\|`whatsapp`\|`in_app`) / read_at / created_at | | |

---

## 4. Découpage en modules & répartition des équipes

Les **6 modules du cahier des charges** (transversaux au découpage par app). Proposition de propriété :

| Module | Contenu | Propriétaire proposé |
|---|---|---|
| **Utilisateurs / Auth** | comptes, rôles, OTP, JWT, validation de compte | 🤝 **Commun — à figer ensemble EN PREMIER** |
| **Épargne (moteur générique)** | `savings_goal`, `subscription`, calcul d'échéances, prorata | 🤝 **Commun — à figer ensemble EN PREMIER** |
| **Catalogue Kits** | `kit`, `kit_item`, recalcul temps réel | 🤝 Commun (CRUD côté Admin, lecture côté Client) |
| **Paiements** | `contribution`, allocations, validation, Provider Pattern MoMo | Client déclare · **Admin/Agent valide** |
| **Livraison** | `delivery`, `delivery_issue` | Client suit · **Admin/Agent gère** |
| **Notifications** | push/SMS/WhatsApp, rappels, alertes | 🔲 À attribuer (proposé : équipe Client) |
| **Administration** | dashboard, agents, rapports, saison, remboursements | **Équipe Admin/Agent** |

**Ordre de travail recommandé :**
1. **Semaine 0 (ensemble)** : valider ce contrat → geler `schema.prisma`, Auth, moteur Épargne, conventions.
2. Puis chaque équipe développe son périmètre contre le schéma commun, avec tests de contrat.
3. Intégration continue sur un backend unique dès le départ (pas de merge « big bang » à la fin).

---

## 5. Catalogue des endpoints (couvre les DEUX apps)

### 5.1 Auth (commun) — voir §2

### 5.2 Client / Parent
```
GET    /parents/me                          profil
PUT    /parents/me
GET    /parents/me/children
POST   /parents/me/children
PUT    /parents/me/children/:id
DELETE /parents/me/children/:id
POST   /parents/me/subscription/confirm     { frequency }
GET    /parents/me/savings                   objectifs + progression (totalGoal/totalSaved/progress)
GET    /kits?level=CM2                        catalogue (lecture)
POST   /parents/me/children/:id/kit          { kit_id | custom_items[] }  → recalcule target
GET    /parents/me/contributions             historique + allocations
POST   /parents/me/contributions             déclare un paiement (Phase A) → status=pending_validation
GET    /parents/me/deliveries
POST   /parents/me/deliveries/:id/location   épingle GPS
POST   /parents/me/deliveries/:id/confirm    signature réception
POST   /parents/me/deliveries/:id/issues     signalement
POST   /parents/me/refunds                   demande de remboursement
GET    /parents/me/notifications
```

### 5.3 Agent terrain
```
GET    /agent/me/dashboard                   KPI (clients, collectes, impayés)
GET    /agent/me/clients                     portefeuille de l'agent
GET    /agent/me/clients/:id
POST   /agent/me/clients                     inscription assistée (crée user client + status)
POST   /agent/me/contributions               encaissement → split prorata (§6.1)
GET    /agent/me/deliveries?date=today
GET    /agent/me/deliveries/:id              bon de livraison
POST   /agent/me/deliveries/:id/validate
GET    /agent/me/overdue                      relances impayés
POST   /agent/me/overdue/remind              SMS de relance
GET    /agent/me/report                       rapport hebdo + commissions
```

### 5.4 Admin
```
GET    /admin/dashboard                       KPI globaux + alertes
GET    /admin/families                        toutes les familles (filtres ville/statut/agent)
GET    /admin/families/:id                     dossier
GET    /admin/families/pending                 comptes en attente de validation
POST   /admin/families/:id/approve             ✅ active le compte client
POST   /admin/families/:id/reject              { reason }
GET    /admin/finances                         bilan (par ville / par plan)
GET    /admin/reports?type=...&format=xlsx
GET    /admin/agents  ·  POST /admin/agents    gestion agents
GET    /admin/kits · POST · PUT · DELETE       CRUD catalogue (déclenche recalcul)
POST   /admin/kits/:id/duplicate               dupliquer d'une saison à l'autre
GET    /admin/deliveries                        suivi global
GET    /admin/refunds  ·  POST /admin/refunds/:id/approve  ·  /reject
GET    /admin/season · PUT /admin/season        paramètres (dates, tarifs, commissions)
GET    /admin/kit-stats                          répartition des kits
POST   /admin/contributions/:id/validate         valide un paiement déclaré (Phase A)
```

---

## 6. Règles métier (implémentées côté backend, source de vérité)

### 6.1 Répartition prorata d'une cotisation (BUSINESS_RULES étape 5) — **critique, commune**
Le parent (ou l'agent) verse **un montant global** sans choisir d'enfant. Le backend ventile au prorata du **reste à payer** de chaque objectif :
```
part_enfant_i = montant_versé × (reste_i / Σ reste)   [arrondi, le reliquat va au plus grand reste]
```
Crée N `contribution_allocation` + N `ledger_entry`. **Le même algorithme s'applique à l'encaissement agent.**

### 6.2 Calcul des échéances (cahier 5bis.4, confirmé par le prototype)
```
jours_restants = delivery_deadline − aujourd'hui
Journalier : montant = ⌈ total ÷ jours_restants ⌉  arrondi au multiple de 50 supérieur
Hebdo      : semaines = ⌊ jours_restants ÷ 7 ⌋ ;  montant = ⌈ total ÷ semaines ⌉ → 50
Mensuel    : mois = ⌊ jours_restants ÷ 30 ⌋ ;      montant = ⌈ total ÷ mois ⌉ → 50
```
`total` = somme des `target_amount` des objectifs actifs du parent.

### 6.3 Changement de kit (cahier 5bis.6)
`nouveau_reste = nouveau_prix_kit − saved_amount` ; `saved_amount` **jamais perdu** ; échéances recalculées ; historique conservé ; confirmation explicite requise.

### 6.4 Validation de compte client (règle métier ajoutée — cf. mémoire projet)
Après inscription, `user.status = pending_validation`. Le client voit un **écran bloquant** et n'accède pas au dashboard tant que l'admin n'a pas appelé `/admin/families/:id/approve`. `reject` → `status=rejected` + `rejection_reason`. Le login renvoie `403 ACCOUNT_PENDING_VALIDATION` (avec un token limité permettant seulement d'afficher l'écran d'attente). 🔲 **À TRANCHER** : ce gating s'applique-t-il aussi aux clients inscrits **par un agent** ? (Recommandation : inscription agent = déjà `active`, car l'agent fait foi.)

### 6.5 Paiement Mobile Money phasé (cahier §8)
- **Phase A (lancement)** : déclaration manuelle → `status=pending_validation` → file admin/gestionnaire → `validate`. Objectif < 2 h.
- **Phase B** : USSD Push. **Phase C** : API complète. Le backend expose une abstraction **Provider Pattern** (`PaymentProvider`) pour brancher Orange/Moov sans toucher au domaine.

### 6.6 Recalcul temps réel du catalogue (cahier 5bis.7 — non-négociable)
Toute modif de `kit.total_price` ou `season.delivery_deadline` recalcule les montants par échéance affichés, **sans redéploiement**. Les apps ne mettent jamais en cache un montant calculé « en dur ».

---

## 7. Points à trancher ensemble (bloquants avant le backend)

1. 🔲 **Année scolaire** : `2025-2026` vs `2026-2027`.
2. 🔲 **Kit par famille vs par enfant** (+ kits personnalisés) → recommandé : **par enfant**.
3. 🔲 **PIN** : secret backend ou simple déverrouillage local ? → recommandé : local.
4. 🔲 **Gating de validation** pour les clients inscrits par un agent.
5. 🔲 **Propriété du module Notifications**.
6. 🔲 **Casse & schéma de tokens** : l'app Admin/Agent doit migrer vers `snake_case` + access/refresh (l'app Client est déjà conforme).
7. 🔲 **`id` stable des enfants** : l'app Client utilise le prénom comme id → à remplacer par un vrai id serveur.

---

*Document vivant — mettre à jour au fil des décisions. Prochaine étape proposée : geler ce contrat en réunion inter-équipes, puis dériver le `schema.prisma` et les DTO partagés.*
