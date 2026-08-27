import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/supply.dart';
import '../domain/models/supply_failure.dart';
import 'supply_data_source.dart';

Supply _parseSupply(Map<String, dynamic> json) {
  return Supply(
    id: json['id'] as String,
    category: json['category'] as String,
    label: json['label'] as String,
    unit: json['unit'] as String,
    unitPrice: (json['unit_price'] as num).toDouble(),
  );
}

/// Implémentation backend du seam [SupplyDataSource] (endpoints
/// `/admin/supplies`).
class RestSupplyDataSource implements SupplyDataSource {
  const RestSupplyDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<Supply>> fetchAll() async {
    final json = await _client.get(ApiRoutes.adminSupplies);
    return (json['data'] as List).cast<Map<String, dynamic>>().map(_parseSupply).toList();
  }

  @override
  Future<Supply> fetchById(String id) async {
    try {
      final json = await _client.get(ApiRoutes.adminSupply(id));
      return _parseSupply(json);
    } on ApiException catch (e) {
      if (e.statusCode == 404) throw SupplyFailure(e.message);
      rethrow;
    }
  }

  @override
  Future<Supply> create({
    required String category,
    required String label,
    required String unit,
    required double unitPrice,
  }) async {
    final json = await _client.post(
      ApiRoutes.adminSupplies,
      body: {
        'category': category,
        'label': label,
        'unit': unit,
        'unit_price': unitPrice.round(),
      },
    );
    return _parseSupply(json);
  }

  @override
  Future<Supply> update(Supply supply) async {
    final json = await _client.put(
      ApiRoutes.adminSupply(supply.id),
      body: {
        'category': supply.category,
        'label': supply.label,
        'unit': supply.unit,
        'unit_price': supply.unitPrice.round(),
      },
    );
    return _parseSupply(json);
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.delete(ApiRoutes.adminSupply(id));
    } on ApiException catch (e) {
      if (e.statusCode == 404) throw SupplyFailure(e.message);
      rethrow;
    }
  }
}
