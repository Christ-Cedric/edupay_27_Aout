import '../domain/models/supply.dart';

abstract interface class SupplyRepository {
  Future<List<Supply>> getSupplies();

  Future<Supply> getSupplyById(String id);

  Future<Supply> createSupply({
    required String category,
    required String label,
    required String unit,
    required double unitPrice,
  });

  Future<Supply> updateSupply(Supply supply);

  Future<void> deleteSupply(String id);
}
