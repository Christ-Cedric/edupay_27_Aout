import '../domain/models/supply.dart';

/// Contrat de source de données du catalogue de fournitures — seam mock ↔ REST.
abstract interface class SupplyDataSource {
  Future<List<Supply>> fetchAll();

  Future<Supply> fetchById(String id);

  Future<Supply> create({
    required String category,
    required String label,
    required String unit,
    required double unitPrice,
  });

  Future<Supply> update(Supply supply);

  Future<void> delete(String id);
}
