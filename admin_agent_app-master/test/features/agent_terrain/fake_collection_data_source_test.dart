import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/agent_terrain/data/fake_collection_data_source.dart';

void main() {
  late FakeCollectionDataSource dataSource;

  setUp(() => dataSource = FakeCollectionDataSource());

  test('fetchForFamily renvoie l\'historique seedé du prototype', () async {
    final history = await dataSource.fetchForFamily('fam-1');
    expect(history, hasLength(2));
    expect(history.every((c) => c.familyId == 'fam-1'), isTrue);
  });
}
