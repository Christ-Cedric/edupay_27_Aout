# Frontend Context

## Pages & Écrans (`features/parent/presentation/pages/`)
L'application est divisée en plusieurs phases distinctes d'expérience utilisateur :

### Phase 1 : Authentification (`auth_pages.dart`)
- **SplashPage** : Écran d'attente (chargement initial).
- **PhonePage** : Saisie du numéro de téléphone.
- **OtpPage** : Vérification du code OTP (4 chiffres).

### Phase 2 : Onboarding (`onboarding_pages.dart`)
L'onboarding est strictement limité à la création de compte.
- **ProfileFormPage** : Récupère les informations personnelles du parent (Nom, Prénom, Sexe, Adresse).
- **RegistrationSuccessPage** : Fin de l'onboarding, le compte est créé et redirige vers l'application principale.

### Fonctionnalités Métier dans l'App Principale
La gestion des enfants (ajout, modification), le choix des plans, et la sélection des kits sont désormais des écrans appartenant à l'application principale (Phase 3), accessibles depuis "Mes enfants".

### Phase 3 : Main App (`home_pages.dart` et `parent_shell.dart`)
Le cœur de l'application utilise une `StatefulShellRoute` (Bottom Navigation Bar) gérée par `ParentShell`.
- **HomePage** : Tableau de bord affichant la progression globale, les enfants et les dernières cotisations.
- **SavingsPage**, **DeliveryPage**, **ProfilePage** : Autres onglets principaux.
- **ContributePage** : Pour effectuer un paiement direct.
- **PaymentSuccessPage**, **HistoryPage**, **NotificationsPage**, **RefundPage**, **ContactPage** : Écrans secondaires accessibles depuis le menu ou l'historique.

## Widgets Partagés (`shared/widgets/`)
- `action_button.dart` : Boutons principaux.
- `app_card.dart` : Conteneurs de style carte.
- `edupay_logo.dart` : Logo de l'application.

## Navigation (`app_router.dart`)
L'arbre complet est orchestré par `GoRouter`. La garde de navigation (`redirect`) scrute `ParentAppState.authStatus` (unauthenticated, onboarding, authenticated) et force la redirection.

## State Management UI
- `ParentAppState` (ChangeNotifier) centralise tous les TextEditingController (`phoneController`, `nameController`, etc.).
- Les requêtes réseau sont enveloppées dans la classe générique `RequestState<T>` (idle, loading, success, error) pour contrôler facilement les loaders dans l'interface sans multiplier les variables booléennes (ex: `homeState.isLoading`).

## Design System
- Un design moderne et responsive, probablement configuré via `app/theme/` (fonds sombres, couleurs vives type vert "success"). Couleurs définies de manière stricte dans `AppColors`.
