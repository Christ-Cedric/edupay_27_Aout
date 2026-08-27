# Architecture du Projet

## Modèle Architectural : Clean Architecture (simplifiée par Feature)
EduPay organise son code selon une approche "Feature-First" en couches. Chaque "Feature" (actuellement `parent/`) est découpée de manière stricte.

### 1. Couche `domain` (Business Rules)
La couche la plus profonde. Elle ne connaît rien de l'API externe, ni de Flutter.
- **Entités/Modèles (`parent_models.dart`)** : `ParentProfile`, `ChildProfile`, `Contribution`, les enums de configurations (`SavingsPlan`, `SchoolKit`, `PaymentMethod`).
- **Contrats (`parent_repository.dart`)** : Interfaces définissant ce dont l'application a besoin (Ex: `ParentRepository`).
- **Use Cases (`parent_use_cases.dart`)** : Orchestration des règles métier. Ex: `makePayment()` calcule la répartition de la cotisation entre les enfants.

### 2. Couche `data` (External Interfaces)
- **Services API (`parent_api_service.dart`)** : Gère les appels HTTP bruts via un `ApiClient` (Dossier réseau).
- **Repositories concrets (`rest_parent_repository.dart`, `fake_parent_repository.dart`)** : Implémentent les interfaces du `domain`. Ils récupèrent les JSON depuis l'API et les transforment en objets du `domain` ou inversement.

### 3. Couche `presentation` (UI)
- **UI State Management (`parent_app_state.dart`)** : Un `ChangeNotifier` massif. Il maintient l'état global (Auth, Loading states encapsulés via `RequestState<T>`, données des formulaires).
- **Views (`pages/`)** : Les écrans de l'application, complètement stupides (Stateless autant que possible), qui lisent leurs données et postent leurs événements au `ParentAppState`.
- **Navigation (`app/router/`)** : Configuration centralisée de `GoRouter`.

### 4. Couche `app` et `shared`
- `app/` contient l'amorçage de l'application : thème (`app_theme.dart`, `app_colors.dart`), configuration et `GoRouter`.
- `shared/widgets/` : Composants réutilisables, agnostiques à la Feature (Boutons d'action, Cartes, Logos).

## Flux de Dépendance (Dependency Rule)
`presentation` -> `domain` <- `data`
La présentation connaît le domaine (Modèles + Use cases). La donnée connaît le domaine (elle l'implémente). Le domaine ne connaît personne.
