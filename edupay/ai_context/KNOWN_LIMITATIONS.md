# Limitations Connues (Dette Technique & Risques)

## 1. Fat Controller / State Unique
Le `ParentAppState` centralise à la fois :
- L'état asynchrone (homeState, profileState...).
- Les données métier globales (profile, children...).
- Les contrôleurs UI (`TextEditingController`).
**Limitation** : Ce fichier est très gros (300+ lignes). Sa modification par plusieurs développeurs peut causer des conflits de fusion (merge conflicts). Si l'application grandit, il faudra scinder cet état (ex: `AuthAppState`, `ChildFormState`, `DashboardState`).

## 2. Optimistic UI Updates sans mécanisme de synchronisation robuste
Dans `ParentAppState.addChild()`, l'enfant est ajouté immédiatement à la liste en local avant que l'appel API ne soit terminé, afin que l'interface paraisse rapide. Si l'appel échoue, l'enfant est retiré silencieusement ou avec une erreur remontée.
**Limitation** : Si la connexion réseau est très instable, des données inconsistantes pourraient apparaître temporairement, et le rattrapage d'erreur n'inclut pas de "Retry Mechanism" automatisé.

## 3. Absence de persistance locale forte
L'application ne montre pas l'utilisation visible de base de données locale complexe (comme Isar, Hive ou SQLite). Toute donnée dépend du maintien en mémoire du `ParentAppState`.
**Limitation** : Un crash de l'OS qui kill l'application en arrière-plan réinitialisera l'onboarding si le token/statut n'est pas persisté (probablement fait via `SharedPreferences`, mais demande vérification rigoureuse).

## 4. Gestion des exceptions globale
La capture des erreurs se fait par un `try-catch` générique qui passe un `Object error` à l'état.
**Limitation** : Le formatage ou la traduction d'erreurs d'API spécifiques (ex: 400 Bad Request, 500 Server Error) en messages "User Friendly" risque de manquer de granularité.
