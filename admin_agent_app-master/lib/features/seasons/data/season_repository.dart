import '../domain/models/season.dart';

abstract interface class SeasonRepository {
  Future<Season> getCurrentSeason();

  Future<List<Season>> getAllSeasons();

  Future<Season> updateSeason(Season season);

  Future<Season> createSeason(Season season);

  Future<Season> setCurrentSeason(String id);
}
