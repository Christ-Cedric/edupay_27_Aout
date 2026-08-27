import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:edupay_admin/core/domain/school_level.dart';
import 'package:edupay_admin/features/kits/domain/models/kit.dart';
import 'package:edupay_admin/features/kits/presentation/screens/edit_kit_screen.dart';
import 'package:edupay_admin/features/kits/presentation/screens/kit_variant_detail_screen.dart';
import 'package:edupay_admin/features/kits/presentation/screens/kits_catalog_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: '/admin/settings/kits',
    routes: [
      GoRoute(
        path: '/admin/settings/kits',
        builder: (context, state) => const KitsCatalogScreen(),
        routes: [
          GoRoute(
            path: 'variant/:level',
            builder: (context, state) => KitVariantDetailScreen(
              level: KitLevel.values.byName(state.pathParameters['level']!),
            ),
          ),
          GoRoute(
            path: ':kitId/edit',
            builder: (context, state) =>
                EditKitScreen(kitId: state.pathParameters['kitId']!),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets(
    'catalogue -> variant -> classe -> modifie le prix d\'un kit via ses articles',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      // 3 cartes de variant en haut du catalogue (contrat §3.6).
      expect(find.text('Kit Basique'), findsOneWidget);
      expect(find.text('Kit Essentiel'), findsOneWidget);
      expect(find.text('Kit Premium'), findsOneWidget);

      await tester.tap(find.text('Kit Basique'));
      await tester.pumpAndSettle();

      expect(find.byType(KitVariantDetailScreen), findsOneWidget);

      // Le kit basique de test cible CP1 (fake_kit_data_source) — choisir la
      // classe dans le sélecteur pour faire apparaître son contenu.
      await tester.tap(find.byType(DropdownButtonFormField<SchoolLevel>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CP1').last);
      await tester.pumpAndSettle();

      expect(find.text('4 articles'), findsOneWidget);

      await tester.tap(find.text('Modifier ✎'));
      await tester.pumpAndSettle();

      expect(find.byType(EditKitScreen), findsOneWidget);

      // Le prix n'est plus saisi directement : on modifie le prix unitaire
      // du premier article (ordre des champs par ligne : catégorie, article,
      // quantité, unité, prix unitaire), et le total recalculé s'affiche.
      final firstUnitPriceField = find.byType(TextField).at(4);
      await tester.enterText(firstUnitPriceField, '1000');
      await tester.pumpAndSettle();

      // Le formulaire (5 champs par article) dépasse largement la fenêtre —
      // le bouton n'est construit dans l'arbre qu'une fois défilé en vue.
      final save = find.text('Enregistrer les modifications');
      await tester.dragUntilVisible(
        save,
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      // Enregistrer ramène sur l'écran du variant (pas le catalogue racine),
      // qui affiche à nouveau le kit modifié avec le total recalculé.
      expect(find.byType(KitVariantDetailScreen), findsOneWidget);
      expect(find.textContaining('8 100 FCFA'), findsOneWidget);
    },
  );
}
