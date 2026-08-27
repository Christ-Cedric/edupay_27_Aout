# Contexte du Projet : EduPay

## Vision du Projet
EduPay est une application Flutter visant à simplifier et organiser la collecte d'épargne ou de fonds auprès des parents d'élèves pour le financement des frais de scolarité, l'achat de kits scolaires et autres dépenses liées à l'éducation.

## Objectifs
- Digitaliser et sécuriser l'épargne des parents (plans journaliers, hebdomadaires, mensuels).
- Faciliter le suivi des cotisations pour chaque enfant.
- Proposer la personnalisation et l'achat de kits scolaires de manière anticipée.
- S'intégrer avec les moyens de paiement locaux (Mobile Money : Orange Money, Moov Money).

## Public Cible
Les parents d'élèves, principalement dans un contexte ouest-africain (Burkina Faso, d'après les numéros et villes par défaut comme Koudougou, et la devise XOF), souhaitant anticiper les dépenses scolaires de leurs enfants.

## Description Complète et Fonctionnement Général
L'application simplifie l'inscription en limitant l'"Onboarding" à la création et l'activation du compte (Numéro de téléphone, OTP, Informations personnelles). Une fois le compte créé, le parent est immédiatement redirigé vers l'application principale (Home).
Toutes les fonctionnalités métier (gestion des enfants, choix des plans, sélection des kits, cotisations) sont réalisées depuis l'application principale. Depuis la section "Mes enfants", le parent peut gérer les enfants et démarrer le parcours de souscription (choix de la fréquence, sélection des kits, calcul automatique, confirmation).

## Architecture Globale
Le projet suit une **Clean Architecture** classique avec séparation en couches :
1. **Domain Layer (`domain/`)** : Contient les modèles métiers et les abstractions des contrats (`ParentRepository`), sans aucune dépendance au framework UI.
2. **Data Layer (`data/`)** : Implémente le contrat du Domain. Comprend des services API (`ParentApiService`), et des Repositories concrets (`RestParentRepository`, `FakeParentRepository`).
3. **Presentation Layer (`presentation/`)** : Composée des Pages (`pages/`), de la logique UI et du State Management (`parent_app_state.dart`).

## Technologies
- **Flutter / Dart** (SDK `^3.12.2`)
- **GoRouter** : Gestion complète et déclarative de la navigation avec des redirections basées sur le statut d'authentification (`AuthStatus`).
- **Provider / ChangeNotifier** : Gestion de l'état asynchrone et de la logique de présentation.
- **Material Design / Cupertino Icons** : Design System.

## Organisation du Code
- `lib/app/` : Configuration, Réseau (ApiClient), Routage, Thème global.
- `lib/features/` : Modules fonctionnels, actuellement centré sur la feature `parent`.
- `lib/shared/` : Composants UI réutilisables (`widgets/`).

## Contraintes et Décisions Architecturales
- **Optimistic UI Updates** : (Ex. l'ajout d'un enfant met à jour la liste en local avant confirmation du backend pour ne pas bloquer l'UI, cf `ParentAppState.addChild`).
- **Fake Repository** : Le projet inclut un backend simulé (`FakeParentRepository`) pour le développement rapide ou le mode démo hors ligne.
- **State unique** : Un seul `ParentAppState` (héritant de `ChangeNotifier`) gère toute la logique de présentation et conserve l'état d'authentification et des données en mémoire.
