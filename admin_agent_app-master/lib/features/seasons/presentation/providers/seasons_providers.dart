import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/fake_season_data_source.dart';
import '../../data/rest_season_data_source.dart';
import '../../data/season_data_source.dart';
import '../../data/season_repository.dart';
import '../../data/season_repository_impl.dart';
import '../../domain/models/season.dart';

part 'seasons_providers.g.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@Riverpod(keepAlive: true)
SeasonDataSource seasonDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeSeasonDataSource();
  }
  return RestSeasonDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
SeasonRepository seasonRepository(Ref ref) {
  return SeasonRepositoryImpl(ref.watch(seasonDataSourceProvider));
}

@riverpod
Future<Season> currentSeason(Ref ref) {
  return ref.watch(seasonRepositoryProvider).getCurrentSeason();
}

@riverpod
Future<List<Season>> seasonsList(Ref ref) {
  return ref.watch(seasonRepositoryProvider).getAllSeasons();
}

@riverpod
class SeasonEditController extends _$SeasonEditController {
  @override
  FutureOr<Season?> build() => null;

  Future<void> save(Season season) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = await ref.read(seasonRepositoryProvider).updateSeason(season);
      ref.invalidate(currentSeasonProvider);
      ref.invalidate(seasonsListProvider);
      return updated;
    });
  }
}

/// Création d'une nouvelle saison et bascule de la saison courante — motif
/// "Gestion des saisons" (écran `SeasonsListScreen`/`NewSeasonScreen`).
@riverpod
class SeasonCreateController extends _$SeasonCreateController {
  @override
  FutureOr<Season?> build() => null;

  Future<void> create(Season season) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final created = await ref.read(seasonRepositoryProvider).createSeason(season);
      ref.invalidate(seasonsListProvider);
      return created;
    });
  }
}

@riverpod
class SeasonSwitchController extends _$SeasonSwitchController {
  @override
  FutureOr<void> build() {}

  Future<void> setCurrent(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(seasonRepositoryProvider).setCurrentSeason(id);
      ref.invalidate(currentSeasonProvider);
      ref.invalidate(seasonsListProvider);
    });
  }
}
