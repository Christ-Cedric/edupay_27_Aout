import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/families/presentation/screens/pending_validation_list_screen.dart';

void main() {
  testWidgets('approuver un compte le retire de la file d\'attente', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PendingValidationListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ouedraogo Marie'), findsOneWidget);
    expect(find.text('Zongo Ibrahim'), findsOneWidget);

    await tester.tap(find.text('Approuver').first);
    await tester.pumpAndSettle();

    expect(find.text('Ouedraogo Marie'), findsNothing);
    expect(find.text('Zongo Ibrahim'), findsOneWidget);
  });

  testWidgets('rejeter un compte demande un motif puis le retire de la file', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PendingValidationListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rejeter').first);
    await tester.pumpAndSettle();

    // La confirmation est désactivée tant qu'aucun motif n'est saisi ? Non :
    // on saisit un motif puis on confirme.
    await tester.enterText(find.byType(TextField), 'Numéro invalide');
    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();

    expect(find.text('Ouedraogo Marie'), findsNothing);
  });
}
