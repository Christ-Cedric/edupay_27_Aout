import '../../../core/domain/school_level.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/kit.dart';
import '../domain/models/kit_failure.dart';
import 'kit_data_source.dart';

KitItem _parseKitItem(Map<String, dynamic> json) {
  return KitItem(
    category: json['category'] as String,
    label: json['label'] as String,
    quantity: json['quantity'] as int,
    unit: json['unit'] as String,
    unitPrice: (json['unit_price'] as num).toDouble(),
  );
}

Map<String, dynamic> _kitItemToJson(KitItem item) => {
  'category': item.category,
  'label': item.label,
  'quantity': item.quantity,
  'unit': item.unit,
  'unit_price': item.unitPrice.round(),
};

Kit _parseKit(Map<String, dynamic> json) {
  return Kit(
    id: json['id'] as String,
    level: KitLevel.values.byName(json['level'] as String),
    // Chaîne libre côté backend (pas d'enum serveur) — `null` improbable en
    // pratique (le formulaire impose toujours une classe), retombe sur la
    // première pour ne jamais planter sur une donnée historique incomplète.
    schoolLevel:
        schoolLevelFromLabel(json['level_scope'] as String) ??
        SchoolLevel.values.first,
    price: (json['price'] as num).toDouble(),
    items: (json['items'] as List)
        .cast<Map<String, dynamic>>()
        .map(_parseKitItem)
        .toList(),
  );
}

/// Implémentation backend du seam [KitDataSource] (endpoints `/admin/kits`,
/// contrat partagé §5.4). `price` est toujours dérivé des fournitures côté
/// serveur — jamais envoyé par l'app.
class RestKitDataSource implements KitDataSource {
  const RestKitDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<Kit>> fetchAll() async {
    final json = await _client.get(ApiRoutes.adminKits);
    return (json['data'] as List).cast<Map<String, dynamic>>().map(_parseKit).toList();
  }

  @override
  Future<Kit> fetchById(String id) async {
    try {
      final json = await _client.get(ApiRoutes.adminKit(id));
      return _parseKit(json);
    } on ApiException catch (e) {
      if (e.statusCode == 404) throw KitFailure(e.message);
      rethrow;
    }
  }

  @override
  Future<Kit> create({
    required KitLevel level,
    required SchoolLevel schoolLevel,
    required List<KitItem> items,
  }) async {
    final json = await _client.post(
      ApiRoutes.adminKits,
      body: {
        'level': level.name,
        'level_scope': schoolLevel.label,
        'items': items.map(_kitItemToJson).toList(),
      },
    );
    return _parseKit(json);
  }

  @override
  Future<Kit> update(Kit kit) async {
    final json = await _client.put(
      ApiRoutes.adminKit(kit.id),
      body: {
        'level': kit.level.name,
        'level_scope': kit.schoolLevel.label,
        'items': kit.items.map(_kitItemToJson).toList(),
      },
    );
    return _parseKit(json);
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.delete(ApiRoutes.adminKit(id));
    } on ApiException catch (e) {
      // 409 : encore assigné à des familles (le repository fait déjà ce
      // contrôle en amont ; ce filet couvre une course éventuelle). 404 : déjà
      // supprimé. Dans les deux cas, message propre plutôt que la
      // représentation brute d'ApiException affichée à l'écran.
      if (e.statusCode == 409 || e.statusCode == 404) throw KitFailure(e.message);
      rethrow;
    }
  }

  @override
  Future<KitImportResult> importCatalog(String fileBase64) async {
    try {
      final json = await _client.post(
        ApiRoutes.adminKitsImport,
        body: {'file_base64': fileBase64},
      );
      return KitImportResult(
        created: json['created'] as int,
        updated: json['updated'] as int,
        warnings: (json['warnings'] as List).cast<String>(),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 400) throw KitFailure(e.message);
      rethrow;
    }
  }
}
