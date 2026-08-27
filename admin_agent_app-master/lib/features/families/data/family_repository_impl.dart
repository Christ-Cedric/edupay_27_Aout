import '../domain/models/family.dart';
import '../domain/models/family_filter.dart';
import '../domain/models/family_status.dart';
import '../domain/models/savings_plan.dart';
import 'family_data_source.dart' show ChildEnrollmentInput, FamilyDataSource;
import 'family_repository.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  FamilyRepositoryImpl(this._dataSource);

  final FamilyDataSource _dataSource;

  @override
  Future<List<Family>> getFamilies(FamilyFilter filter) =>
      _dataSource.fetchAll(filter);

  @override
  Future<Family> getFamilyById(String id) => _dataSource.fetchById(id);

  @override
  Future<Family> enrollFamily({
    required String fullName,
    required String phone,
    required SavingsPlan plan,
    required List<ChildEnrollmentInput> children,
    String? assignedAgentName,
    required String city,
    String? district,
  }) {
    return _dataSource.enroll(
      fullName: fullName,
      phone: phone,
      plan: plan,
      children: children,
      assignedAgentName: assignedAgentName,
      city: city,
      district: district,
    );
  }

  @override
  Future<void> reportIncident(String familyId, String note) =>
      _dataSource.reportIncident(familyId, note);

  @override
  Future<List<Family>> getPendingValidationFamilies() {
    return _dataSource.fetchAll(
      const FamilyFilter(status: FamilyStatus.pendingValidation),
    );
  }

  @override
  Future<void> approveFamily(String familyId) => _dataSource.approve(familyId);

  @override
  Future<void> rejectFamily(String familyId, String reason) =>
      _dataSource.reject(familyId, reason);

  @override
  Future<Family> recordCashContribution({
    required String familyId,
    required int amount,
    String? collectedByAgentId,
  }) {
    return _dataSource.recordCashContribution(
      familyId: familyId,
      amount: amount,
      collectedByAgentId: collectedByAgentId,
    );
  }

  @override
  Future<Family> addChild({
    required String familyId,
    required String firstName,
    String? level,
    String? school,
  }) {
    return _dataSource.addChild(
      familyId: familyId,
      firstName: firstName,
      level: level,
      school: school,
    );
  }

  @override
  Future<Family> updateChild({
    required String familyId,
    required String childId,
    String? level,
    String? school,
  }) {
    return _dataSource.updateChild(
      familyId: familyId,
      childId: childId,
      level: level,
      school: school,
    );
  }

  @override
  Future<Family> removeChild({required String familyId, required String childId}) =>
      _dataSource.removeChild(familyId: familyId, childId: childId);

  @override
  Future<Family> assignKit({
    required String familyId,
    required String childId,
    required String kitId,
  }) {
    return _dataSource.assignKit(familyId: familyId, childId: childId, kitId: kitId);
  }
}
