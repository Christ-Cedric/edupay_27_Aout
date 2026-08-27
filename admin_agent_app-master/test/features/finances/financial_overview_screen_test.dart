import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/finances/data/finance_repository.dart';
import 'package:edupay_admin/features/finances/domain/models/finance_summary.dart';
import 'package:edupay_admin/features/finances/presentation/providers/finance_providers.dart';
import 'package:edupay_admin/features/finances/presentation/screens/financial_overview_screen.dart';

class _FakeFinanceRepository implements FinanceRepository {
  _FakeFinanceRepository(this.summary);
  final FinanceSummary summary;

  @override
  Future<FinanceSummary> getSummary() async => summary;
}

void main() {
  testWidgets('affiche le bilan financier du prototype', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: FinancialOverviewScreen())),
    );
    await tester.pumpAndSettle();
    // Le chargement de la saison (`FakeSeasonDataSource`) passe par un vrai
    // délai que `pumpAndSettle` ne rattrape pas toujours de façon fiable.
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('59 300 FCFA'), findsOneWidget);
    expect(find.textContaining('Koudougou (4 fam.)'), findsOneWidget);
    expect(find.textContaining('Journalier (2 fam.)'), findsOneWidget);

    // Montant exact (pas compact/arrondi) sur les lignes de répartition —
    // sinon impossible de vérifier qu'elles totalisent le montant global.
    expect(find.text('40 800 FCFA'), findsOneWidget);

    // Vraie saison (mock : "2025-2026"), pas une année codée en dur.
    expect(find.textContaining('SAISON 2025-2026'), findsOneWidget);
  });

  testWidgets(
    '"Voir plus" apparaît et déplie les villes au-delà de 3',
    (tester) async {
      const summary = FinanceSummary(
        totalCollected: 10000,
        activeFamilies: 4,
        byCity: [
          CityBreakdown(city: 'Koudougou', familyCount: 1, amount: 2500),
          CityBreakdown(city: 'Ouagadougou', familyCount: 1, amount: 2500),
          CityBreakdown(city: 'Bobo-Dioulasso', familyCount: 1, amount: 2500),
          CityBreakdown(city: 'Fada N\'Gourma', familyCount: 1, amount: 2500),
        ],
        byPlan: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            financeRepositoryProvider.overrideWithValue(
              _FakeFinanceRepository(summary),
            ),
          ],
          child: const MaterialApp(home: FinancialOverviewScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.textContaining('Koudougou'), findsOneWidget);
      expect(find.textContaining('Ouagadougou'), findsOneWidget);
      expect(find.textContaining('Bobo-Dioulasso'), findsOneWidget);
      expect(find.textContaining('Fada'), findsNothing);
      expect(find.text('Voir plus (1)'), findsOneWidget);

      await tester.tap(find.text('Voir plus (1)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Fada'), findsOneWidget);
      expect(find.text('Voir moins'), findsOneWidget);
    },
  );
}
