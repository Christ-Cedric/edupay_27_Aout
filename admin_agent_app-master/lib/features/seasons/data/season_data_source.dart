import '../domain/models/season.dart';

/// Contrat de source de données de la saison — seam mock ↔ REST.
abstract interface class SeasonDataSource {
  Future<Season> fetchCurrent();

  Future<List<Season>> fetchAll();

  Future<Season> update(Season season);

  /// Crée une nouvelle saison (`season.id`/`isCurrent` ignorés — assignés
  /// par le serveur, une saison créée ne devient jamais courante
  /// automatiquement).
  Future<Season> create(Season season);

  /// Désigne la saison [id] comme courante — démarque toute autre saison.
  Future<Season> setCurrent(String id);
}
