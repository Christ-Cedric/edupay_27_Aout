import '../domain/models/agent.dart';
import '../domain/models/agent_failure.dart';
import 'agent_data_source.dart';

/// Source de données en mémoire, seedée avec les agents du prototype
/// (écran `ad_ag`). Mode `mock` du seam [AgentDataSource].
class FakeAgentDataSource implements AgentDataSource {
  final List<Agent> _agents = [
    const Agent(
      id: 'agent-1',
      fullName: 'Konate Ali',
      phone: '+22670112233',
      zone: 'Koudougou',
      clientCount: 12,
      commission: 7200,
      contractType: AgentContractType.volunteer,
      status: AgentStatus.active,
    ),
    const Agent(
      id: 'agent-2',
      fullName: 'Ouedraogo B.',
      phone: '+22670112244',
      zone: 'Koudougou',
      clientCount: 9,
      commission: 5400,
      contractType: AgentContractType.volunteer,
      status: AgentStatus.active,
    ),
    const Agent(
      id: 'agent-3',
      fullName: 'Sana Wendyam',
      phone: '+22670112255',
      zone: 'Ouagadougou',
      clientCount: 11,
      commission: 6600,
      contractType: AgentContractType.paid,
      status: AgentStatus.active,
    ),
  ];

  @override
  Future<List<Agent>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_agents);
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
    await Future.delayed(const Duration(milliseconds: 500));
    final agent = Agent(
      id: 'agent-${_agents.length + 1}',
      fullName: fullName,
      phone: phone,
      zone: zone,
      district: district,
      clientCount: 0,
      commission: 0,
      contractType: contractType,
      status: AgentStatus.active,
    );
    _agents.add(agent);
    return agent;
  }

  @override
  Future<Agent> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _agents.firstWhere(
      (a) => a.id == id,
      orElse: () => throw AgentFailure('Agent introuvable : $id'),
    );
  }

  @override
  Future<Agent> suspend(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final agent = await fetchById(id);
    if (agent.status == AgentStatus.suspended) {
      throw const AgentFailure('Cet agent est déjà suspendu.');
    }
    return _replace(id, agent.copyWith(status: AgentStatus.suspended));
  }

  @override
  Future<Agent> reactivate(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final agent = await fetchById(id);
    if (agent.status == AgentStatus.active) {
      throw const AgentFailure('Cet agent est déjà actif.');
    }
    return _replace(id, agent.copyWith(status: AgentStatus.active));
  }

  Agent _replace(String id, Agent updated) {
    final index = _agents.indexWhere((a) => a.id == id);
    _agents[index] = updated;
    return updated;
  }
}
