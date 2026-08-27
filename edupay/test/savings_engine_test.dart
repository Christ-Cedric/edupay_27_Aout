import 'package:edupay/features/parent/domain/parent_models.dart';
import 'package:edupay/features/parent/domain/savings_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_catalogue.dart';

ChildProfile _child({
  required String name,
  required SchoolKit kit,
  int saved = 0,
}) =>
    ChildProfile(
      firstName: name,
      level: 'CM2',
      school: 'Centre',
      kitSelection: ChildKitSelection.standard(kit),
      savedAmount: saved,
    );

void main() {
  setUpAll(loadFakeCatalogue);

  // Date de référence fixe pour des calculs déterministes.
  final now = DateTime(2026, 8, 15); // 31 jours avant la date limite.

  group('computeSavingsPlan', () {
    test('aucun enfant : tout à zéro, rien à cotiser', () {
      final plan = computeSavingsPlan(
        children: const [],
        frequency: SavingsPlan.daily,
        now: now,
      );
      expect(plan.hasChildren, isFalse);
      expect(plan.totalGoal, 0);
      expect(plan.globalRemaining, 0);
      expect(plan.perPeriodAmount, 0);
      expect(plan.goalReached, isFalse);
      expect(plan.expired, isFalse);
    });

    test('reste global = somme des restes dus par enfant', () {
      final plan = computeSavingsPlan(
        children: [
          _child(name: 'Awa', kit: SchoolKit.basic, saved: 2000), // 12000 - 2000
          _child(name: 'Boris', kit: SchoolKit.comfort, saved: 500), // 18500 - 500
        ],
        frequency: SavingsPlan.monthly,
        now: now,
      );
      expect(plan.totalGoal, 12000 + 18500);
      expect(plan.globalRemaining, 10000 + 18000);
    });

    test('répartit le reste global sur le temps restant (journalier)', () {
      final plan = computeSavingsPlan(
        children: [_child(name: 'Awa', kit: SchoolKit.basic)], // reste 12000
        frequency: SavingsPlan.daily,
        now: now, // 31 jours
      );
      expect(plan.periodsRemaining, 31);
      expect(plan.perPeriodAmount, (12000 / 31).ceil()); // = 388
    });

    test('objectif atteint : plus rien à cotiser', () {
      final plan = computeSavingsPlan(
        children: [_child(name: 'Awa', kit: SchoolKit.basic, saved: 12000)],
        frequency: SavingsPlan.weekly,
        now: now,
      );
      expect(plan.globalRemaining, 0);
      expect(plan.goalReached, isTrue);
      expect(plan.perPeriodAmount, 0);
      expect(plan.progressPercent, 100);
    });

    test('période expirée : la totalité du reste est due immédiatement', () {
      final plan = computeSavingsPlan(
        children: [_child(name: 'Awa', kit: SchoolKit.basic, saved: 5000)],
        frequency: SavingsPlan.daily,
        now: DateTime(2026, 9, 20), // après la date limite
      );
      expect(plan.expired, isTrue);
      expect(plan.periodsRemaining, 0);
      expect(plan.perPeriodAmount, 7000); // reste dû en un seul versement
    });

    test('sur-épargne bornée : pas de reste négatif', () {
      final plan = computeSavingsPlan(
        children: [_child(name: 'Awa', kit: SchoolKit.basic, saved: 20000)],
        frequency: SavingsPlan.daily,
        now: now,
      );
      expect(plan.globalRemaining, 0);
      expect(plan.totalSaved, 12000); // borné à l'objectif
      expect(plan.goalReached, isTrue);
    });

    test('ajout tardif : la cotisation par période augmente sur le temps restant',
        () {
      final before = computeSavingsPlan(
        children: [_child(name: 'Awa', kit: SchoolKit.basic)],
        frequency: SavingsPlan.daily,
        now: now,
      );
      final after = computeSavingsPlan(
        children: [
          _child(name: 'Awa', kit: SchoolKit.basic),
          _child(name: 'Boris', kit: SchoolKit.comfort), // ajouté tardivement
        ],
        frequency: SavingsPlan.daily,
        now: now,
      );
      // Même échéance, mais reste global plus élevé => cotisation plus élevée.
      expect(after.periodsRemaining, before.periodsRemaining);
      expect(after.globalRemaining, greaterThan(before.globalRemaining));
      expect(after.perPeriodAmount, greaterThan(before.perPeriodAmount));
    });

    test('somme des objectifs : fournitures + scolarité + moyen de déplacement', () {
      final child = const ChildProfile(
        firstName: 'Fatou',
        level: 'CM2',
        school: 'Centre',
        kitSelection: ChildKitSelection.standard(SchoolKit.basic), // 12 000
        tuitionAmount: 50000,
        transportAmount: 30000,
        transportType: 'Vélo',
        savedAmount: 12000,
      );

      final plan = computeSavingsPlan(
        children: [child],
        frequency: SavingsPlan.daily,
        now: now, // 31 jours
      );

      // Total : 12 000 (kit) + 50 000 (scolarité) + 30 000 (vélo) = 92 000 F
      expect(plan.totalGoal, 92000);
      expect(plan.totalSaved, 12000);
      expect(plan.globalRemaining, 80000);
      // 80 000 / 31 = 2580.64 -> 2581 F / jour
      expect(plan.perPeriodAmount, 2581);
    });
  });

  group('allocateContribution', () {
    test('répartit au prorata du reste dû', () {
      // Restes : 10000 et 30000 (total 40000). Paiement 4000 => 1000 / 3000.
      final shares = allocateContribution(
        remainingByChild: [10000, 30000],
        amount: 4000,
      );
      expect(shares, [1000, 3000]);
      expect(shares.fold(0, (a, b) => a + b), 4000);
    });

    test('paiement supérieur au reste : excédent non alloué', () {
      final shares = allocateContribution(
        remainingByChild: [2000, 3000],
        amount: 10000, // > 5000
      );
      expect(shares, [2000, 3000]); // chacun plafonné à son reste
      expect(shares.fold(0, (a, b) => a + b), 5000);
    });

    test('enfant déjà soldé ignoré', () {
      final shares = allocateContribution(
        remainingByChild: [0, 5000],
        amount: 2000,
      );
      expect(shares, [0, 2000]);
    });

    test('aucun reste : parts nulles', () {
      final shares = allocateContribution(
        remainingByChild: [0, 0],
        amount: 3000,
      );
      expect(shares, [0, 0]);
    });

    test('l’arrondi est absorbé par le dernier enfant dû (somme exacte)', () {
      // 3 enfants à reste égal, paiement 1000 : 333 + 333 + reste.
      final shares = allocateContribution(
        remainingByChild: [1000, 1000, 1000],
        amount: 1000,
      );
      expect(shares.fold(0, (a, b) => a + b), 1000);
    });
  });
}
