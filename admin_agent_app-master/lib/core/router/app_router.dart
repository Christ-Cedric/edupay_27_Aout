import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dev/widget_gallery_screen.dart';
import '../domain/school_level.dart';
import '../widgets/maintenance_screen.dart';
import '../widgets/session_expired_screen.dart';
import '../widgets/update_required_screen.dart';
import '../../features/agents/presentation/screens/agent_detail_screen.dart';
import '../../features/agents/presentation/screens/agents_list_screen.dart';
import '../../features/agents/presentation/screens/new_agent_screen.dart';
import '../../features/alerts/presentation/screens/overdue_alerts_screen.dart';
import '../../features/audit/presentation/screens/audit_log_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/account_settings_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/deliveries/presentation/screens/deliveries_screen.dart';
import '../../features/families/domain/models/family.dart';
import '../../features/families/presentation/screens/direct_enrollment_screen.dart';
import '../../features/families/presentation/screens/enrollment_success_screen.dart';
import '../../features/families/presentation/screens/families_list_screen.dart';
import '../../features/families/presentation/screens/add_child_screen.dart';
import '../../features/families/presentation/screens/family_children_screen.dart';
import '../../features/families/presentation/screens/family_contract_screen.dart';
import '../../features/families/presentation/screens/family_detail_screen.dart';
import '../../features/families/presentation/screens/record_contribution_screen.dart';
import '../../features/families/presentation/screens/pending_validation_list_screen.dart';
import '../../features/finances/presentation/screens/financial_overview_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/kits/domain/models/kit.dart';
import '../../features/kits/presentation/screens/edit_kit_screen.dart';
import '../../features/kits/presentation/screens/kit_stats_screen.dart';
import '../../features/kits/presentation/screens/kit_variant_detail_screen.dart';
import '../../features/kits/presentation/screens/kits_catalog_screen.dart';
import '../../features/kits/presentation/screens/new_kit_screen.dart';
import '../../features/refunds/presentation/screens/refund_detail_screen.dart';
import '../../features/refunds/presentation/screens/refunds_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/seasons/presentation/screens/new_season_screen.dart';
import '../../features/seasons/presentation/screens/seasons_list_screen.dart';
import '../../features/settings/presentation/screens/season_settings_screen.dart';
import '../../features/supplies/presentation/screens/edit_supply_screen.dart';
import '../../features/supplies/presentation/screens/new_supply_screen.dart';
import '../../features/supplies/presentation/screens/supplies_list_screen.dart';
import '../../shell/admin_shell.dart';
import 'auth_guard.dart';
import 'route_paths.dart';

part 'app_router.g.dart';

/// Reconstruit le routeur à chaque changement de [SessionController] pour
/// que `redirect` soit ré-évalué (GoRouter n'écoute pas Riverpod nativement).
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(sessionControllerProvider, (_, _) => notifyListeners());
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => authGuardRedirect(
      sessionState: ref.read(sessionControllerProvider),
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.adminDashboard,
                builder: (context, state) => const AdminDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'alerts',
                    builder: (context, state) => const OverdueAlertsScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.adminFamilies,
                builder: (context, state) => const FamiliesListScreen(),
                routes: [
                  GoRoute(
                    path: 'enroll',
                    builder: (context, state) => const DirectEnrollmentScreen(),
                    routes: [
                      GoRoute(
                        path: 'success',
                        builder: (context, state) => EnrollmentSuccessScreen(
                          family: state.extra! as Family,
                          onEnrollAnother: () =>
                              context.go('${RoutePaths.adminFamilies}/enroll'),
                          onBackToDashboard: () =>
                              context.go(RoutePaths.adminDashboard),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'pending',
                    builder: (context, state) =>
                        const PendingValidationListScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => FamilyDetailScreen(
                      familyId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'contract',
                        builder: (context, state) => FamilyContractScreen(
                          familyId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'record-contribution',
                        builder: (context, state) => RecordContributionScreen(
                          familyId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'children',
                        builder: (context, state) => FamilyChildrenScreen(
                          familyId: state.pathParameters['id']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'new',
                            builder: (context, state) => AddChildScreen(
                              familyId: state.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.adminFinances,
                builder: (context, state) => const FinancialOverviewScreen(),
                routes: [
                  GoRoute(
                    path: 'reports',
                    builder: (context, state) => const ReportsScreen(),
                  ),
                  GoRoute(
                    path: 'refunds',
                    builder: (context, state) => const RefundsScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => RefundDetailScreen(
                          refundId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'deliveries',
                    builder: (context, state) => const DeliveriesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.adminSettings,
                builder: (context, state) => const SeasonSettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'audit-logs',
                    builder: (context, state) => const AuditLogScreen(),
                  ),
                  GoRoute(
                    path: 'account',
                    builder: (context, state) => const AccountSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'agents',
                    builder: (context, state) => const AgentsListScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) => const NewAgentScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => AgentDetailScreen(
                          agentId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'seasons',
                    builder: (context, state) => const SeasonsListScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) => const NewSeasonScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'kits',
                    builder: (context, state) => const KitsCatalogScreen(),
                    routes: [
                      GoRoute(
                        path: 'stats',
                        builder: (context, state) => const KitStatsScreen(),
                      ),
                      GoRoute(
                        path: 'new',
                        builder: (context, state) {
                          final preset =
                              state.extra as ({KitLevel level, SchoolLevel schoolLevel})?;
                          return NewKitScreen(
                            initialLevel: preset?.level,
                            initialSchoolLevel: preset?.schoolLevel,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'variant/:level',
                        builder: (context, state) => KitVariantDetailScreen(
                          level: KitLevel.values.byName(
                            state.pathParameters['level']!,
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'supplies',
                        builder: (context, state) => const SuppliesListScreen(),
                        routes: [
                          GoRoute(
                            path: 'new',
                            builder: (context, state) => const NewSupplyScreen(),
                          ),
                          GoRoute(
                            path: ':id/edit',
                            builder: (context, state) => EditSupplyScreen(
                              supplyId: state.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: ':kitId/edit',
                        builder: (context, state) => EditKitScreen(
                          kitId: state.pathParameters['kitId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      if (kDebugMode) ...[
        GoRoute(
          path: RoutePaths.devWidgetGallery,
          builder: (context, state) => const WidgetGalleryScreen(),
        ),
        GoRoute(
          path: RoutePaths.sessionExpired,
          builder: (context, state) => SessionExpiredScreen(
            onReconnect: () => context.go(RoutePaths.login),
          ),
        ),
        GoRoute(
          path: RoutePaths.devMaintenance,
          builder: (context, state) =>
              MaintenanceScreen(onContactSupport: () => context.pop()),
        ),
        GoRoute(
          path: RoutePaths.devUpdateRequired,
          builder: (context, state) => UpdateRequiredScreen(
            onUpdate: () => context.pop(),
            onLater: () => context.pop(),
          ),
        ),
      ],
    ],
  );
}
