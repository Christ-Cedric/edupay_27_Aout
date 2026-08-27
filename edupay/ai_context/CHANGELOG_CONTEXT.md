# Changelog Context

L'historique des modifications doit suivre le format standard "Keep a Changelog" (https://keepachangelog.com/).

## Format Attendu

```markdown
# Changelog
Tous les changements notables sur ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère à la [Gestion Sémantique de Version](https://semver.org/lang/fr/).

## [Unreleased]
### Ajouté
- Logique pour le paiement via Moov Money.

### Modifié
- Le `ParentAppState` met désormais en cache les profils enfants pour éviter un appel API à chaque affichage de `HomePage`.

### Corrigé
- Bug où le bouton "Retour" lors du flux OTP renvoyait vers le Splash Screen.

## [1.0.0] - 2026-07-15
### Ajouté
- Initialisation complète de l'architecture Clean Architecture.
- Gestion d'état asynchrone complète avec `ParentAppState`.
- Routes GoRouter sécurisées basées sur `AuthStatus`.
- Faux Backend (`FakeParentRepository`) pour tests UI fluides.
```

## Règles d'ajout
- Tout agent IA ou développeur modifiant le code d'EduPay DOIT mettre à jour la section `[Unreleased]` de ce document si les changements impactent le comportement général de l'application ou l'architecture.
