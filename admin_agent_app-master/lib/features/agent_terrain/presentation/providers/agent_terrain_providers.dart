import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/collection_data_source.dart';
import '../../data/collection_repository.dart';
import '../../data/collection_repository_impl.dart';
import '../../data/fake_collection_data_source.dart';
import '../../data/rest_collection_data_source.dart';
import '../../domain/models/collection.dart';

part 'agent_terrain_providers.g.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@Riverpod(keepAlive: true)
CollectionDataSource collectionDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeCollectionDataSource();
  }
  return RestCollectionDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
CollectionRepository collectionRepository(Ref ref) {
  return CollectionRepositoryImpl(ref.watch(collectionDataSourceProvider));
}

@riverpod
Future<List<Collection>> familyCollectionHistory(Ref ref, String familyId) {
  return ref.watch(collectionRepositoryProvider).getHistoryForFamily(familyId);
}
