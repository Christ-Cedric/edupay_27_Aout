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

  group('Règles de calcul par catégorie', () {
    final refDate = DateTime(2026, 8, 15); // 31 jours avant le 15 septembre 2026

    test('Fournitures : montant total divisé par jours restants avant le 15 septembre', () {
      final child = _child(name: 'Awa', kit: SchoolKit.basic); // 12 000 FCFA
      final cat = computeCategorySavings(
        children: [child],
        category: SavingsGoalType.supplies,
        now: refDate,
      );

      expect(cat.targetAmount, 12000);
      expect(cat.daysRemaining, 31);
      expect(cat.deadline, DateTime(2026, 9, 15));
      // 12000 / 31 = 387.09 -> 388 F / jour
      expect(cat.dailyAmount, 388);
    });

    test('Scolarité : date fixée au 15 septembre', () {
      const child = ChildProfile(
        firstName: 'Boris',
        level: 'CM2',
        school: 'Centre',
        tuitionAmount: 62000,
        savedAmount: 0,
      );
      final cat = computeCategorySavings(
        children: [child],
        category: SavingsGoalType.registration,
        now: refDate,
      );

      expect(cat.targetAmount, 62000);
      expect(cat.deadline, DateTime(2026, 9, 15));
      expect(cat.daysRemaining, 31);
      // 62000 / 31 = 2000 F / jour
      expect(cat.dailyAmount, 2000);
    });

    test('Moyen de déplacement : date personnalisée et montant quotidien sur durée restante', () {
      final customDeadline = DateTime(2026, 9, 4); // 20 jours après le 15 août
      final child = ChildProfile(
        firstName: 'Fatou',
        level: 'CM2',
        school: 'Centre',
        transportAmount: 30000,
        transportSavedAmount: 10000, // Reste 20 000
        transportDeadline: customDeadline,
        savedAmount: 10000,
      );

      final cat = computeCategorySavings(
        children: [child],
        category: SavingsGoalType.transport,
        now: refDate,
      );

      expect(cat.targetAmount, 30000);
      expect(cat.savedAmount, 10000);
      expect(cat.remainingAmount, 20000);
      expect(cat.deadline, customDeadline);
      expect(cat.daysRemaining, 20);
      // 20 000 / 20 = 1000 F / jour
      expect(cat.dailyAmount, 1000);
    });

    test('Ajout nouvel objectif même catégorie : Nouveau total = Reste ancien + Montant nouvel objectif', () {
      // Ancien objectif : 50 000 FCFA, Déjà cotisé : 20 000 FCFA => Reste = 30 000 FCFA
      // Nouvel objectif ajouté : 15 000 FCFA
      final newTotal = calculateCumulativeGoalTotal(
        oldTargetAmount: 50000,
        oldSavedAmount: 20000,
        newGoalAmount: 15000,
      );
      expect(newTotal, 30000 + 15000); // 45 000 FCFA

      // Recalcul sur 30 jours restants
      final newContribution = calculateNewContribution(
        newTotalToFinance: newTotal,
        daysRemaining: 30,
      );
      // 45 000 / 30 = 1500 F / jour
      expect(newContribution, 1500);
    });
  });
}
