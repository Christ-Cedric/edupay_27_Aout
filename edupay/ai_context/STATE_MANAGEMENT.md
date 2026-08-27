# State Management (Gestion des États)

EduPay gère l'état global et asynchrone principalement via un Provider basé sur `ChangeNotifier`.

## 1. Modèle Principal : `ParentAppState`
`features/parent/presentation/parent_app_state.dart` est le chef d'orchestre de la présentation. Il détient :
- L'état d'authentification (`AuthStatus authStatus`).
- L'état du profil, des enfants, et des plans d'épargne (modèles du domaine).
- Les `TextEditingController` des divers formulaires pour conserver l'état de saisie pendant la navigation (utile pour le flux d'Onboarding divisé en multiples écrans).

## 2. Abstraction Asynchrone : `RequestState<T>`
Une classe immuable custom `RequestState<T>` est utilisée pour encapsuler proprement les états de chargement liés à l'UI sans polluer le contrôleur de multiples booléens `isLoading`.
- `RequestState.idle()`
- `RequestState.loading({T? data})`
- `RequestState.success(T data)`
- `RequestState.error(Object error, {T? data})`

**Exemple d'utilisation :**
L'action de paiement met à jour la variable asynchrone `paymentState`.
L'UI peut ensuite lire `appState.paymentState.isLoading` pour afficher un Spinner sur le bouton de paiement.

## 3. Propagation à l'UI
Les pages consomment le `ParentAppState` de deux manières principales selon les conventions de `provider` :
- `context.watch<ParentAppState>()` pour écouter (et rebuild) aux changements (lorsque `notifyListeners()` est appelé).
- `context.read<ParentAppState>()` pour déclencher une action (ex: `onPressed: () => context.read<ParentAppState>().addChild()`) sans s'abonner aux changements.

## 4. Portée de l'État (Scoping)
Le `ParentAppState` est probablement injecté tout en haut de l'arbre des widgets (au niveau de `edupay_app.dart` ou `parent_scope.dart`), ce qui rend son état accessible de partout dans l'application, et vital pour le fonctionnement des Guards du `GoRouter`.
