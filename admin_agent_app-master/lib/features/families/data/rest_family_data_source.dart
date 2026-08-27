import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/delivery_status.dart';
import '../domain/models/family.dart';
import '../domain/models/family_failure.dart';
import '../domain/models/family_filter.dart';
import '../domain/models/family_status.dart';
import '../domain/models/savings_plan.dart';
import 'family_data_source.dart';

FamilyChild _parseChild(Map<String, dynamic> json) {
  return FamilyChild(
    id: json['id'] as String,
    firstName: json['first_name'] as String,
    level: json['level'] as String,
    school: json['school'] as String,
    // Nuls tant qu'aucun kit n'a été choisi pour la saison en cours (état
    // normal en début de saison).
    kitId: json['kit_id'] as String?,
    targetAmount: (json['target_amount'] as num?)?.toDouble(),
    savedAmount: (json['saved_amount'] as num?)?.toDouble(),
  );
}

Family _parseFamily(Map<String, dynamic> json) {
  return Family(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    phone: json['phone'] as String,
    city: json['city'] as String,
    plan: SavingsPlan.values.byName(json['plan'] as String),
    balance: (json['balance'] as num).toDouble(),
    targetAmount: (json['target_amount'] as num).toDouble(),
    children: (json['children'] as List)
        .cast<Map<String, dynamic>>()
        .map(_parseChild)
        .toList(),
    status: FamilyStatus.values.byName(json['status'] as String),
    deliveryStatus: DeliveryStatus.values.byName(json['delivery_status'] as String),
    registeredAt: DateTime.parse(json['registered_at'] as String),
    assignedAgentName: json['assigned_agent_name'] as String?,
    rejectionReason: json['rejection_reason'] as String?,
    district: json['district'] as String?,
  );
}

/// Implémentation backend du seam [FamilyDataSource] (endpoints
/// `/admin/families`, contrat partagé §5.4).
class RestFamilyDataSource implements FamilyDataSource {
  const RestFamilyDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<Family>> fetchAll(FamilyFilter filter) async {
    final json = await _client.get(
      ApiRoutes.adminFamilies,
      query: {
        if (filter.query.isNotEmpty) 'search': filter.query,
        if (filter.status != null) 'status': filter.status!.name,
        if (filter.city != null) 'city': filter.city,
      },
    );
    final families = (json['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(_parseFamily)
        .toList();

    // `assignedAgentName` n'est pas un filtre supporté côté serveur (utilisé
    // uniquement par les écrans Agent terrain, hors périmètre) : appliqué
    // côté client pour rester correct si un jour sollicité.
    if (filter.assignedAgentName == null) return families;
    return families
        .where((f) => f.assignedAgentName == filter.assignedAgentName)
        .toList();
  }

  @override
  Future<Family> fetchById(String id) async {
    final json = await _client.get(ApiRoutes.adminFamily(id));
    return _parseFamily(json);
  }

  /// Résout le nom d'agent affiché (issu du menu déroulant, alimenté par
  /// [agentsListProvider]) vers son id serveur, requis par l'API. Renvoie
  /// `null` si aucune correspondance ou si aucun agent n'est assigné (le
  /// backend accepte une famille sans agent).
  Future<String?> _resolveAgentId(String? assignedAgentName) async {
    if (assignedAgentName == null) return null;
    final json = await _client.get(ApiRoutes.adminAgents);
    final agents = (json['data'] as List).cast<Map<String, dynamic>>();
    for (final agent in agents) {
      if (agent['full_name'] == assignedAgentName) {
        return agent['id'] as String;
      }
    }
    return null;
  }

  @override
  Future<Family> enroll({
    required String fullName,
    required String phone,
    required SavingsPlan plan,
    required List<ChildEnrollmentInput> children,
    String? assignedAgentName,
    required String city,
    String? district,
  }) async {
    final agentId = await _resolveAgentId(assignedAgentName);
    final json = await _client.post(
      ApiRoutes.adminFamilies,
      body: {
        'full_name': fullName,
        'phone': phone,
        'plan': plan.name,
        'children': children
            .map(
              (c) => {
                'first_name': c.firstName,
                'level': ?c.level,
                'school': ?c.school,
                'kit_id': c.kitId,
              },
            )
            .toList(),
        'assigned_agent_id': ?agentId,
        'city': city,
        'district': ?district,
      },
    );
    return _parseFamily(json);
  }

  @override
  Future<void> approve(String id) async {
    await _client.post(ApiRoutes.adminApproveFamily(id));
  }

  @override
  Future<void> reject(String id, String reason) async {
    await _client.post(ApiRoutes.adminRejectFamily(id), body: {'reason': reason});
  }

  @override
  Future<void> reportIncident(String familyId, String note) async {
    await _client.post(ApiRoutes.adminFamilyIncident(familyId), body: {'note': note});
  }

  @override
  Future<Family> recordCashContribution({
    required String familyId,
    required int amount,
    String? collectedByAgentId,
  }) async {
    try {
      await _client.post(
        ApiRoutes.adminFamilyContributions(familyId),
        body: {
          'amount': amount,
          'collected_by_agent_id': ?collectedByAgentId,
        },
      );
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 403 || e.statusCode == 409) {
        throw FamilyFailure(e.message);
      }
      rethrow;
    }
    // Le solde à jour vit sur la famille, pas sur la cotisation créée :
    // on relit le dossier plutôt que de reconstituer le calcul côté client.
    return fetchById(familyId);
  }

  @override
  Future<Family> addChild({
    required String familyId,
    required String firstName,
    String? level,
    String? school,
  }) async {
    final json = await _client.post(
      ApiRoutes.adminFamilyChildren(familyId),
      body: {'first_name': firstName, 'level': ?level, 'school': ?school},
    );
    return _parseFamily(json);
  }

  @override
  Future<Family> updateChild({
    required String familyId,
    required String childId,
    String? level,
    String? school,
  }) async {
    final json = await _client.patch(
      ApiRoutes.adminFamilyChild(familyId, childId),
      body: {'level': ?level, 'school': ?school},
    );
    return _parseFamily(json);
  }

  @override
  Future<Family> removeChild({required String familyId, required String childId}) async {
    try {
      await _client.delete(ApiRoutes.adminFamilyChild(familyId, childId));
    } on ApiException catch (e) {
      if (e.statusCode == 409) throw FamilyFailure(e.message);
      rethrow;
    }
    return fetchById(familyId);
  }

  @override
  Future<Family> assignKit({
    required String familyId,
    required String childId,
    required String kitId,
  }) async {
    try {
      final json = await _client.post(
        ApiRoutes.adminAssignChildKit(familyId, childId),
        body: {'kit_id': kitId},
      );
      return _parseFamily(json);
    } on ApiException catch (e) {
      if (e.statusCode == 400) throw FamilyFailure(e.message);
      rethrow;
    }
  }
}
