import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/fake_vehicle_data_source.dart';
import '../../data/rest_vehicle_data_source.dart';
import '../../data/vehicle_data_source.dart';
import '../../data/vehicle_repository.dart';
import '../../data/vehicle_repository_impl.dart';
import '../../domain/models/transport_vehicle.dart';

part 'vehicles_providers.g.dart';

@Riverpod(keepAlive: true)
VehicleDataSource vehicleDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeVehicleDataSource();
  }
  return RestVehicleDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
VehicleRepository vehicleRepository(Ref ref) {
  return VehicleRepositoryImpl(ref.watch(vehicleDataSourceProvider));
}

@riverpod
Future<List<TransportVehicle>> vehiclesList(Ref ref) {
  return ref.watch(vehicleRepositoryProvider).getVehicles();
}

@riverpod
Future<TransportVehicle> vehicleDetail(Ref ref, String id) {
  return ref.watch(vehicleRepositoryProvider).getVehicleById(id);
}

@riverpod
class VehicleCreateController extends _$VehicleCreateController {
  @override
  FutureOr<TransportVehicle?> build() => null;

  Future<void> create({
    required String name,
    String? description,
    required double price,
    required List<String> images,
    required bool isAvailable,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final vehicle = await ref.read(vehicleRepositoryProvider).createVehicle(
        name: name,
        description: description,
        price: price,
        images: images,
        isAvailable: isAvailable,
      );
      ref.invalidate(vehiclesListProvider);
      return vehicle;
    });
  }
}

@riverpod
class VehicleEditController extends _$VehicleEditController {
  @override
  FutureOr<TransportVehicle?> build() => null;

  Future<void> save(TransportVehicle vehicle) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final saved = await ref.read(vehicleRepositoryProvider).updateVehicle(vehicle);
      ref.invalidate(vehiclesListProvider);
      ref.invalidate(vehicleDetailProvider(vehicle.id));
      return saved;
    });
  }
}

@riverpod
class VehicleDeleteController extends _$VehicleDeleteController {
  @override
  FutureOr<void> build() {}

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vehicleRepositoryProvider).deleteVehicle(id);
      ref.invalidate(vehiclesListProvider);
    });
  }
}
