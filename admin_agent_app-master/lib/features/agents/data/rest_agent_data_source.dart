import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/agent.dart';
import '../domain/models/agent_failure.dart';
import 'agent_data_source.dart';

Agent _parseAgent(Map<String, dynamic> json) {
  return Agent(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    phone: json['phone'] as String,
    zone: json['zone'] as String,
    district: json['district'] as String?,
    clientCount: json['client_count'] as int,
    commission: (json['commission'] as num).toDouble(),
    contractType: AgentContractType.values.byName(json['contract_type'] as String),
    status: AgentStatus.values.byName(json['status'] as String),
  );
}

/// Implémentation backend du seam [AgentDataSource] (endpoints `/admin/agents`,
/// contrat partagé §5.4).
class RestAgentDataSource implements AgentDataSource {
  const RestAgentDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<Agent>> fetchAll() async {
    final json = await _client.get(ApiRoutes.adminAgents);
    return (json['data'] as List).cast<Map<String, dynamic>>().map(_parseAgent).toList();
  }

  @override
  Future<Agent> create({
    required String fullName,
    required String phone,
    required String zone,
    String? district,
    required AgentContractType contractType,
    required String password,
  }) async {
    final json = await _client.post(
      ApiRoutes.adminAgents,
      body: {
        'full_name': fullName,
        'phone': phone,
        'zone': zone,
        'district': ?district,
        'contract_type': contractType.name,
        'password': password,
      },
    );
    return _parseAgent(json);
  }

  @override
  Future<Agent> fetchById(String id) async {
    try {
      final json = await _client.get(ApiRoutes.adminAgent(id));
      return _parseAgent(json);
    } on ApiException catch (e) {
      if (e.statusCode == 404) throw AgentFailure(e.message);
      rethrow;
    }
  }

  @override
  Future<Agent> suspend(String id) => _postStatus(ApiRoutes.adminSuspendAgent(id));

  @override
  Future<Agent> reactivate(String id) => _postStatus(ApiRoutes.adminReactivateAgent(id));

  Future<Agent> _postStatus(String path) async {
    try {
      final json = await _client.post(path);
      return _parseAgent(json);
    } on ApiException catch (e) {
      // 409 : transition invalide (déjà dans cet état) ; 404 : agent introuvable.
      if (e.statusCode == 409 || e.statusCode == 404) throw AgentFailure(e.message);
      rethrow;
    }
  }
}
