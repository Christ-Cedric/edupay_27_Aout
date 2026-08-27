import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/families/data/fake_family_data_source.dart';
import 'package:edupay_admin/features/families/domain/models/family.dart';
import 'package:edupay_admin/features/families/domain/models/family_failure.dart';
import 'package:edupay_admin/features/families/domain/models/family_filter.dart';
import 'package:edupay_admin/features/families/domain/models/family_status.dart';
import 'package:edupay_admin/features/families/domain/models/savings_plan.dart';

void main() {
  late FakeFamilyDataSource dataSource;

  setUp(() => dataSource = FakeFamilyDataSource());

  test('fetchAll sans filtre renvoie toutes les familles seedées', () async {
    final families = await dataSource.fetchAll(const FamilyFilter());
    expect(families, hasLength(6));
  });

  test('fetchAll filtre par recherche insensible à la casse', () async {
    final families = await dataSource.fetchAll(
      const FamilyFilter(query: 'aminata'),
    );
    expect(families, hasLength(1));
    expect(families.single.fullName, 'Aminata Kabore');
  });

  test('fetchAll filtre par statut', () async {
    final pending = await dataSource.fetchAll(
      const FamilyFilter(status: FamilyStatus.pendingValidation),
    );
    expect(pending, hasLength(2));
    expect(
      pending.every((f) => f.status == FamilyStatus.pendingValidation),
      isTrue,
    );
  });

  test(
    'enroll ajoute une famille active immédiatement (inscription admin)',
    () async {
      final family = await dataSource.enroll(
        fullName: 'Test Testeur',
        phone: '+226 00 00 00 00',
        plan: SavingsPlan.monthly,
        children: const [
          (firstName: 'Fatoumata', level: 'CM2', school: null, kitId: 'kit-premium'),
        ],
        assignedAgentName: 'Konate Ali',
        city: 'Koudougou',
      );

      expect(family.status, FamilyStatus.active);
      final all = await dataSource.fetchAll(const FamilyFilter());
      expect(all, hasLength(7));
    },
  );

  test(
    'enroll avec plusieurs enfants agrège leurs kits dans l\'objectif famille (§7 #2 du contrat)',
    () async {
      final family = await dataSource.enroll(
        fullName: 'Familly Multi',
        phone: '+226 00 00 00 01',
        plan: SavingsPlan.weekly,
        children: const [
          (firstName: 'Aïcha', level: null, school: null, kitId: 'kit-basic'),
          (firstName: 'Boubacar', level: null, school: null, kitId: 'kit-premium'),
        ],
        assignedAgentName: 'Konate Ali',
        city: 'Koudougou',
      );

      expect(family.childrenCount, 2);
      expect(family.children.map((c) => c.firstName), ['Aïcha', 'Boubacar']);
      expect(family.targetAmount, 12000 + 27000);
    },
  );

  test('approve fait passer une famille en attente à active', () async {
    await dataSource.approve('fam-5');
    final family = await dataSource.fetchById('fam-5');
    expect(family.status, FamilyStatus.active);
  });

  test(
    'reject fait passer une famille en attente à rejetée avec motif',
    () async {
      await dataSource.reject('fam-6', 'Numéro invalide');
      final family = await dataSource.fetchById('fam-6');
      expect(family.status, FamilyStatus.rejected);
      expect(family.rejectionReason, 'Numéro invalide');
    },
  );

  test('fetchAll filtre par agent assigné (module Agent terrain)', () async {
    final families = await dataSource.fetchAll(
      const FamilyFilter(assignedAgentName: 'Konate Ali'),
    );
    expect(families, hasLength(3));
    expect(families.every((f) => f.assignedAgentName == 'Konate Ali'), isTrue);
  });

  test(
    'recordCashContribution refuse un encaissement sur un compte en attente de validation',
    () async {
      // fam-5 est seedée `pendingValidation` (voir fetchAll filtre par statut).
      expect(
        () => dataSource.recordCashContribution(familyId: 'fam-5', amount: 1000),
        throwsA(isA<FamilyFailure>()),
      );
    },
  );

  test(
    'recordCashContribution refuse un encaissement sur un compte rejeté',
    () async {
      await dataSource.reject('fam-6', 'Numéro invalide');
      expect(
        () => dataSource.recordCashContribution(familyId: 'fam-6', amount: 1000),
        throwsA(isA<FamilyFailure>()),
      );
    },
  );

  test(
    'recordCashContribution reste possible sur un compte actif',
    () async {
      final before = await dataSource.fetchById('fam-1');
      final updated = await dataSource.recordCashContribution(
        familyId: 'fam-1',
        amount: 1000,
      );
      expect(updated.balance, before.balance + 1000);
    },
  );

  test('addChild ajoute un enfant sans kit (état normal en début de saison)', () async {
    final family = await dataSource.addChild(
      familyId: 'fam-1',
      firstName: 'Nouvel Enfant',
      level: 'CP',
    );
    final added = family.children.firstWhere((c) => c.firstName == 'Nouvel Enfant');
    expect(added.hasKitThisSeason, isFalse);
    expect(added.kitId, isNull);
  });

  test('updateChild modifie la classe d\'un enfant existant', () async {
    final before = await dataSource.fetchById('fam-1');
    final childId = before.children.first.id;

    final family = await dataSource.updateChild(
      familyId: 'fam-1',
      childId: childId,
      level: '6ème',
    );

    expect(family.children.first.level, '6ème');
  });

  test('removeChild refuse de retirer un enfant qui a déjà un kit', () async {
    final before = await dataSource.fetchById('fam-1');
    final childId = before.children.first.id;
    expect(childId, isNotNull);

    expect(
      () => dataSource.removeChild(familyId: 'fam-1', childId: childId),
      throwsA(isA<FamilyFailure>()),
    );
  });

  test('removeChild retire un enfant sans historique (jamais eu de kit)', () async {
    final withNewChild = await dataSource.addChild(
      familyId: 'fam-1',
      firstName: 'À Retirer',
    );
    final newChildId = withNewChild.children
        .firstWhere((c) => c.firstName == 'À Retirer')
        .id;

    final family = await dataSource.removeChild(familyId: 'fam-1', childId: newChildId);

    expect(family.children.any((c) => c.id == newChildId), isFalse);
  });

  test('assignKit choisit le kit d\'un enfant pour la saison en cours', () async {
    final withNewChild = await dataSource.addChild(
      familyId: 'fam-1',
      firstName: 'Sans Kit',
    );
    final childId = withNewChild.children
        .firstWhere((c) => c.firstName == 'Sans Kit')
        .id;

    final family = await dataSource.assignKit(
      familyId: 'fam-1',
      childId: childId,
      kitId: 'kit-basic',
    );

    final child = family.children.firstWhere((c) => c.id == childId);
    expect(child.hasKitThisSeason, isTrue);
    expect(child.kitId, 'kit-basic');
    expect(child.savedAmount, 0);
  });
}
