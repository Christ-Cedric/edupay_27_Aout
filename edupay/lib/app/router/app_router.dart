import 'package:go_router/go_router.dart';

import '../../features/parent/presentation/pages/auth_pages.dart';
import '../../features/parent/presentation/pages/children_pages.dart';
import '../../features/parent/presentation/pages/delivery_pages.dart';
import '../../features/parent/presentation/pages/goals_pages.dart';
import '../../features/parent/presentation/pages/home_pages.dart';
import '../../features/parent/presentation/pages/onboarding_pages.dart';
import '../../features/parent/presentation/pages/profile_pages.dart';
import '../../features/parent/presentation/pages/savings_pages.dart';
import '../../features/parent/presentation/pages/subscription_pages.dart';
import '../../features/parent/presentation/pages/contribution_type_selection_page.dart';
import '../../features/parent/presentation/parent_app_state.dart';
import '../../features/parent/presentation/parent_shell.dart';
import '../../features/parent/domain/parent_models.dart';
import '../../features/parent/presentation/pages/statistics_pages.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(ParentAppState appState) => GoRouter(
    initialLocation: '/welcome',
    refreshListenable: appState,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuth = location == '/welcome' || location.startsWith('/auth');
      final isOnboarding = location.startsWith('/onboarding');
      final isApp = location.startsWith('/app');
      return switch (appState.authStatus) {
        // Le statut n'est pas encore tranché (lecture du token persisté en
        // cours) : on reste sur l'écran courant (`/welcome` à froid) sans
        // flasher l'écran de connexion.
        AuthStatus.restoring => null,
        AuthStatus.unauthenticated => isAuth ? null : '/welcome',
        AuthStatus.onboarding => isOnboarding ? null : '/onboarding/profile',
        AuthStatus.pendingApproval =>
          location == '/auth/pending' ? null : '/auth/pending',
        AuthStatus.authenticated => isApp ? null : '/app/home',
      };
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/auth/phone', builder: (_, _) => const PhonePage()),
      GoRoute(path: '/auth/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/auth/otp', builder: (_, _) => const OtpPage()),
      GoRoute(
        path: '/auth/forgot/reset',
        builder: (_, _) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/auth/pending',
        builder: (_, _) => const AccountPendingPage(),
      ),
      // Onboarding is limited to account activation: profile then success.
      GoRoute(
        path: '/onboarding/profile',
        builder: (_, _) =>
            const ParentShell(title: 'Inscription', child: ProfileFormPage()),
      ),
      GoRoute(
        path: '/onboarding/success',
        builder: (_, _) => const RegistrationSuccessPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ParentShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/app/home', builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/savings',
                builder: (_, _) => const SavingsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/delivery',
                builder: (_, _) => const DeliveryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/profile',
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/app/contribute/type',
        builder: (_, _) => const ParentShell(
          title: 'Type de cotisation',
          child: ContributionTypeSelectionPage(),
        ),
      ),
      GoRoute(
        path: '/app/contribute',
        builder: (context, state) => ParentShell(
          title: 'Cotiser',
          child: ContributePage(
            targetGoalType: state.extra as SavingsGoalType?,
          ),
        ),
      ),
      GoRoute(
        path: '/app/payment-success',
        builder: (_, _) =>
            const ParentShell(showAppBar: false, child: PaymentSuccessPage()),
      ),
      GoRoute(
        path: '/app/notifications',
        builder: (_, _) => const ParentShell(
          title: 'Notifications',
          child: NotificationsPage(),
        ),
      ),
      GoRoute(
        path: '/app/history',
        builder: (_, _) =>
            const ParentShell(title: 'Historique', child: HistoryPage()),
      ),
      GoRoute(
        path: '/app/statistics',
        builder: (_, _) =>
            const ParentShell(title: 'Statistiques', child: StatisticsPage()),
      ),
      GoRoute(
        path: '/app/savings/:index',
        builder: (context, state) => ParentShell(
          title: 'Épargne',
          child: SavingsDetailPage(
            childIndex: int.parse(state.pathParameters['index']!),
          ),
        ),
      ),
      GoRoute(
        path: '/app/delivery/savings',
        builder: (_, _) =>
            const ParentShell(title: 'Épargne', child: SavingsOverviewPage()),
      ),
      GoRoute(
        path: '/app/delivery/registration',
        builder: (_, _) => const ParentShell(
          title: 'Inscription',
          child: RegistrationDetailPage(),
        ),
      ),
      GoRoute(
        path: '/app/delivery/order',
        builder: (_, _) =>
            const ParentShell(title: 'Commande', child: OrderDetailPage()),
      ),
      GoRoute(
        path: '/app/delivery/home',
        builder: (_, _) => const ParentShell(
          title: 'Livraison à domicile',
          child: ConfirmReceiptPage(),
        ),
      ),
      GoRoute(
        path: '/app/delivery/confirm-receipt',
        builder: (_, _) =>
            const ParentShell(title: 'Réception', child: ConfirmReceiptPage()),
      ),
      GoRoute(
        path: '/app/delivery/receipt-confirmed',
        builder: (_, _) =>
            const ParentShell(showAppBar: false, child: ReceiptConfirmedPage()),
      ),
      GoRoute(
        path: '/app/delivery/report-issue',
        builder: (_, _) =>
            const ParentShell(title: 'Signalement', child: ReportIssuePage()),
      ),
      GoRoute(
        path: '/app/delivery/report-issue/success',
        builder: (_, _) => const ParentShell(
          showAppBar: false,
          child: ReportIssueSuccessPage(),
        ),
      ),
      // « Nouvel objectif » : Choix des catégories de dépenses.
      GoRoute(
        path: '/app/goals',
        builder: (_, _) => const ParentShell(
          title: 'Nouvel objectif',
          child: GoalCategorySelectionPage(),
        ),
      ),
      GoRoute(
        path: '/app/goals/tuition',
        builder: (_, _) =>
            const ParentShell(title: 'Scolarité', child: TuitionGoalPage()),
      ),
      GoRoute(
        path: '/app/goals/transport',
        builder: (_, _) =>
            const ParentShell(title: 'Déplacement', child: TransportGoalPage()),
      ),
      // « Mes enfants » : point d'entrée de toute la souscription.
      GoRoute(
        path: '/app/children',
        builder: (_, _) =>
            const ParentShell(title: 'Enfants', child: ChildrenPage()),
      ),
      GoRoute(
        path: '/app/children/add',
        builder: (_, _) =>
            const ParentShell(title: 'Ajouter', child: AddChildPage()),
      ),
      // Étape 1 : un kit par enfant (choisi avant la fréquence, pour que le
      // parent connaisse le contenu/prix réel avant de s'engager sur un
      // rythme de cotisation).
      GoRoute(
        path: '/app/children/kits',
        builder: (_, _) =>
            const ParentShell(title: 'Kits', child: AssignKitsPage()),
      ),
      // Étape 2 : fréquence seule, aucun montant.
      GoRoute(
        path: '/app/plan',
        builder: (_, _) =>
            const ParentShell(title: 'Fréquence', child: PlanPage()),
      ),
      // Depuis le profil : modifier UNIQUEMENT la fréquence (pas de saut vers
      // le contrat).
      GoRoute(
        path: '/app/plan/edit',
        builder: (_, _) => const ParentShell(
          title: "Plan d'épargne",
          child: PlanPage(editOnly: true),
        ),
      ),
      GoRoute(
        path: '/app/children/kits/custom/:index',
        builder: (context, state) => ParentShell(
          title: 'Kit personnalisé',
          child: CustomKitPage(
            childIndex: int.parse(state.pathParameters['index']!),
          ),
        ),
      ),
      // Étape 4 : montants visibles + signature.
      GoRoute(
        path: '/app/contract',
        builder: (_, _) =>
            const ParentShell(title: 'Mon contrat', child: ContractPage()),
      ),
      GoRoute(
        path: '/app/plan-success',
        builder: (_, _) =>
            const ParentShell(showAppBar: false, child: PlanSuccessPage()),
      ),
      GoRoute(
        path: '/app/profile/edit',
        builder: (_, _) =>
            const ParentShell(title: 'Modifier', child: EditProfilePage()),
      ),
      GoRoute(
        path: '/app/settings',
        builder: (_, _) =>
            const ParentShell(title: 'Paramètres', child: SettingsPage()),
      ),
      GoRoute(
        path: '/app/settings/password',
        builder: (_, _) => const ParentShell(
          title: 'Mot de passe',
          child: ChangePasswordPage(),
        ),
      ),
      GoRoute(
        path: '/app/settings/devices',
        builder: (_, _) => const ParentShell(
          title: 'Appareils',
          child: ConnectedDevicesPage(),
        ),
      ),
      GoRoute(
        path: '/app/legal/:doc',
        builder: (context, state) => ParentShell(
          title: 'Document',
          child: LegalDocumentPage(doc: state.pathParameters['doc']!),
        ),
      ),
      GoRoute(
        path: '/app/preferences',
        builder: (_, _) =>
            const ParentShell(title: 'Préférences', child: PreferencesPage()),
      ),
      GoRoute(
        path: '/app/payment-methods',
        builder: (_, _) =>
            const ParentShell(title: 'Paiement', child: PaymentMethodsPage()),
      ),
      GoRoute(
        path: '/app/theme',
        builder: (_, _) =>
            const ParentShell(title: 'Thème', child: ThemePage()),
      ),
      GoRoute(
        path: '/app/about',
        builder: (_, _) =>
            const ParentShell(title: 'À propos', child: AboutPage()),
      ),
      GoRoute(
        path: '/app/refund',
        builder: (_, _) =>
            const ParentShell(title: 'Remboursement', child: RefundPage()),
      ),
      GoRoute(
        path: '/app/refund-success',
        builder: (_, _) =>
            const ParentShell(showAppBar: false, child: RefundSuccessPage()),
      ),
      GoRoute(
        path: '/app/contact',
        builder: (_, _) =>
            const ParentShell(title: 'Contact', child: ContactPage()),
      ),
    ],
  );
}
