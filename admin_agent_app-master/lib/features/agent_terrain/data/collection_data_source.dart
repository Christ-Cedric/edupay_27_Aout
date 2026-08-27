import '../domain/models/collection.dart';

/// Contrat de source de données des encaissements (consultation Admin
/// uniquement — l'enregistrement d'un encaissement se fait via
/// `FamilyRepository.recordCashContribution`) — seam mock ↔ REST.
abstract interface class CollectionDataSource {
  Future<List<Collection>> fetchForFamily(String familyId);

  /// Toutes les cotisations, toutes familles confondues (rapport « cotisations »,
  /// écran Rapports & exports).
  Future<List<Collection>> fetchAll();
}
