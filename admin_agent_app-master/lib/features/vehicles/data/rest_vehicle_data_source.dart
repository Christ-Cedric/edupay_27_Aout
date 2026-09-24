import '../../../core/network/api_client.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/transport_vehicle.dart';
import 'vehicle_data_source.dart';

class RestVehicleDataSource implements VehicleDataSource {
  final ApiClient _client;

  const RestVehicleDataSource(this._client);

  @override
  Future<List<TransportVehicle>> getVehicles() async {
    final json = await _client.get(ApiRoutes.adminVehicles);
    return (json['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(TransportVehicle.fromJson)
        .toList();
  }

  @override
  Future<TransportVehicle> getVehicleById(String id) async {
    final json = await _client.get(ApiRoutes.adminVehicle(id));
    return TransportVehicle.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<TransportVehicle> createVehicle({
    required String name,
    String? description,
    required double price,
    required List<String> images,
    required bool isAvailable,
  }) async {
    final json = await _client.post(
      ApiRoutes.adminVehicles,
      body: {
        'name': name,
        'description': description,
        'price': price.round(),
        'images': images,
        'is_available': isAvailable,
      },
    );
    return TransportVehicle.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<TransportVehicle> updateVehicle(TransportVehicle vehicle) async {
    final json = await _client.put(
      ApiRoutes.adminVehicle(vehicle.id),
      body: {
        'name': vehicle.name,
        'description': vehicle.description,
        'price': vehicle.price.round(),
        'images': vehicle.images,
        'is_available': vehicle.isAvailable,
      },
    );
    return TransportVehicle.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await _client.delete(ApiRoutes.adminVehicle(id));
  }
}
