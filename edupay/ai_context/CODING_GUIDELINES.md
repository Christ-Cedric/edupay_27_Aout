# Coding Guidelines & Conventions

Pour maintenir la cohérence de la base de code, tout nouveau développement dans EduPay doit respecter les règles suivantes :

## 1. Architecture par Fonctionnalité (Feature-First)
- Tout nouveau domaine fonctionnel doit être placé dans `lib/features/<nom_feature>/`.
- À l'intérieur, respectez strictement le découpage `data/`, `domain/`, `presentation/`.
- **Ne mélangez jamais les responsabilités** : Les classes de présentation ne font pas d'appels HTTP, elles appellent les `UseCases` (Domain), qui appellent les `Repositories` (Domain -> Data).

## 2. Nommage (Naming Conventions)
- **Fichiers** : `snake_case.dart` (ex: `parent_app_state.dart`).
- **Classes & Enums** : `PascalCase` (ex: `ParentProfile`).
- **Variables & Méthodes** : `camelCase` (ex: `totalSaved`).
- **Extensions** : suffixées par `Details` ou `Label` (ex: `SchoolKitLabel`).
- **Widgets** : Nom explicite lié à l'UI (ex: `AddChildPage`, `ActionCard`).

## 3. UI et Widgets (Stateless vs Stateful)
- Privilégiez les `StatelessWidget`.
- Si l'écran a besoin de réagir aux changements d'état, lisez cet état via `context.watch<ParentAppState>()` ou des `Consumer`.
- Ne stockez **pas** de logique métier dans les widgets. Confiez-la au `ParentAppState`.
- Évitez les arbres de widgets trop profonds. Séparez les morceaux logiques en sous-widgets privés (ex: `_HeaderSection`, `_ItemList`) dans le même fichier, ou dans `shared/widgets/` s'ils sont réutilisables.

## 4. Gestion des Exceptions
- Les requêtes réseau (`ApiClient`) ou les appels `Repository` lèveront des Exceptions.
- Le `ParentAppState` **doit** encapsuler ces appels dans des blocs `try-catch` et setter l'état `error` sur l'instance correspondante de `RequestState<T>`.
- Ne laissez pas d'exceptions non gérées remonter jusqu'à l'UI qui ferait crasher l'app (Red Screen of Death).

## 5. Immutilibité et Constructeurs Constants
- Utilisez des classes de modèles immuables avec des champs `final`.
- Créez des constructeurs `const` autant que possible pour les Widgets et les Modèles afin d'optimiser les performances de rendu.

## 6. Commentaires et Documentation
- Utilisez les docstrings `///` pour documenter les abstractions, les classes métiers, et tout algorithme non trivial (ex: logique de fractionnement de paiement).
- Évitez les commentaires évidents qui paraphrasent le code.
