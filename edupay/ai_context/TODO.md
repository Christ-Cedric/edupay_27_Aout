# TODO (Améliorations et Tâches immédiates)

## Tâches Architecturales
- [ ] Diviser le `ParentAppState` en plusieurs contrôleurs de formulaire spécifiques pour éviter les fuites de mémoire potentielles si les `TextEditingController` restent actifs trop longtemps.
- [ ] Implémenter un intercepteur HTTP (ex: avec `dio`) pour gérer l'injection du token d'authentification sur toutes les requêtes du backend.

## Tâches Fonctionnelles
- [ ] Connecter la validation OTP au service d'authentification réel.
- [ ] Ajouter une gestion du mode Hors Ligne (Offline Support) lors du chargement du Dashboard (`ParentUseCases.loadDashboard`), car l'absence de réseau lève probablement une erreur immédiate bloquante.
- [ ] Mettre en place la page des "Réglages" dans le Profil (`ProfilePage`).

## Tâches UI / UX
- [ ] Vérifier que les messages d'erreur remontés par `RequestState.error` soient traduits de l'anglais/technique vers le français pour l'utilisateur final.
- [ ] Ajouter des tests visuels ou d'intégration (Golden Tests) pour s'assurer du rendu correct des "Cartes Enfants" avec la progression d'épargne.
