import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edupay_admin/core/router/route_paths.dart';
import 'package:edupay_admin/features/dashboard/data/dashboard_repository.dart';
import 'package:edupay_admin/features/dashboard/domain/models/dashboard_alert.dart';
import 'package:edupay_admin/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:edupay_admin/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edupay_admin/features/dashboard/presentation/screens/admin_dashboard_screen.dart';

/// Couvre toutes les alertes possibles (contrairement au mock, qui n'émet
/// jamais `pendingValidation`/`pendingDeliveries`) pour verrouiller le
/// routage de chaque carte du dashboard — la consigne "toutes les cards
/// sont cliquables" doit rester vraie quel que soit le contenu renvoyé par
/// le backend.
const _summary = DashboardSummary(
  season: '2026-2027',
  activeFamilies: 4,
  totalCollected: 0,
  collectionRate: 0,
  overduePayments: 2,
  activeAgents: 2,
  pendingDeliveries: 3,
  alerts: [
    DashboardAlert(
      title: 'Comptes à valider',
      subtitle: '2 famille(s) en attente de validation',
      severity: DashboardAlertSeverity.warning,
      kind: DashboardAlertKind.pendingValidation,
    ),
    DashboardAlert(
      title: 'Livraisons en attente',
      subtitle: '3 kit(s) à livrer',
      severity: DashboardAlertSeverity.info,
      kind: DashboardAlertKind.pendingDeliveries,
    ),
  ],
);

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> getSummary() async => _summary;
}

class _TargetScreen extends StatelessWidget {
  const _TargetScreen(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(label);
}

Widget _app() {
  final router = GoRouter(
    initialLocation: RoutePaths.adminDashboard,
    routes: [
      GoRoute(
        path: RoutePaths.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminFamilies,
        builder: (context, state) => const _TargetScreen('Familles'),
        routes: [
          GoRoute(
            path: 'pending',
            builder: (context, state) => const _TargetScreen('En attente'),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.adminFinances,
        builder: (context, state) => const _TargetScreen('Finances'),
        routes: [
          GoRoute(
            path: 'deliveries',
            builder: (context, state) => const _TargetScreen('Livraisons'),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.adminSettings,
        builder: (context, state) => const _TargetScreen('Paramètres'),
        routes: [
          GoRoute(
            path: 'agents',
            builder: (context, state) => const _TargetScreen('Agents'),
          ),
        ],
      ),
      GoRoute(
        path: '${RoutePaths.adminDashboard}/alerts',
        builder: (context, state) => const _TargetScreen('Alertes impayés'),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// La section alertes est plus bas dans la ListView (lazy) que ce que le
// viewport de test par défaut (800×600) construit sans défiler — même
// contournement que dans dashboard_alert_navigation_test.dart.
Future<void> _tapAndSettle(
  WidgetTester tester,
  Finder finder, {
  bool scrollToAlerts = false,
}) async {
  await tester.pumpWidget(_app());
  await tester.pumpAndSettle();
  if (scrollToAlerts) {
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
  } else {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la tuile Familles actives ouvre Familles', (tester) async {
    await _tapAndSettle(tester, find.text('Familles actives'));
    expect(find.text('Familles'), findsOneWidget);
  });

  testWidgets('la tuile Total collecté ouvre Finances', (tester) async {
    await _tapAndSettle(tester, find.text('Total collecté'));
    expect(find.text('Finances'), findsOneWidget);
  });

  testWidgets('la tuile Taux cotisation ouvre Finances', (tester) async {
    await _tapAndSettle(tester, find.text('Taux cotisation'));
    expect(find.text('Finances'), findsOneWidget);
  });

  testWidgets('la tuile Impayés ouvre les alertes impayés', (tester) async {
    await _tapAndSettle(tester, find.text('Impayés'));
    expect(find.text('Alertes impayés'), findsOneWidget);
  });

  testWidgets('la tuile Agents actifs ouvre Agents', (tester) async {
    await _tapAndSettle(tester, find.text('Agents actifs'));
    expect(find.text('Agents'), findsOneWidget);
  });

  testWidgets('la tuile Livraisons à faire ouvre Livraisons', (tester) async {
    await _tapAndSettle(tester, find.text('Livraisons à faire'));
    expect(find.text('Livraisons'), findsOneWidget);
  });

  testWidgets('la carte "Comptes à valider" ouvre la file d\'attente', (
    tester,
  ) async {
    await _tapAndSettle(
      tester,
      find.text('Comptes à valider'),
      scrollToAlerts: true,
    );
    expect(find.text('En attente'), findsOneWidget);
  });

  testWidgets('la carte "Livraisons en attente" ouvre Livraisons', (
    tester,
  ) async {
    await _tapAndSettle(
      tester,
      find.text('Livraisons en attente'),
      scrollToAlerts: true,
    );
    expect(find.text('Livraisons'), findsOneWidget);
  });

  testWidgets('le libellé de saison ouvre Paramètres', (tester) async {
    await _tapAndSettle(tester, find.textContaining('Saison'));
    expect(find.text('Paramètres'), findsOneWidget);
  });
}
