import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edupay_admin/core/router/route_paths.dart';
import 'package:edupay_admin/features/deliveries/presentation/screens/deliveries_screen.dart';
import 'package:edupay_admin/features/finances/presentation/screens/financial_overview_screen.dart';
import 'package:edupay_admin/features/refunds/presentation/screens/refunds_screen.dart';
import 'package:edupay_admin/features/reports/presentation/screens/reports_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: RoutePaths.adminFinances,
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
          ),
          GoRoute(
            path: 'deliveries',
            builder: (context, state) => const DeliveriesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.adminDashboard,
        builder: (context, state) =>
            const Scaffold(body: Text('Dashboard placeholder')),
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  testWidgets(
    'le hub Finances mène à Rapports, Remboursements et Livraisons et permet de revenir',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      // Les liens du hub sont plus bas dans la liste que le viewport de
      // test par défaut (800×600) ; on défile pour les rendre visibles.
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rapports & exports'));
      await tester.pumpAndSettle();
      expect(find.byType(ReportsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(FinancialOverviewScreen), findsOneWidget);

      await tester.tap(find.text('Remboursements'));
      await tester.pumpAndSettle();
      expect(find.byType(RefundsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Suivi livraisons'));
      await tester.pumpAndSettle();
      expect(find.byType(DeliveriesScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(FinancialOverviewScreen), findsOneWidget);
    },
  );
}
