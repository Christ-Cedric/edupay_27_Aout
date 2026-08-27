import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:edupay_admin/features/auth/presentation/providers/auth_providers.dart';
import 'package:edupay_admin/main.dart';

import '../helpers/fake_session_auth_repository.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets(
    'les 4 onglets de la barre basse Admin naviguent vers leur écran',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              FakeSessionAuthRepository(),
            ),
          ],
          child: const EduPayAdminApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '+22676691911');
      await tester.enterText(find.byType(TextFormField).last, 'admin123');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Admin - EduP@y'), findsOneWidget);

      await tester.tap(find.text('Familles'));
      await tester.pumpAndSettle();
      expect(find.text('Toutes les familles'), findsOneWidget);

      await tester.tap(find.text('Finances'));
      await tester.pumpAndSettle();
      expect(find.textContaining('TOTAL COLLECTÉ'), findsOneWidget);

      await tester.tap(find.text('Params'));
      await tester.pumpAndSettle();
      expect(find.text('SAISON EN COURS'), findsOneWidget);

      // Revenir au premier onglet fonctionne toujours (pile par branche).
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Admin - EduP@y'), findsOneWidget);
    },
  );
}
