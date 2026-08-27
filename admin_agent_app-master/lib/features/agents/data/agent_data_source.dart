import '../domain/models/agent.dart';

/// Contrat de source de données des agents — la couture (seam) qui permet de
/// basculer entre données mock ([FakeAgentDataSource]) et backend réel
/// ([RestAgentDataSource]) sans toucher au repository ni à l'UI.
///
/// Le [AgentRepository] dépend de cette interface, pas d'une implémentation
/// concrète. Le choix se fait au composition root (provider) selon
/// `AppEnvironment` (voir `docs/SHARED_API_CONTRACT.md`).
abstract interface class AgentDataSource {
  Future<List<Agent>> fetchAll();

  Future<Agent> create({
    required String fullName,
    required String phone,
    required String zone,
    String? district,
    required AgentContractType contractType,
    required String password,
  });

  Future<Agent> fetchById(String id);

  Future<Agent> suspend(String id);

  Future<Agent> reactivate(String id);
}
