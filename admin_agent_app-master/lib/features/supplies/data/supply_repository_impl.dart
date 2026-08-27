import '../domain/models/supply.dart';
import 'supply_data_source.dart';
import 'supply_repository.dart';

class SupplyRepositoryImpl implements SupplyRepository {
  SupplyRepositoryImpl(this._dataSource);

  final SupplyDataSource _dataSource;

  @override
  Future<List<Supply>> getSupplies() => _dataSource.fetchAll();

  @override
  Future<Supply> getSupplyById(String id) => _dataSource.fetchById(id);

  @override
  Future<Supply> createSupply({
    required String category,
    required String label,
    required String unit,
    required double unitPrice,
  }) {
    return _dataSource.create(
      category: category,
      label: label,
      unit: unit,
      unitPrice: unitPrice,
    );
  }

  @override
  Future<Supply> updateSupply(Supply supply) => _dataSource.update(supply);

  @override
  Future<void> deleteSupply(String id) => _dataSource.delete(id);
}
