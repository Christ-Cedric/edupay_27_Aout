import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/auth/presentation/providers/auth_providers.dart';
import 'package:edupay_admin/main.dart';

import 'helpers/fake_session_auth_repository.dart';

void main() {
  testWidgets('EduPayAdminApp démarre et atteint l\'écran de connexion', (
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

    expect(find.text('Se connecter'), findsOneWidget);
  });
}
