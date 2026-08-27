import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/core/domain/school_level.dart';
import 'package:edupay_admin/features/kits/data/fake_kit_data_source.dart';
import 'package:edupay_admin/features/kits/domain/models/kit.dart';

void main() {
  test('fetchAll renvoie le catalogue seedé, réparti sur plusieurs classes', () async {
    final kits = await FakeKitDataSource().fetchAll();
    expect(kits, hasLength(5));
    expect(kits.map((k) => k.level), containsAll(KitLevel.values));
    // CM2 a ses 3 variants (contrat §3.6 : classe × variant).
    expect(
      kits.where((k) => k.schoolLevel == SchoolLevel.cm2).map((k) => k.level),
      containsAll(KitLevel.values),
    );
  });

  test('fetchById renvoie le kit demandé', () async {
    final kit = await FakeKitDataSource().fetchById('kit-intermediate');
    expect(kit.price, 17400);
    expect(kit.items, hasLength(4));
  });

  test('update persiste les modifications d\'articles et recalcule le prix', () async {
    final dataSource = FakeKitDataSource();
    final original = await dataSource.fetchById('kit-basic');

    const newItems = [
      KitItem(
        category: 'Cahiers & Écriture',
        label: 'Nouveau cahier',
        quantity: 2,
        unit: 'unité',
        unitPrice: 500,
      ),
    ];
    await dataSource.update(original.copyWith(items: newItems));

    final updated = await dataSource.fetchById('kit-basic');
    expect(updated.price, 1000);
    expect(updated.items, newItems);
  });

  test('fetchById lance une erreur claire pour un id inconnu', () async {
    expect(
      () => FakeKitDataSource().fetchById('kit-inexistant'),
      throwsA(isA<Exception>()),
    );
  });

  test('delete retire le kit du catalogue', () async {
    final dataSource = FakeKitDataSource();
    await dataSource.delete('kit-basic');

    final all = await dataSource.fetchAll();
    expect(all.map((k) => k.id), isNot(contains('kit-basic')));
  });
}
