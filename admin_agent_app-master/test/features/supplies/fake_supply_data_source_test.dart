import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/supplies/data/fake_supply_data_source.dart';

void main() {
  test('fetchAll renvoie les fournitures seedées', () async {
    final supplies = await FakeSupplyDataSource().fetchAll();
    expect(supplies, hasLength(3));
  });

  test('fetchById renvoie la fourniture demandée', () async {
    final supply = await FakeSupplyDataSource().fetchById('supply-1');
    expect(supply.label, 'Cahier 192 pages');
    expect(supply.unitPrice, 800);
  });

  test('fetchById lance une erreur claire pour un id inconnu', () async {
    expect(
      () => FakeSupplyDataSource().fetchById('supply-inexistante'),
      throwsA(isA<Exception>()),
    );
  });

  test('create ajoute une fourniture au catalogue', () async {
    final dataSource = FakeSupplyDataSource();
    final created = await dataSource.create(
      category: 'Trousse',
      label: 'Trousse simple',
      unit: 'unité',
      unitPrice: 2000,
    );

    expect(created.category, 'Trousse');
    final all = await dataSource.fetchAll();
    expect(all, hasLength(4));
    expect(all.map((s) => s.label), contains('Trousse simple'));
  });

  test('update persiste les modifications', () async {
    final dataSource = FakeSupplyDataSource();
    final original = await dataSource.fetchById('supply-1');

    await dataSource.update(original.copyWith(unitPrice: 1000));

    final updated = await dataSource.fetchById('supply-1');
    expect(updated.unitPrice, 1000);
  });

  test('delete retire la fourniture du catalogue', () async {
    final dataSource = FakeSupplyDataSource();
    await dataSource.delete('supply-1');

    final all = await dataSource.fetchAll();
    expect(all.map((s) => s.id), isNot(contains('supply-1')));
  });
}
