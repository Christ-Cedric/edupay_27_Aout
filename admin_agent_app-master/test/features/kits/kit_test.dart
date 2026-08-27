import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/core/domain/school_level.dart';
import 'package:edupay_admin/features/kits/domain/models/kit.dart';

void main() {
  group('KitItem.lineTotal', () {
    test('quantité × prix unitaire', () {
      const item = KitItem(
        category: 'Cahiers & Écriture',
        label: '5 cahiers',
        quantity: 5,
        unit: 'unité',
        unitPrice: 300,
      );
      expect(item.lineTotal, 1500);
    });
  });

  group('computeItemsTotal', () {
    test('somme les lignes de plusieurs fournitures', () {
      const items = [
        KitItem(
          category: 'Cahiers & Écriture',
          label: 'Cahiers',
          quantity: 5,
          unit: 'unité',
          unitPrice: 300,
        ),
        KitItem(
          category: 'Écriture',
          label: 'Stylos',
          quantity: 3,
          unit: 'unité',
          unitPrice: 200,
        ),
      ];
      // (5*300) + (3*200) = 1500 + 600 = 2100
      expect(computeItemsTotal(items), 2100);
    });

    test('vaut 0 pour une liste vide', () {
      expect(computeItemsTotal(const []), 0);
    });
  });

  group('kitsForSchoolLevel', () {
    test('filtre les kits ciblant la classe donnée', () {
      const items = [
        KitItem(
          category: 'Cahiers & Écriture',
          label: 'Cahiers',
          quantity: 1,
          unit: 'unité',
          unitPrice: 100,
        ),
      ];
      final kits = [
        const Kit(
          id: 'k1',
          level: KitLevel.basic,
          schoolLevel: SchoolLevel.cm2,
          price: 100,
          items: items,
        ),
        const Kit(
          id: 'k2',
          level: KitLevel.premium,
          schoolLevel: SchoolLevel.cm2,
          price: 100,
          items: items,
        ),
        const Kit(
          id: 'k3',
          level: KitLevel.basic,
          schoolLevel: SchoolLevel.cp1,
          price: 100,
          items: items,
        ),
      ];

      final result = kitsForSchoolLevel(kits, SchoolLevel.cm2);

      expect(result.map((k) => k.id), ['k1', 'k2']);
    });

    test('renvoie une liste vide si aucun kit ne cible la classe', () {
      expect(kitsForSchoolLevel(const [], SchoolLevel.cm2), isEmpty);
    });
  });
}
