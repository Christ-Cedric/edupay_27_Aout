import '../domain/models/season.dart';
import 'season_data_source.dart';
import 'season_repository.dart';

class SeasonRepositoryImpl implements SeasonRepository {
  SeasonRepositoryImpl(this._dataSource);

  final SeasonDataSource _dataSource;

  @override
  Future<Season> getCurrentSeason() => _dataSource.fetchCurrent();

  @override
  Future<List<Season>> getAllSeasons() => _dataSource.fetchAll();

  @override
  Future<Season> updateSeason(Season season) => _dataSource.update(season);

  @override
  Future<Season> createSeason(Season season) => _dataSource.create(season);

  @override
  Future<Season> setCurrentSeason(String id) => _dataSource.setCurrent(id);
}
