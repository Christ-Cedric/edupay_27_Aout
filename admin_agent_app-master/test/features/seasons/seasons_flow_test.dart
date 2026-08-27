import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:edupay_admin/features/seasons/presentation/screens/new_season_screen.dart';
import 'package:edupay_admin/features/seasons/presentation/screens/seasons_list_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: '/admin/settings/seasons',
    routes: [
      GoRoute(
        path: '/admin/settings/seasons',
        builder: (context, state) => const SeasonsListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const NewSeasonScreen(),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets('affiche les saisons seedées avec la courante marquée', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('2025-2026'), findsOneWidget);
    expect(find.text('2024-2025'), findsOneWidget);
    expect(find.text('Courante'), findsOneWidget);
  });

  testWidgets('créer une saison la fait apparaître dans la liste (pas courante)', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Créer une saison'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '2026-2027');
    await tester.enterText(find.byType(TextFormField).last, '500');
    await tester.tap(find.text('Créer la saison'));
    await tester.pumpAndSettle();

    expect(find.byType(SeasonsListScreen), findsOneWidget);
    expect(find.text('2026-2027'), findsOneWidget);
  });

  testWidgets(
    'basculer vers une saison non courante demande confirmation puis la marque courante',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('2024-2025'));
      await tester.pumpAndSettle();
      expect(find.text('Changer de saison'), findsOneWidget);

      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      // Une seule saison courante à la fois : le badge reste unique après
      // la bascule (plus sur "2025-2026", maintenant sur "2024-2025").
      expect(find.text('Courante'), findsOneWidget);

      // "2024-2025" est désormais courante : retaper dessus ne rouvre plus
      // la confirmation (AppCard.onTap devient nul pour la saison courante).
      await tester.tap(find.text('2024-2025'));
      await tester.pumpAndSettle();
      expect(find.text('Changer de saison'), findsNothing);
    },
  );
}
