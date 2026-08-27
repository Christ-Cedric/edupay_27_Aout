import '../domain/models/family.dart';
import '../domain/models/family_filter.dart';
import '../domain/models/savings_plan.dart';
import 'family_data_source.dart' show ChildEnrollmentInput;

/// Interface d'accès aux données des familles — seul point à modifier quand
/// le vrai backend arrivera (remplacer [FakeFamilyDataSource] par une
/// source Dio, sans toucher à l'UI/aux providers).
abstract interface class FamilyRepository {
  Future<List<Family>> getFamilies(FamilyFilter filter);

  Future<Family> getFamilyById(String id);

  Future<Family> enrollFamily({
    required String fullName,
    required String phone,
    required SavingsPlan plan,
    required List<ChildEnrollmentInput> children,
    String? assignedAgentName,
    required String city,
    String? district,
  });

  Future<void> reportIncident(String familyId, String note);

  Future<List<Family>> getPendingValidationFamilies();

  Future<void> approveFamily(String familyId);

  Future<void> rejectFamily(String familyId, String reason);

  /// Encaissement cash saisi par l'admin (dossier famille).
  Future<Family> recordCashContribution({
    required String familyId,
    required int amount,
    String? collectedByAgentId,
  });

  /// Ajoute un enfant à une famille existante — sans kit (choix séparé, par
  /// saison, voir [assignKit]).
  Future<Family> addChild({
    required String familyId,
    required String firstName,
    String? level,
    String? school,
  });

  /// Modifie la classe/école d'un enfant.
  Future<Family> updateChild({
    required String familyId,
    required String childId,
    String? level,
    String? school,
  });

  /// Retire un enfant — peut échouer ([FamilyFailure]) s'il a déjà un
  /// historique de cotisation.
  Future<Family> removeChild({required String familyId, required String childId});

  /// Choisit ou change le kit d'un enfant pour la saison en cours.
  Future<Family> assignKit({
    required String familyId,
    required String childId,
    required String kitId,
  });
}
