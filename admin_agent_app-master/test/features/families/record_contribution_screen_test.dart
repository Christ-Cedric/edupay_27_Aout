import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/families/data/family_repository.dart';
import 'package:edupay_admin/features/families/domain/models/delivery_status.dart';
import 'package:edupay_admin/features/families/domain/models/family.dart';
import 'package:edupay_admin/features/families/domain/models/family_filter.dart';
import 'package:edupay_admin/features/families/domain/models/family_status.dart';
import 'package:edupay_admin/features/families/domain/models/savings_plan.dart';
import 'package:edupay_admin/features/families/presentation/providers/families_providers.dart';
import 'package:edupay_admin/features/families/presentation/screens/record_contribution_screen.dart';

class _FakeFamilyRepository implements FamilyRepository {
  _FakeFamilyRepository(this.family);

  final Family family;

  @override
  Future<Family> getFamilyById(String id) async => family;

  @override
  Future<List<Family>> getFamilies(FamilyFilter filter) async => [family];

  @override
  Future<void> reportIncident(String familyId, String note) async {}

  @override
  Future<List<Family>> getPendingValidationFamilies() async => [];

  @override
  Future<void> approveFamily(String familyId) => throw UnimplementedError();

  @override
  Future<void> rejectFamily(String familyId, String reason) =>
      throw UnimplementedError();

  @override
  Future<Family> enrollFamily({
    required String fullName,
    required String phone,
    required SavingsPlan plan,
    required List<dynamic> children,
    String? assignedAgentName,
    required String city,
    String? district,
  }) => throw UnimplementedError();

  @override
  Future<Family> recordCashContribution({
    required String familyId,
    required int amount,
    String? collectedByAgentId,
    String? targetGoalType,
  }) => throw UnimplementedError();

  @override
  Future<Family> addChild({
    required String familyId,
    required String firstName,
    String? level,
    String? school,
  }) => throw UnimplementedError();

  @override
  Future<Family> updateChild({
    required String familyId,
    required String childId,
    String? level,
    String? school,
  }) => throw UnimplementedError();

  @override
  Future<Family> removeChild({required String familyId, required String childId}) =>
      throw UnimplementedError();

  @override
  Future<Family> assignKit({
    required String familyId,
    required String childId,
    required String kitId,
  }) => throw UnimplementedError();
}

Family _familyWith({required double balance, required double targetAmount}) =>
    Family(
      id: 'fam-1',
      fullName: 'Aminata Kabore',
      phone: '+226 76 12 34 56',
      city: 'Koudougou',
      plan: SavingsPlan.weekly,
      balance: balance,
      targetAmount: targetAmount,
      children: const [],
      status: FamilyStatus.active,
      deliveryStatus: DeliveryStatus.pending,
      registeredAt: DateTime(2026, 6),
    );

Future<void> _pump(WidgetTester tester, Family family) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        familyRepositoryProvider.overrideWithValue(
          _FakeFamilyRepository(family),
        ),
      ],
      child: const MaterialApp(
        home: RecordContributionScreen(familyId: 'fam-1'),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'pré-remplit le montant avec la cotisation périodique du plan',
    (tester) async {
      // Plan hebdomadaire = 2 000 FCFA/sem. (savings_plan.dart), largement
      // sous le reste à payer ici : aucun plafonnement attendu.
      await _pump(
        tester,
        _familyWith(balance: 500, targetAmount: 10000),
      );
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '2000');
    },
  );

  testWidgets(
    'plafonne le pré-remplissage au reste à payer si celui-ci est plus petit',
    (tester) async {
      // Reste à payer = 500, sous les 2 000 FCFA/sem. du plan.
      await _pump(
        tester,
        _familyWith(balance: 2000, targetAmount: 2500),
      );
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '500');
    },
  );

  testWidgets(
    'ne pré-remplit rien quand l\'objectif est déjà atteint',
    (tester) async {
      await _pump(
        tester,
        _familyWith(balance: 5000, targetAmount: 5000),
      );
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    },
  );
}
