import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/school_level.dart';
import '../../../../core/network/network_providers.dart';
import '../../../families/presentation/providers/families_providers.dart';
import '../../data/fake_kit_data_source.dart';
import '../../data/kit_data_source.dart';
import '../../data/kit_repository.dart';
import '../../data/kit_repository_impl.dart';
import '../../data/rest_kit_data_source.dart';
import '../../domain/models/kit.dart';

part 'kits_providers.g.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@Riverpod(keepAlive: true)
KitDataSource kitDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeKitDataSource();
  }
  return RestKitDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
KitRepository kitRepository(Ref ref) {
  return KitRepositoryImpl(
    ref.watch(kitDataSourceProvider),
    ref.watch(familyRepositoryProvider),
  );
}

@riverpod
Future<List<Kit>> kitsList(Ref ref) {
  return ref.watch(kitRepositoryProvider).getKits();
}

@riverpod
Future<Kit> kitDetail(Ref ref, String id) {
  return ref.watch(kitRepositoryProvider).getKitById(id);
}

@riverpod
class KitEditController extends _$KitEditController {
  @override
  FutureOr<Kit?> build() => null;

  Future<void> save(Kit kit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final saved = await ref.read(kitRepositoryProvider).updateKit(kit);
      ref.invalidate(kitsListProvider);
      ref.invalidate(kitDetailProvider(kit.id));
      return saved;
    });
  }
}

@riverpod
class KitCreateController extends _$KitCreateController {
  @override
  FutureOr<Kit?> build() => null;

  Future<void> create({
    required KitLevel level,
    required SchoolLevel schoolLevel,
    required List<KitItem> items,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final kit = await ref
          .read(kitRepositoryProvider)
          .createKit(level: level, schoolLevel: schoolLevel, items: items);
      ref.invalidate(kitsListProvider);
      return kit;
    });
  }
}

@riverpod
class KitDeleteController extends _$KitDeleteController {
  @override
  FutureOr<void> build() {}

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(kitRepositoryProvider).deleteKit(id);
      ref.invalidate(kitsListProvider);
    });
  }
}

@riverpod
class KitImportController extends _$KitImportController {
  @override
  FutureOr<KitImportResult?> build() => null;

  Future<void> import(String fileBase64) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(kitRepositoryProvider)
          .importCatalog(fileBase64);
      ref.invalidate(kitsListProvider);
      return result;
    });
  }
}
