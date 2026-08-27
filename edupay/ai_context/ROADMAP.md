# Roadmap (Fonctionnalités Prévues / À implémenter)

En observant la structure actuelle, l'architecture Clean, et les use cases, plusieurs évolutions sont probables ou nécessaires pour amener l'application en production :

## Phase 1 : Finalisation de l'API Backend
- Remplacement effectif du `FakeParentRepository` par le `RestParentRepository` dans l'injection de dépendances (`app_dependencies.dart` / `parent_scope.dart`).
- Sécurisation des routes API (gestion des JWT, rafraîchissement des tokens).
- Gestion des états hors ligne (Caching local de la configuration des kits et des profils).

## Phase 2 : Moyens de paiement avancés
- Intégration réelle des SDK Orange Money / Moov Money pour automatiser la vérification de transaction (via callback ou webhooks). Le paiement est actuellement modélisé sans pont direct avec un SDK natif complexe.

## Phase 3 : Logistique & Suivi
- La page `DeliveryPage` (Livraison) nécessitera un suivi des commandes de kits avec statuts (En préparation, Expédié, Livré).
- La page `RefundPage` (Remboursement) nécessitera des vérifications d'éligibilité au remboursement avant traitement.

## Phase 4 : Améliorations UX
- Animations poussées sur la progression de l'épargne.
- Notifications Push (nécessite une intégration Firebase Cloud Messaging ou équivalent) pour la page `NotificationsPage`.
