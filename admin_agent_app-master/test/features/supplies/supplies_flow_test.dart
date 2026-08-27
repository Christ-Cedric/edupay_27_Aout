import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edupay_admin/features/supplies/presentation/screens/new_supply_screen.dart';
import 'package:edupay_admin/features/supplies/presentation/screens/supplies_list_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: '/admin/settings/kits/supplies',
    routes: [
      GoRoute(
        path: '/admin/settings/kits/supplies',
        builder: (context, state) => const SuppliesListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const NewSupplyScreen(),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  testWidgets('affiche les fournitures seedées groupées par catégorie', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Cahiers & Écriture'), findsOneWidget);
    expect(find.text('Cahier 192 pages'), findsOneWidget);
    expect(find.text('Écriture'), findsOneWidget);
    expect(find.text('Géométrie'), findsOneWidget);
  });

  testWidgets('créer une fourniture la fait apparaître dans la liste', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Ajouter une fourniture'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Trousse');
    await tester.enterText(fields.at(1), 'Trousse simple');
    await tester.enterText(fields.at(2), 'unité');
    await tester.enterText(fields.at(3), '2000');
    await tester.tap(find.text('Créer la fourniture'));
    await tester.pumpAndSettle();

    expect(find.byType(SuppliesListScreen), findsOneWidget);
    expect(find.text('Trousse simple'), findsOneWidget);
  });
}
