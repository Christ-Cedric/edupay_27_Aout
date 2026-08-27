import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/seasons/data/fake_season_data_source.dart';
import 'package:edupay_admin/features/seasons/domain/models/season.dart';

void main() {
  test('fetchAll renvoie les saisons seedées, une seule courante', () async {
    final seasons = await FakeSeasonDataSource().fetchAll();
    expect(seasons, hasLength(2));
    expect(seasons.where((s) => s.isCurrent), hasLength(1));
  });

  test('fetchCurrent renvoie la saison marquée courante', () async {
    final current = await FakeSeasonDataSource().fetchCurrent();
    expect(current.isCurrent, isTrue);
  });

  test('create ajoute une saison, jamais courante automatiquement', () async {
    final dataSource = FakeSeasonDataSource();
    final created = await dataSource.create(
      Season(
        id: '',
        label: '2026-2027',
        launchDate: DateTime(2026, 9),
        deliveryDeadline: DateTime(2026, 11),
        enrollmentOpen: true,
        refundFee: 500,
        isCurrent: false,
      ),
    );

    expect(created.isCurrent, isFalse);
    final all = await dataSource.fetchAll();
    expect(all, hasLength(3));
    expect(all.map((s) => s.label), contains('2026-2027'));
  });

  test('setCurrent ne laisse qu\'une seule saison courante', () async {
    final dataSource = FakeSeasonDataSource();
    final created = await dataSource.create(
      Season(
        id: '',
        label: '2026-2027',
        launchDate: DateTime(2026, 9),
        deliveryDeadline: DateTime(2026, 11),
        enrollmentOpen: true,
        refundFee: 500,
        isCurrent: false,
      ),
    );

    await dataSource.setCurrent(created.id);

    final all = await dataSource.fetchAll();
    expect(all.where((s) => s.isCurrent), hasLength(1));
    expect(all.firstWhere((s) => s.isCurrent).id, created.id);
  });
}
