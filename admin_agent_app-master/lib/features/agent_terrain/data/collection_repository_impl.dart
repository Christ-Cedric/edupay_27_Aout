import '../domain/models/collection.dart';
import 'collection_data_source.dart';
import 'collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._dataSource);

  final CollectionDataSource _dataSource;

  @override
  Future<List<Collection>> getHistoryForFamily(String familyId) =>
      _dataSource.fetchForFamily(familyId);

  @override
  Future<List<Collection>> getAllHistory() => _dataSource.fetchAll();
}
