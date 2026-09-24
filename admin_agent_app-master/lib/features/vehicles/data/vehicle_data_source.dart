import '../domain/models/transport_vehicle.dart';

abstract class VehicleDataSource {
  Future<List<TransportVehicle>> getVehicles();
  Future<TransportVehicle> getVehicleById(String id);
  Future<TransportVehicle> createVehicle({
    required String name,
    String? description,
    required double price,
    required List<String> images,
    required bool isAvailable,
  });
  Future<TransportVehicle> updateVehicle(TransportVehicle vehicle);
  Future<void> deleteVehicle(String id);
}
