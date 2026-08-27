import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/auth/presentation/providers/auth_providers.dart';
import 'package:edupay_admin/features/auth/presentation/screens/login_screen.dart';
import 'package:edupay_admin/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:edupay_admin/main.dart';

import '../../helpers/fake_session_auth_repository.dart';

void main() {
  testWidgets('des identifiants valides mènent du splash au dashboard admin', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeSessionAuthRepository()),
        ],
        child: const EduPayAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '+22676691911');
    await tester.enterText(find.byType(TextFormField).last, 'admin123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminDashboardScreen), findsOneWidget);
  });

  testWidgets(
    'un mot de passe invalide affiche une erreur et reste sur la connexion',
    (tester) async {
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
      await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Numéro ou mot de passe incorrect.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets('la bascule œil affiche/masque le mot de passe', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeSessionAuthRepository()),
        ],
        child: const EduPayAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });
}
