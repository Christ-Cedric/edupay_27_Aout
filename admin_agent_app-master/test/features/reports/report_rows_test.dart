import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:edupay_admin/core/domain/school_level.dart';
import 'package:edupay_admin/features/agent_terrain/domain/models/collection.dart';
import 'package:edupay_admin/features/agent_terrain/domain/models/collection_mode.dart';
import 'package:edupay_admin/features/families/domain/models/delivery_status.dart';
import 'package:edupay_admin/features/families/domain/models/family.dart';
import 'package:edupay_admin/features/families/domain/models/family_status.dart';
import 'package:edupay_admin/features/families/domain/models/savings_plan.dart';
import 'package:edupay_admin/features/kits/domain/models/kit.dart';
import 'package:edupay_admin/features/reports/presentation/screens/reports_screen.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('buildContributionsRows', () {
    test('une ligne par cotisation, formatée pour le CSV', () {
      final rows = buildContributionsRows([
        Collection(
          id: 'col-1',
          familyId: 'fam-1',
          familyName: 'Aminata Kabore',
          agentName: 'Konate Ali',
          amount: 2000,
          mode: CollectionMode.cash,
          collectedAt: DateTime(2026, 3, 5),
          receiptNumber: 'EP-RC-2026-0148',
        ),
      ]);

      expect(rows, hasLength(1));
      expect(rows.single, [
        '05/03/2026',
        'Aminata Kabore',
        'Konate Ali',
        '2 000 FCFA',
        'Espèces en main',
        'EP-RC-2026-0148',
      ]);
    });
  });

  group('buildFamiliesRows', () {
    test('une ligne par famille, statut et livraison traduits', () {
      final rows = buildFamiliesRows([
        Family(
          id: 'fam-1',
          fullName: 'Bila Ouedraogo',
          phone: '+226 70 00 00 00',
          city: 'Ouagadougou',
          plan: SavingsPlan.monthly,
          balance: 8500,
          targetAmount: 17000,
          children: const [],
          status: FamilyStatus.active,
          deliveryStatus: DeliveryStatus.inProgress,
          registeredAt: DateTime(2026),
        ),
      ]);

      expect(rows.single, [
        'Bila Ouedraogo',
        'Ouagadougou',
        'Actif',
        'Mensuel',
        '8 500 FCFA',
        '17 000 FCFA',
        '0',
        'En route',
      ]);
    });
  });

  group('buildDeliveriesRows', () {
    final kit = const Kit(
      id: 'kit-cm2-basic',
      level: KitLevel.basic,
      schoolLevel: SchoolLevel.cm2,
      price: 15000,
      items: [
        KitItem(
          category: 'Cahiers & Écriture',
          label: 'Cahiers',
          quantity: 5,
          unit: 'unité',
          unitPrice: 500,
        ),
        KitItem(
          category: 'Écriture',
          label: 'Stylos',
          quantity: 3,
          unit: 'unité',
          unitPrice: 250,
        ),
      ],
    );

    test('joint chaque enfant à son kit via son kitId', () {
      final rows = buildDeliveriesRows([
        Family(
          id: 'fam-1',
          fullName: 'Aminata Kabore',
          phone: '+226 76 12 34 56',
          city: 'Koudougou',
          plan: SavingsPlan.weekly,
          balance: 2000,
          targetAmount: 15000,
          children: [
            const FamilyChild(
              id: 'child-1',
              firstName: 'Issa',
              level: 'CM2',
              school: 'École A',
              kitId: 'kit-cm2-basic',
              targetAmount: 15000,
              savedAmount: 2000,
            ),
          ],
          status: FamilyStatus.active,
          deliveryStatus: DeliveryStatus.pending,
          registeredAt: DateTime(2026),
          assignedAgentName: 'Konate Ali',
        ),
      ], [kit]);

      expect(rows.single, [
        'Aminata Kabore',
        'Koudougou',
        'CM2 - Kit Basique',
        'En attente',
        'Konate Ali',
      ]);
    });

    test('famille sans enfant → tiret, pas de plantage', () {
      final rows = buildDeliveriesRows([
        Family(
          id: 'fam-2',
          fullName: 'Famille sans enfant',
          phone: '+226 70 11 22 33',
          city: 'Bobo-Dioulasso',
          plan: SavingsPlan.daily,
          balance: 0,
          targetAmount: 0,
          children: const [],
          status: FamilyStatus.active,
          deliveryStatus: DeliveryStatus.pending,
          registeredAt: DateTime(2026),
        ),
      ], [kit]);

      expect(rows.single[2], '—');
      expect(rows.single[4], '—');
    });

    test('kit introuvable dans le catalogue → tiret, pas de plantage', () {
      final rows = buildDeliveriesRows([
        Family(
          id: 'fam-3',
          fullName: 'Kit orphelin',
          phone: '+226 70 44 55 66',
          city: 'Koudougou',
          plan: SavingsPlan.weekly,
          balance: 0,
          targetAmount: 15000,
          children: [
            const FamilyChild(
              id: 'child-2',
              firstName: 'Awa',
              level: 'CM2',
              school: 'École B',
              kitId: 'kit-inconnu',
              targetAmount: 15000,
              savedAmount: 0,
            ),
          ],
          status: FamilyStatus.active,
          deliveryStatus: DeliveryStatus.pending,
          registeredAt: DateTime(2026),
        ),
      ], [kit]);

      expect(rows.single[2], '—');
    });
  });
}
