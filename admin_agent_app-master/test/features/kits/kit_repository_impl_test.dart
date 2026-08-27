import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/families/data/family_data_source.dart'
    show ChildEnrollmentInput;
import 'package:edupay_admin/features/families/data/family_repository.dart';
import 'package:edupay_admin/features/families/data/fake_family_data_source.dart';
import 'package:edupay_admin/features/families/data/family_repository_impl.dart';
import 'package:edupay_admin/features/families/domain/models/family.dart';
import 'package:edupay_admin/features/families/domain/models/family_filter.dart';
import 'package:edupay_admin/features/families/domain/models/savings_plan.dart';
import 'package:edupay_admin/features/kits/data/fake_kit_data_source.dart';
import 'package:edupay_admin/features/kits/data/kit_repository_impl.dart';
import 'package:edupay_admin/features/kits/domain/models/kit_failure.dart';

/// Double de test : aucune famille n'utilise jamais aucun kit, pour tester
/// le chemin de succès de `deleteKit` indépendamment des données seedées.
class _EmptyFamilyRepository implements FamilyRepository {
  @override
  Future<List<Family>> getFamilies(FamilyFilter filter) async => [];

  @override
  Future<Family> getFamilyById(String id) => throw UnimplementedError();

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
  Future<void> reportIncident(String familyId, String note) =>
      throw UnimplementedError();

  @override
  Future<List<Family>> getPendingValidationFamilies() =>
      throw UnimplementedError();

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

void main() {
  test('deleteKit refuse de supprimer un kit assigné à des familles', () async {
    final repository = KitRepositoryImpl(
      FakeKitDataSource(),
      FamilyRepositoryImpl(FakeFamilyDataSource()),
    );

    // 'kit-intermediate' est assigné à plusieurs enfants seedés.
    expect(
      () => repository.deleteKit('kit-intermediate'),
      throwsA(isA<KitFailure>()),
    );
  });

  test('deleteKit supprime un kit non assigné à une famille', () async {
    final repository = KitRepositoryImpl(
      FakeKitDataSource(),
      _EmptyFamilyRepository(),
    );

    await repository.deleteKit('kit-basic');

    final remaining = await repository.getKits();
    expect(remaining.map((k) => k.id), isNot(contains('kit-basic')));
  });
}
