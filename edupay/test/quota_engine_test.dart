import 'package:edupay/features/parent/domain/parent_models.dart';
import 'package:edupay/features/parent/domain/quota_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyQuotaPayment', () {
    test('un paiement exact valide un seul quota, reliquat nul', () {
      final state = QuotaState(
        quotaValue: 2000,
        subscriptionStartDate: DateTime(2026, 1, 1),
        frequency: SavingsPlan.daily,
      );

      final result = applyQuotaPayment(state, 2000);

      expect(result.quotasValidatedNow, 1);
      expect(result.state.quotasAcquired, 1);
      expect(result.state.availableBalance, 0);
    });

    test('un paiement supérieur valide plusieurs quotas (§3)', () {
      final state = QuotaState(
        quotaValue: 2000,
        subscriptionStartDate: DateTime(2026, 1, 1),
        frequency: SavingsPlan.daily,
      );

      // 12000 F pour un quota de 2000 F => 6 quotas validés immédiatement.
      final result = applyQuotaPayment(state, 12000);

      expect(result.quotasValidatedNow, 6);
      expect(result.state.quotasAcquired, 6);
      expect(result.state.availableBalance, 0);
    });

    test('un paiement partiel ne valide rien et grossit le reliquat (§4)', () {
      final state = QuotaState(
        quotaValue: 2000,
        subscriptionStartDate: DateTime(2026, 1, 1),
        frequency: SavingsPlan.daily,
      );

      final result = applyQuotaPayment(state, 800);

      expect(result.quotasValidatedNow, 0);
      expect(result.state.quotasAcquired, 0);
      expect(result.state.availableBalance, 800);
    });

    test('le reliquat cumulé complète un quota dès qu\'il l\'atteint (§4)', () {
      final afterFirst = applyQuotaPayment(
        QuotaState(
          quotaValue: 2000,
          subscriptionStartDate: DateTime(2026, 1, 1),
          frequency: SavingsPlan.daily,
        ),
        800,
      ).state;

      final afterSecond = applyQuotaPayment(afterFirst, 1500);

      expect(afterSecond.quotasValidatedNow, 1);
      expect(afterSecond.state.quotasAcquired, 1);
      expect(afterSecond.state.availableBalance, 300);
    });

    test('aucun montant versé n\'est perdu (somme conservée à travers plusieurs paiements)', () {
      var state = QuotaState(
        quotaValue: 1300,
        subscriptionStartDate: DateTime(2026, 1, 1),
        frequency: SavingsPlan.daily,
      );
      const payments = [400, 700, 1250, 3000, 50];
      var totalPaid = 0;
      for (final amount in payments) {
        state = applyQuotaPayment(state, amount).state;
        totalPaid += amount;
      }

      expect(state.quotasAcquired * state.quotaValue + state.availableBalance, totalPaid);
    });
  });

  group('periodsElapsedSince', () {
    test('0 avant la première période complète', () {
      expect(
        periodsElapsedSince(DateTime(2026, 1, 1), DateTime(2026, 1, 1, 12), SavingsPlan.daily),
        0,
      );
    });

    test('journalier : un jour complet = 1 période', () {
      expect(
        periodsElapsedSince(DateTime(2026, 1, 1), DateTime(2026, 1, 3), SavingsPlan.daily),
        2,
      );
    });

    test('hebdomadaire : division entière par 7', () {
      expect(
        periodsElapsedSince(DateTime(2026, 1, 1), DateTime(2026, 1, 20), SavingsPlan.weekly),
        2, // 19 jours / 7 = 2 (arrondi au sol)
      );
    });
  });

  group('isInArrears', () {
    test('faux tant que les quotas validés couvrent les périodes écoulées', () {
      final state = QuotaState(
        quotaValue: 1000,
        subscriptionStartDate: DateTime(2026, 1, 1),
        frequency: SavingsPlan.daily,
        quotasAcquired: 10,
      );
      expect(isInArrears(state, now: DateTime(2026, 1, 5)), isFalse);
    });

    test('vrai dès que ≥ 3 périodes de retard se sont accumulées (§6)', () {
      final state = QuotaState(
        quotaValue: 1000,
        subscriptionStartDate: DateTime(2026, 1, 1),
        frequency: SavingsPlan.daily,
        quotasAcquired: 0,
      );
      // 4 jours écoulés, 0 quota validé => 4 périodes de retard >= 3.
      expect(isInArrears(state, now: DateTime(2026, 1, 5)), isTrue);
    });

    test('pas encore en retard à moins de 3 périodes d\'écart', () {
      final state = QuotaState(
        quotaValue: 1000,
        subscriptionStartDate: DateTime(2026, 1, 1),
        frequency: SavingsPlan.daily,
        quotasAcquired: 0,
      );
      // 2 jours écoulés, 0 quota validé => 2 périodes de retard < 3.
      expect(isInArrears(state, now: DateTime(2026, 1, 3)), isFalse);
    });
  });
}
