# Backend Context

## Architecture
Le backend est interfacé côté application par la couche "Data" (Dossier `data/`). L'application utilise le pattern Repository pour s'isoler des détails d'implémentation de l'API externe.

## Composants
1. **ParentApiService** (`features/parent/data/services/parent_api_service.dart`) : Une classe de bas niveau qui gère les appels réseaux spécifiques à la ressource `parent`.
2. **RestParentRepository** (`features/parent/data/repositories/rest_parent_repository.dart`) : Implémente l'interface `ParentRepository`. Il utilise `ParentApiService` pour effectuer les requêtes, puis désérialise les JSON (souvent au format `Map<String, dynamic>`) en modèles du domaine fort typés (ex: `ParentProfile.fromJson`).
3. **FakeParentRepository** (`features/parent/data/fake_parent_repository.dart`) : Fournit des données statiques simulées (mocks) pour le développement ou les tests (parfait lorsque le backend réel n'est pas encore prêt).

## Logique Métier (Use Cases)
La logique métier agissant comme intermédiaire entre le Frontend et les Repositories se trouve dans `ParentUseCases`.
Par exemple :
- `makePayment` prend en charge le fractionnement d'une cotisation en l'allouant aux enfants en fonction de l'argent restant dû pour leur kit respectif, puis enregistre la transaction via le repository.

## Sécurité & Middleware
Géré par l'infrastructure réseau (probablement `ApiClient` dans `app/network/`), le backend recevra vraisemblablement des tokens d'authentification après validation de l'OTP (Phase d'authentification par téléphone).

## Gestion des Erreurs
Les erreurs réseau sont propagées sous forme d'Exceptions (`Exception` ou `Error`) depuis la couche Data, remontent à travers les `UseCases`, pour être finalement capturées dans le `try-catch` du `ParentAppState` où elles mettront à jour les `RequestState.error` pour affichage dans l'UI.
