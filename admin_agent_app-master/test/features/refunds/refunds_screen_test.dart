import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edupay_admin/core/router/route_paths.dart';
import 'package:edupay_admin/features/refunds/presentation/screens/refunds_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: RoutePaths.adminFinances,
    routes: [
      GoRoute(
        path: RoutePaths.adminFinances,
        builder: (context, state) => const RefundsScreen(),
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
  testWidgets('approuver une demande la retire de la liste en attente', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Aminata Kabore'), findsOneWidget);
    expect(find.text('EN ATTENTE (1)'), findsOneWidget);

    await tester.tap(find.text('Approuver'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard placeholder'), findsOneWidget);
  });
}
