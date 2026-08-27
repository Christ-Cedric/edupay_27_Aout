import '../domain/models/supply.dart';
import '../domain/models/supply_failure.dart';
import 'supply_data_source.dart';

/// Source de données en mémoire — quelques fournitures d'exemple. Mode
/// `mock` du seam [SupplyDataSource].
class FakeSupplyDataSource implements SupplyDataSource {
  final List<Supply> _supplies = [
    const Supply(
      id: 'supply-1',
      category: 'Cahiers & Écriture',
      label: 'Cahier 192 pages',
      unit: 'unité',
      unitPrice: 800,
    ),
    const Supply(
      id: 'supply-2',
      category: 'Écriture',
      label: 'Stylo bille bleu',
      unit: 'unité',
      unitPrice: 150,
    ),
    const Supply(
      id: 'supply-3',
      category: 'Géométrie',
      label: 'Équerre',
      unit: 'unité',
      unitPrice: 500,
    ),
  ];

  @override
  Future<List<Supply>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_supplies);
  }

  @override
  Future<Supply> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _supplies.firstWhere(
      (s) => s.id == id,
      orElse: () => throw SupplyFailure('Fourniture introuvable : $id'),
    );
  }

  @override
  Future<Supply> create({
    required String category,
    required String label,
    required String unit,
    required double unitPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final supply = Supply(
      id: 'supply-${_supplies.length + 1}',
      category: category,
      label: label,
      unit: unit,
      unitPrice: unitPrice,
    );
    _supplies.add(supply);
    return supply;
  }

  @override
  Future<Supply> update(Supply supply) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _supplies.indexWhere((s) => s.id == supply.id);
    if (index != -1) _supplies[index] = supply;
    return supply;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _supplies.removeWhere((s) => s.id == id);
  }
}
