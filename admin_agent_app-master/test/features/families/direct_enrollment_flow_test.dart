import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edupay_admin/core/router/route_paths.dart';
import 'package:edupay_admin/features/families/domain/models/family.dart';
import 'package:edupay_admin/features/families/presentation/screens/direct_enrollment_screen.dart';
import 'package:edupay_admin/features/families/presentation/screens/enrollment_success_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: '${RoutePaths.adminFamilies}/enroll',
    routes: [
      GoRoute(
        path: '${RoutePaths.adminFamilies}/enroll',
        builder: (context, state) => const DirectEnrollmentScreen(),
        routes: [
          GoRoute(
            path: 'success',
            builder: (context, state) => EnrollmentSuccessScreen(
              family: state.extra! as Family,
              onEnrollAnother: () =>
                  context.go('${RoutePaths.adminFamilies}/enroll'),
              onBackToDashboard: () => context.go(RoutePaths.adminDashboard),
            ),
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

/// Localise un champ par son texte d'exemple (`hintText`) plutôt que par
/// position (`.first`/`.last`) — le formulaire a maintenant plusieurs
/// `TextFormField` (famille + un par enfant), l'ordre n'est plus fiable.
Finder _fieldWithHint(String hint) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.hintText == hint,
);

Future<void> _tapSubmit(WidgetTester tester) async {
  final submit = find.text('Inscrire ce client');
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('inscrire un client mène à l\'écran de succès avec le récap', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.enterText(
      _fieldWithHint('Ouedraogo Marie'),
      'Ouedraogo Marie',
    );
    await tester.enterText(
      _fieldWithHint('+226 70 45 67 89'),
      '+226 70 45 67 89',
    );
    // La ville est un champ explicite et obligatoire (indépendant de tout
    // agent) — doit être choisie avant de pouvoir soumettre.
    final cityField = find.text('Choisissez une ville');
    await tester.ensureVisible(cityField);
    await tester.pumpAndSettle();
    await tester.tap(cityField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ouagadougou').last);
    await tester.pumpAndSettle();
    // Un kit est par enfant, lié à sa classe (§3.6 du contrat) : "Ajouter un
    // enfant" fait apparaître prénom/niveau/école, puis le kit une fois la
    // classe choisie (il se présélectionne automatiquement pour cette classe).
    final addChild = find.text('Ajouter un enfant');
    await tester.ensureVisible(addChild);
    await tester.pumpAndSettle();
    await tester.tap(addChild);
    await tester.pumpAndSettle();
    await tester.enterText(_fieldWithHint('Fatoumata'), 'Fatoumata');
    final levelField = find.text('Choisissez le niveau');
    await tester.ensureVisible(levelField);
    await tester.pumpAndSettle();
    await tester.tap(levelField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('CM2').last);
    await tester.pumpAndSettle();
    await _tapSubmit(tester);

    expect(find.byType(EnrollmentSuccessScreen), findsOneWidget);
    expect(find.text('Ouedraogo Marie'), findsOneWidget);
    expect(find.text('Actif ✓'), findsOneWidget);
  });

  testWidgets(
    'inscrire un client sans enfant fonctionne (objectif reste à 0)',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.enterText(
        _fieldWithHint('Ouedraogo Marie'),
        'Zongo Ibrahim',
      );
      await tester.enterText(
        _fieldWithHint('+226 70 45 67 89'),
        '+226 65 44 55 66',
      );
      final cityField = find.text('Choisissez une ville');
      await tester.ensureVisible(cityField);
      await tester.pumpAndSettle();
      await tester.tap(cityField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ouagadougou').last);
      await tester.pumpAndSettle();
      // Aucun enfant ajouté — doit rester possible (voir mémo du plan :
      // une famille peut exister sans enfant, sans objectif fantôme).
      await _tapSubmit(tester);

      expect(find.byType(EnrollmentSuccessScreen), findsOneWidget);
      expect(find.text('Zongo Ibrahim'), findsOneWidget);
    },
  );

  testWidgets('un champ vide bloque la soumission avec un message d\'erreur', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await _tapSubmit(tester);

    expect(find.text('Renseignez tous les champs requis'), findsOneWidget);
    expect(find.byType(DirectEnrollmentScreen), findsOneWidget);
  });
}
