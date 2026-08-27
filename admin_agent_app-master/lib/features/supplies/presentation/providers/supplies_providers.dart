import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/fake_supply_data_source.dart';
import '../../data/supply_data_source.dart';
import '../../data/supply_repository.dart';
import '../../data/supply_repository_impl.dart';
import '../../data/rest_supply_data_source.dart';
import '../../domain/models/supply.dart';

part 'supplies_providers.g.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@Riverpod(keepAlive: true)
SupplyDataSource supplyDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeSupplyDataSource();
  }
  return RestSupplyDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
SupplyRepository supplyRepository(Ref ref) {
  return SupplyRepositoryImpl(ref.watch(supplyDataSourceProvider));
}

@riverpod
Future<List<Supply>> suppliesList(Ref ref) {
  return ref.watch(supplyRepositoryProvider).getSupplies();
}

@riverpod
Future<Supply> supplyDetail(Ref ref, String id) {
  return ref.watch(supplyRepositoryProvider).getSupplyById(id);
}

@riverpod
class SupplyCreateController extends _$SupplyCreateController {
  @override
  FutureOr<Supply?> build() => null;

  Future<void> create({
    required String category,
    required String label,
    required String unit,
    required double unitPrice,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supply = await ref
          .read(supplyRepositoryProvider)
          .createSupply(
            category: category,
            label: label,
            unit: unit,
            unitPrice: unitPrice,
          );
      ref.invalidate(suppliesListProvider);
      return supply;
    });
  }
}

@riverpod
class SupplyEditController extends _$SupplyEditController {
  @override
  FutureOr<Supply?> build() => null;

  Future<void> save(Supply supply) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final saved = await ref.read(supplyRepositoryProvider).updateSupply(supply);
      ref.invalidate(suppliesListProvider);
      ref.invalidate(supplyDetailProvider(supply.id));
      return saved;
    });
  }
}

@riverpod
class SupplyDeleteController extends _$SupplyDeleteController {
  @override
  FutureOr<void> build() {}

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(supplyRepositoryProvider).deleteSupply(id);
      ref.invalidate(suppliesListProvider);
    });
  }
}
