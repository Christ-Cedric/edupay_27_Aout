import '../domain/models/transport_vehicle.dart';
import 'vehicle_data_source.dart';

class FakeVehicleDataSource implements VehicleDataSource {
  final List<TransportVehicle> _vehicles = [
    TransportVehicle(
      id: 'v-1',
      name: 'Moto Yamaha YBR 125',
      description: 'Moto robuste idéale pour le transport des élèves et déplacements urbains.',
      price: 650000,
      images: ['https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600'],
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    TransportVehicle(
      id: 'v-2',
      name: 'Tricycle KAVAKI Cargo 200cc',
      description: 'Engin à trois roues performant avec grande capacité d\'emport.',
      price: 1200000,
      images: ['https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600'],
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<TransportVehicle>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_vehicles);
  }

  @override
  Future<TransportVehicle> getVehicleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _vehicles.firstWhere(
      (v) => v.id == id,
      orElse: () => throw Exception('Engin non trouvé'),
    );
  }

  @override
  Future<TransportVehicle> createVehicle({
    required String name,
    String? description,
    required double price,
    required List<String> images,
    required bool isAvailable,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newVehicle = TransportVehicle(
      id: 'v-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      price: price,
      images: images,
      isAvailable: isAvailable,
      createdAt: DateTime.now(),
    );
    _vehicles.insert(0, newVehicle);
    return newVehicle;
  }

  @override
  Future<TransportVehicle> updateVehicle(TransportVehicle vehicle) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
    } else {
      _vehicles.insert(0, vehicle);
    }
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _vehicles.removeWhere((v) => v.id == id);
  }
}
