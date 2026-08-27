import '../domain/models/collection.dart';

/// Interface d'accès en lecture aux encaissements de cotisations (dossier
/// famille Admin, rapport « cotisations ») — seul point à modifier quand le
/// vrai backend arrivera.
abstract interface class CollectionRepository {
  Future<List<Collection>> getHistoryForFamily(String familyId);

  Future<List<Collection>> getAllHistory();
}
