import '../domain/models/transport_vehicle.dart';
import 'vehicle_data_source.dart';
import 'vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleDataSource _dataSource;

  VehicleRepositoryImpl(this._dataSource);

  @override
  Future<List<TransportVehicle>> getVehicles() => _dataSource.getVehicles();

  @override
  Future<TransportVehicle> getVehicleById(String id) => _dataSource.getVehicleById(id);

  @override
  Future<TransportVehicle> createVehicle({
    required String name,
    String? description,
    required double price,
    required List<String> images,
    required bool isAvailable,
  }) {
    return _dataSource.createVehicle(
      name: name,
      description: description,
      price: price,
      images: images,
      isAvailable: isAvailable,
    );
  }

  @override
  Future<TransportVehicle> updateVehicle(TransportVehicle vehicle) {
    return _dataSource.updateVehicle(vehicle);
  }

  @override
  Future<void> deleteVehicle(String id) => _dataSource.deleteVehicle(id);
}
