# Instructions pour l'IA (AI Instructions)

Si vous êtes une intelligence artificielle (Claude, GPT, Gemini, Cursor, etc.) mandatée pour travailler sur ce projet Flutter **EduPay**, voici vos instructions critiques pour ne rien casser et respecter les conventions.

## 1. NE JAMAIS CASSER LE FLUX DE ROUTAGE (GoRouter Guard)
La navigation (`app_router.dart`) s'appuie sur la propriété `authStatus` du `ParentAppState`. Ne modifiez pas la logique du `redirect` à la légère. Un mauvais garde de route (Guard) entraînera une boucle de redirection infinie ou des écrans bloqués en blanc. Assurez-vous que l'authentification gère toujours un passage propre par l'enum `AuthStatus`.

## 2. RÈGLE D'ARCHITECTURE STRICTE
Respectez la Clean Architecture par fonctionnalité :
- Ne mettez **JAMAIS** de code appelant l'API HTTP directement dans un Widget.
- Les requêtes HTTP se font **EXCLUSIVEMENT** dans le dossier `data/services/` (ex: `parent_api_service.dart`).
- La conversion JSON -> Objet Métier se fait dans `data/repositories/`.
- Les widgets parlent uniquement à l'état (ex: `ParentAppState`) qui lui-même parle aux cas d'usage (`UseCases`).

## 3. GESTION DES ERREURS DANS L'UI
Ne laissez pas les requêtes sans fallback visuel.
L'application utilise un modèle générique `RequestState<T>`.
Si vous ajoutez une fonctionnalité nécessitant un appel API :
1. Déclarez un nouveau `RequestState` dans `ParentAppState` (ex: `RequestState<void> myNewFeatureState = const RequestState.idle();`).
2. Passez-le à `loading()` au début de la méthode (N'oubliez pas `notifyListeners()`).
3. Appelez le UseCase dans un `try/catch`.
4. En cas de succès, passez à `success()`.
5. En cas d'erreur, passez l'exception dans `error(e)` et assurez-vous que l'interface affiche l'erreur à l'utilisateur (via un Snackbar ou un label rouge `AppColors.danger`).

## 4. AJOUT OU MODIFICATION DE MODÈLES JSON
Le projet utilise `snake_case` côté JSON et `camelCase` côté Dart. Ne cassez pas ce pont dans les méthodes `.fromJson()` et `.toJson()`. Vérifiez toujours si les clés renvoyées par le backend correspondent à celles codées.

## 5. DESIGN & THEME
- N'utilisez pas de couleurs en "dur" (ex: `Colors.red`). Utilisez **systématiquement** les couleurs de `AppColors` (ex: `AppColors.danger`).
- Gardez les widgets simples, et si vous devez faire une mise en page complexe, déléguez les petits morceaux de code en widgets séparés.

## Comment ajouter une nouvelle page ?
1. Créez le fichier de la page dans `presentation/pages/`.
2. Ajoutez la route dans `app_router.dart`. Attention, si elle doit être dans le Bottom Nav, ajoutez-la au `StatefulShellRoute`.
3. Ajoutez l'action correspondante dans `ParentAppState` avec la gestion de statut asynchrone si nécessaire.
