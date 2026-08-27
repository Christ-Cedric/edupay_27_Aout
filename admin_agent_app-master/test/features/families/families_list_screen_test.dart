import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edupay_admin/core/router/route_paths.dart';
import 'package:edupay_admin/features/families/presentation/screens/families_list_screen.dart';
import 'package:edupay_admin/features/families/presentation/screens/family_detail_screen.dart';
import 'package:edupay_admin/features/families/presentation/screens/pending_validation_list_screen.dart';

Widget _app() {
  // Reproduit le sous-arbre réel (voir app_router.dart) : FamiliesListScreen
  // construit ses navigations à partir de RoutePaths.adminFamilies, donc ce
  // routeur de test doit utiliser les mêmes chemins pour matcher.
  final router = GoRouter(
    initialLocation: RoutePaths.adminFamilies,
    routes: [
      GoRoute(
        path: RoutePaths.adminFamilies,
        builder: (context, state) => const FamiliesListScreen(),
        routes: [
          GoRoute(
            path: 'pending',
            builder: (context, state) => const PendingValidationListScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                FamilyDetailScreen(familyId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  testWidgets('affiche toutes les familles puis filtre par recherche', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Aminata Kabore'), findsOneWidget);
    expect(find.text('Bila Ouedraogo'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'aminata');
    await tester.pumpAndSettle();

    expect(find.text('Aminata Kabore'), findsOneWidget);
    expect(find.text('Bila Ouedraogo'), findsNothing);
  });

  testWidgets('ouvre le dossier famille au tap sur une ligne', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aminata Kabore'));
    await tester.pumpAndSettle();

    expect(find.byType(FamilyDetailScreen), findsOneWidget);
    expect(find.text('Dossier famille'), findsOneWidget);
    expect(find.textContaining('Hebdomadaire'), findsOneWidget);
  });

  testWidgets('la puce "En attente" ouvre l\'écran de validation dédié', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // "En attente" apparaît aussi comme badge de statut sur les familles
    // déjà en attente dans la liste ; on cible explicitement la puce de
    // filtre en haut de l'écran (première occurrence).
    await tester.tap(find.text('En attente').first);
    await tester.pumpAndSettle();

    expect(find.byType(PendingValidationListScreen), findsOneWidget);
  });
}
