import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edupay_admin/core/router/route_paths.dart';
import 'package:edupay_admin/features/alerts/presentation/screens/overdue_alerts_screen.dart';
import 'package:edupay_admin/features/dashboard/presentation/screens/admin_dashboard_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: RoutePaths.adminDashboard,
    routes: [
      GoRoute(
        path: RoutePaths.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'alerts',
            builder: (context, state) => const OverdueAlertsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.adminSettings,
        builder: (context, state) => const _FakeSettingsScreen(),
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

class _FakeSettingsScreen extends StatelessWidget {
  const _FakeSettingsScreen();

  @override
  Widget build(BuildContext context) => const Placeholder();
}

void main() {
  testWidgets(
    'l\'alerte impayés du dashboard ouvre l\'écran Alertes (motif go(\'ad_al\') du prototype)',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('5 familles - impayés +14 jours'));
      await tester.pumpAndSettle();

      expect(find.byType(OverdueAlertsScreen), findsOneWidget);
    },
  );

  testWidgets(
    'l\'alerte objectif saison ouvre les Paramètres (toutes les cartes du dashboard sont cliquables)',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Objectif 50 familles'));
      await tester.pumpAndSettle();

      expect(find.byType(_FakeSettingsScreen), findsOneWidget);
    },
  );
}
