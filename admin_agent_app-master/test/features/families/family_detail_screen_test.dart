import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/families/data/family_data_source.dart'
    show ChildEnrollmentInput;
import 'package:edupay_admin/features/families/data/family_repository.dart';
import 'package:edupay_admin/features/families/domain/models/delivery_status.dart';
import 'package:edupay_admin/features/families/domain/models/family.dart';
import 'package:edupay_admin/features/families/domain/models/family_filter.dart';
import 'package:edupay_admin/features/families/domain/models/family_status.dart';
import 'package:edupay_admin/features/families/domain/models/savings_plan.dart';
import 'package:edupay_admin/features/families/presentation/providers/families_providers.dart';
import 'package:edupay_admin/features/families/presentation/screens/family_detail_screen.dart';

final _family = Family(
  id: 'fam-1',
  fullName: 'Aminata Kabore',
  phone: '+226 76 12 34 56',
  city: 'Koudougou',
  plan: SavingsPlan.weekly,
  balance: 24700,
  targetAmount: 39800,
  children: const [
    FamilyChild(
      id: 'child-1',
      firstName: 'Fatoumata',
      level: 'CM2',
      school: 'École Centre - Koudougou',
      kitId: 'kit-1',
      targetAmount: 39800,
      savedAmount: 24700,
    ),
  ],
  status: FamilyStatus.active,
  deliveryStatus: DeliveryStatus.pending,
  registeredAt: DateTime(2026, 6),
  assignedAgentName: 'Konate Ali',
);

/// Capture le motif transmis à `reportIncident` pour vérifier qu'il vient
/// bien de la saisie de l'admin, plus aucun texte codé en dur.
class _FakeFamilyRepository implements FamilyRepository {
  _FakeFamilyRepository([Family? family]) : family = family ?? _family;

  final Family family;
  String? lastIncidentNote;
  bool contributionRecorded = false;

  @override
  Future<void> reportIncident(String familyId, String note) async {
    lastIncidentNote = note;
  }

  @override
  Future<Family> getFamilyById(String id) async => family;

  @override
  Future<List<Family>> getFamilies(FamilyFilter filter) async => [family];

  @override
  Future<Family> enrollFamily({
    required String fullName,
    required String phone,
    required SavingsPlan plan,
    required List<ChildEnrollmentInput> children,
    String? assignedAgentName,
    required String city,
    String? district,
  }) => throw UnimplementedError();

  @override
  Future<List<Family>> getPendingValidationFamilies() async => [];

  @override
  Future<void> approveFamily(String familyId) => throw UnimplementedError();

  @override
  Future<void> rejectFamily(String familyId, String reason) =>
      throw UnimplementedError();

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

Future<void> _pump(WidgetTester tester, _FakeFamilyRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [familyRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(
        home: FamilyDetailScreen(familyId: 'fam-1'),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'annuler la boîte de dialogue ne signale aucun incident',
    (tester) async {
      final repository = _FakeFamilyRepository();
      await _pump(tester, repository);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Signaler un incident'));
      await tester.pumpAndSettle();
      expect(find.text('Décrivez ce qui se passe...'), findsOneWidget);

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(repository.lastIncidentNote, isNull);
    },
  );

  testWidgets(
    'saisir un motif et confirmer transmet le texte tapé (pas un texte codé en dur)',
    (tester) async {
      final repository = _FakeFamilyRepository();
      await _pump(tester, repository);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Signaler un incident'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Colis endommagé à la livraison',
      );
      await tester.tap(find.text('Signaler'));
      await tester.pumpAndSettle();

      expect(
        repository.lastIncidentNote,
        'Colis endommagé à la livraison',
      );
      expect(find.text('Incident signalé'), findsOneWidget);
    },
  );

  testWidgets(
    'confirmer avec un champ vide ne signale rien',
    (tester) async {
      final repository = _FakeFamilyRepository();
      await _pump(tester, repository);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Signaler un incident'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Signaler'));
      await tester.pumpAndSettle();

      expect(repository.lastIncidentNote, isNull);
    },
  );

  testWidgets('affiche le statut du compte dans le dossier', (tester) async {
    await _pump(tester, _FakeFamilyRepository());
    await tester.pumpAndSettle();

    expect(find.text('Actif'), findsOneWidget);
  });

  testWidgets(
    'affiche le motif de rejet quand le compte est rejeté',
    (tester) async {
      final rejected = _family.copyWith(
        status: FamilyStatus.rejected,
        rejectionReason: 'Numéro de téléphone invalide',
      );
      await _pump(tester, _FakeFamilyRepository(rejected));
      await tester.pumpAndSettle();

      expect(find.text('Compte rejeté'), findsOneWidget);
      expect(find.text('Numéro de téléphone invalide'), findsOneWidget);
    },
  );

  testWidgets(
    "un compte en attente de validation ne peut pas être encaissé",
    (tester) async {
      final pending = _family.copyWith(status: FamilyStatus.pendingValidation);
      await _pump(tester, _FakeFamilyRepository(pending));
      await tester.pumpAndSettle();

      // Si l'action tentait de naviguer (au lieu d'être désactivée), ce tap
      // ferait planter le test : pas de GoRouter dans ce harnais minimal.
      await tester.tap(find.text('Enregistrer un encaissement'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "Ce compte est en attente de validation — approuvez-le avant d'encaisser.",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'un compte rejeté ne peut pas être encaissé',
    (tester) async {
      final rejected = _family.copyWith(status: FamilyStatus.rejected);
      await _pump(tester, _FakeFamilyRepository(rejected));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enregistrer un encaissement'));
      await tester.pumpAndSettle();

      expect(
        find.text("Ce compte n'est pas actif — impossible d'encaisser."),
        findsOneWidget,
      );
    },
  );
}
