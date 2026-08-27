# Règles Métier (Business Rules)

Ces règles dictent le comportement de l'application et la logique financière, notamment en ce qui concerne le parcours de souscription et la répartition des cotisations.

## Nouvelle logique métier de sélection des plans et de répartition des cotisations

**Objectif** : Séparer le choix du mode de cotisation du calcul des montants à payer pour offrir une expérience plus fluide, avec une répartition automatique des cotisations entre les enfants.

### Étape 1 : Sélection des kits
Après la création du compte, la saisie des informations et l'ajout des enfants, le parent sélectionne un kit pour **chacun** de ses enfants (Ex: Enfant 1 = Premium, Enfant 2 = Standard) — **avant** de choisir un rythme de cotisation, pour qu'il connaisse le contenu/prix réel avant de s'engager.
* Une fois la sélection terminée, le système calcule automatiquement le coût total des kits ainsi que le montant individuel pour chaque enfant.

### Étape 2 : Choix du mode de cotisation (avec montant calculé)
Le parent choisit la fréquence de cotisation (Quotidienne, Hebdomadaire, Mensuelle). *(Révisé le 2026-08-06 : affiche désormais le montant par échéance de chaque fréquence, calculé automatiquement à partir du total des kits déjà choisis à l'Étape 1, pour que le parent puisse choisir en connaissance de cause plutôt qu'à l'aveugle.)*
* Le montant par échéance est calculé pour les 3 fréquences (jour/semaine/mois) et affiché sur chaque option.

### Étape 3 : Calcul automatique des échéances
Le système utilise la fréquence choisie à l'Étape 2 pour calculer le montant à payer à chaque échéance par rapport au coût total des kits choisis à l'Étape 1 — ce calcul est déjà visible à l'Étape 2 ; cette étape le fige au moment de la confirmation.
* Ex: Total = 300 000 FCFA. Si fréquence mensuelle -> Calcul de l'échéance mensuelle.

### Étape 4 : Contrat complet et confirmation du plan
Le parent arrive sur la page `ContractPage`, qui affiche le **contrat complet et personnalisé** (repris fidèlement du modèle `EduPay_Contrat_Parent_CGV.docx`, voir `lib/features/parent/domain/contract_document.dart`), avec **les montants enfin visibles** (Ex: "300 000 FCFA / mois").
* Le parent peut télécharger/imprimer le contrat en PDF (bouton dédié, génère le même contenu via `contract_pdf_exporter.dart`).
* Le parent coche une case d'acceptation puis confirme définitivement son engagement. C'est uniquement ici que les chiffres apparaissent.
* Pas de signature manuscrite : la lecture du contrat complet + la case à cocher + la confirmation valent acceptation explicite.

### Étape 5 : Cotisation et Répartition Automatique
Une fois le plan validé, le parent cotise de manière globale.
* **Principe clé** : Le paiement effectué ne doit jamais être considéré comme un paiement global non alloué.
* Le système répartit **automatiquement** chaque versement entre les enfants **au prorata** de la valeur du kit attribué à chacun.
* Ex : Si le total est 300 000 FCFA (Enfant A: 120k, Enfant B: 100k, Enfant C: 80k) et le parent verse 10 000 FCFA, l'algorithme distribue ces 10 000 FCFA proportionnellement à chaque enfant.

## Règle d'or de l'expérience utilisateur
L'application **ne demande jamais** au parent de choisir un enfant avant de cotiser.
Le parent effectue une seule cotisation correspondant à son échéance, et le système ventile l'argent en arrière-plan. Chaque enfant conserve son suivi individuel (montant payé, reste à payer, progression), tout en gardant l'expérience simple pour le parent.

## Règles additionnelles

### Calcul de progression (Dashboard)
- **Total Objectif (`totalGoal`)** : La somme des prix des kits de tous les enfants du parent.
- **Total Épargné (`totalSaved`)** : La somme des montants déjà épargnés (`savedAmount`) par tous les enfants.
- **Pourcentage de Progression (`progress`)** : `(totalSaved / totalGoal) * 100`.

### Validation Formulaire
- Un enfant ne peut être ajouté que si son prénom, son niveau et le nom de son école sont renseignés (déclenche une `ArgumentError` locale sinon).

### Flux de l'Onboarding et Responsabilité
- **Architecture de l'Onboarding** : L'onboarding est strictement limité à l'activation du compte (Phone, OTP, Profil parent). Il ne contient **aucune** logique métier liée aux plans, kits ou cotisations. Le passage à `AuthStatus.authenticated` se fait dès que le profil est rempli.
- **Espace "Mes enfants"** : Toutes les opérations de souscription (choix du plan, des kits, etc.) débutent depuis la section "Mes enfants" de l'application principale, offrant une expérience modulaire et la possibilité de souscrire ou modifier un plan ultérieurement sans recréer un compte.
