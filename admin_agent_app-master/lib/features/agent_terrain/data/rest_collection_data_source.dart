import '../../../core/network/api_client.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/collection.dart';
import '../domain/models/collection_mode.dart';
import 'collection_data_source.dart';

CollectionAllocation _parseAllocation(Map<String, dynamic> a) {
  return CollectionAllocation(
    goalType: a['goal_type'] as String? ?? 'supplies',
    amount: (a['amount'] as num).toDouble(),
    childName: a['child_name'] as String?,
    goalName: a['goal_name'] as String?,
  );
}

Collection _parseCollection(Map<String, dynamic> c) {
  final rawAllocations = c['allocations'] as List? ?? const [];
  return Collection(
    id: c['id'] as String,
    familyId: c['family_id'] as String,
    familyName: c['family_name'] as String,
    agentName: c['agent_name'] as String? ?? '-',
    amount: (c['amount'] as num).toDouble(),
    mode: CollectionMode.values.byName(c['mode'] as String),
    collectedAt: DateTime.parse(c['collected_at'] as String),
    receiptNumber: c['receipt_number'] as String,
    targetGoalType: c['target_goal_type'] as String?,
    allocations: rawAllocations
        .cast<Map<String, dynamic>>()
        .map(_parseAllocation)
        .toList(),
  );
}

/// Implémentation backend du seam [CollectionDataSource] — consultation
/// Admin uniquement (l'encaissement se fait via
/// `RestFamilyDataSource.recordCashContribution`, `/admin/*`).
class RestCollectionDataSource implements CollectionDataSource {
  const RestCollectionDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<Collection>> fetchForFamily(String familyId) async {
    // Dossier famille Admin (« Historique cotisations », `showCollectionHistorySheet`).
    final json = await _client.get('/admin/families/$familyId/contributions');
    return (json['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(_parseCollection)
        .toList();
  }

  @override
  Future<List<Collection>> fetchAll() async {
    // Rapport « cotisations » (écran Rapports & exports) : toutes familles
    // confondues, endpoint `/admin/contributions`.
    final json = await _client.get(ApiRoutes.adminContributions);
    return (json['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(_parseCollection)
        .toList();
  }
}
