import '../domain/models/agent.dart';

abstract interface class AgentRepository {
  Future<List<Agent>> getAgents();

  Future<Agent> createAgent({
    required String fullName,
    required String phone,
    required String zone,
    String? district,
    required AgentContractType contractType,
    required String password,
  });

  Future<Agent> getAgentById(String id);

  Future<Agent> suspendAgent(String id);

  Future<Agent> reactivateAgent(String id);
}
