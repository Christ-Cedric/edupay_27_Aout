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
import 'package:edupay_admin/features/families/presentation/screens/family_children_screen.dart';

/// Kit ids seedés par `FakeKitDataSource` (mode mock par défaut en test) —
/// `kit-intermediate` a un prix réel (18 500 FCFA) que la carte doit
/// afficher, confirmant que le kit de chaque enfant est bien résolu.
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

Family _familyWith(List<FamilyChild> children) => Family(
  id: 'fam-1',
  fullName: 'Aminata Kabore',
  phone: '+226 76 12 34 56',
  city: 'Koudougou',
  plan: SavingsPlan.weekly,
  balance: 0,
  targetAmount: 0,
  children: children,
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
        home: FamilyChildrenScreen(familyId: 'fam-1'),
      ),
    ),
  );
}

void main() {
  testWidgets('affiche un état vide quand la famille n\'a aucun enfant', (
    tester,
  ) async {
    await _pump(tester, _familyWith(const []));
    await tester.pumpAndSettle();

    expect(find.text('Aucun enfant enregistré'), findsOneWidget);
  });

  testWidgets(
    'affiche chaque enfant avec son niveau, son école, son kit et sa progression',
    (tester) async {
      await _pump(
        tester,
        _familyWith(const [
          FamilyChild(
            id: 'child-1',
            firstName: 'Awa',
            level: 'CM2',
            school: 'École Centre - Koudougou',
            kitId: 'kit-intermediate',
            targetAmount: 18500,
            savedAmount: 9250,
          ),
        ]),
      );
      // Le chargement du kit (`FakeKitDataSource`) passe par un vrai délai
      // (200ms) que `pumpAndSettle` ne rattrape pas de façon fiable ici —
      // des `pump` explicites le laissent se résoudre.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Awa'), findsOneWidget);
      expect(find.text('CM2 - École Centre - Koudougou'), findsOneWidget);
      expect(find.text('CM2 - Kit Essentiel'), findsOneWidget);
      expect(find.text('18 500 FCFA'), findsOneWidget);
      expect(find.text('9 250 FCFA'), findsOneWidget);
    },
  );

  testWidgets(
    'un enfant sans kit pour la saison en cours propose de lui en choisir un',
    (tester) async {
      await _pump(
        tester,
        _familyWith(const [
          FamilyChild(
            id: 'child-1',
            firstName: 'Sans Kit',
            level: 'CM2',
            school: '',
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sans Kit'), findsOneWidget);
      expect(find.text('Aucun kit choisi pour cette saison.'), findsOneWidget);
      expect(find.text('Choisir un kit'), findsOneWidget);
    },
  );
}
