# Arbre de Navigation (Routing)

La navigation est entièrement gérée par `GoRouter` (`app/router/app_router.dart`). 

## Logique de Redirection (Guard)
Une fonction `redirect` est évaluée à chaque changement de route.
- Si le statut d'authentification est `unauthenticated` et que la cible n'est pas `/welcome` ou `/auth/*`, redirection vers `/welcome`.
- Si le statut est `onboarding` et que la cible n'est pas `/onboarding/*`, redirection vers `/onboarding/profile`.
- Si le statut est `authenticated` et que la cible n'est pas dans `/app/*`, redirection vers `/app/home`.

## Structure des Routes

```text
/welcome (SplashPage)
│
├── /auth
│   ├── /auth/phone (PhonePage)
│   └── /auth/otp (OtpPage)
│
├── /onboarding (Géré par ParentShell avec titre dynamique)
│   ├── /onboarding/profile (ProfileFormPage)
│   └── /onboarding/success (RegistrationSuccessPage)
│
└── /app (Application Principale)
    ├── /app/home (HomePage) - Onglet 1 de la BottomNavigationBar
    ├── /app/savings (SavingsPage) - Onglet 2
    ├── /app/delivery (DeliveryPage) - Onglet 3
    ├── /app/profile (ProfilePage) - Onglet 4
    │
    ├── /app/contribute (ContributePage)
    ├── /app/payment-success (PaymentSuccessPage)
    ├── /app/notifications (NotificationsPage)
    ├── /app/history (HistoryPage)
    ├── /app/children (ChildrenPage)
    │   └── /app/children/add (AddChildPage)
    ├── /app/plan (PlanPage)
    ├── /app/contract (ContractPage)
    ├── /app/refund (RefundPage)
    ├── /app/refund-success (RefundSuccessPage)
    └── /app/contact (ContactPage)
```

## Transitions
Les transitions d'une étape d'onboarding à l'autre se font en général avec un bouton "Continuer" qui fait un `context.push()` vers la route suivante de l'arbre `/onboarding/...`. La fin de l'onboarding modifie le statut d'authentification ce qui déclenche la redirection globale vers `/app/home`.
