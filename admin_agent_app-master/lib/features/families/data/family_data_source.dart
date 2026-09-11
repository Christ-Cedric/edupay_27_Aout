import '../domain/models/family.dart';
import '../domain/models/family_filter.dart';
import '../domain/models/savings_plan.dart';

/// Un enfant à inscrire, avec son propre kit (§7 #2 du contrat : kit par
/// enfant, pas par famille). Seule la photo n'est pas collectée à ce stade ;
/// `level`/`school` sont `null` quand non renseignés.
typedef ChildEnrollmentInput = ({
  String firstName,
  String? level,
  String? school,
  String kitId,
});

/// Contrat de source de données des familles — seam mock ↔ REST.
///
/// Ne couvre que ce qui touche une source de données : `reportIncident` reste
/// dans le [FamilyRepository] (pas de persistance à ce stade).
abstract interface class FamilyDataSource {
  Future<List<Family>> fetchAll(FamilyFilter filter);

  Future<Family> fetchById(String id);

  Future<Family> enroll({
    required String fullName,
    required String phone,
    required SavingsPlan plan,
    required List<ChildEnrollmentInput> children,
    String? assignedAgentName,
    required String city,
    String? district,
  });

  Future<void> approve(String id);

  Future<void> reject(String id, String reason);

  /// Consigne un incident sur le dossier de la famille (motif `ad_do`).
  Future<void> reportIncident(String familyId, String note);

  /// Encaissement cash saisi par l'admin (dossier famille). Crédite le solde
  /// de la famille via le module Paiements.
  Future<Family> recordCashContribution({
    required String familyId,
    required int amount,
    String? collectedByAgentId,
    String? targetGoalType,
  });

  /// Ajoute un enfant à une famille existante — sans kit (choix séparé, par
  /// saison, voir [assignKit]). Renvoie le dossier famille mis à jour.
  Future<Family> addChild({
    required String familyId,
    required String firstName,
    String? level,
    String? school,
  });

  /// Modifie la classe/école d'un enfant (chaque saison, l'enfant change de
  /// classe). Renvoie le dossier famille mis à jour.
  Future<Family> updateChild({
    required String familyId,
    required String childId,
    String? level,
    String? school,
  });

  /// Retire un enfant — peut échouer ([FamilyFailure]) s'il a déjà un
  /// historique de cotisation. Renvoie le dossier famille mis à jour.
  Future<Family> removeChild({required String familyId, required String childId});

  /// Choisit ou change le kit d'un enfant pour la saison en cours. Renvoie
  /// le dossier famille mis à jour.
  Future<Family> assignKit({
    required String familyId,
    required String childId,
    required String kitId,
  });
}
