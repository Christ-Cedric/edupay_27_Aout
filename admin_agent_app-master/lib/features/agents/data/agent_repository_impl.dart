import '../domain/models/agent.dart';
import 'agent_data_source.dart';
import 'agent_repository.dart';

class AgentRepositoryImpl implements AgentRepository {
  AgentRepositoryImpl(this._dataSource);

  final AgentDataSource _dataSource;

  @override
  Future<List<Agent>> getAgents() => _dataSource.fetchAll();

  @override
  Future<Agent> createAgent({
    required String fullName,
    required String phone,
    required String zone,
    String? district,
    required AgentContractType contractType,
    required String password,
  }) {
    return _dataSource.create(
      fullName: fullName,
      phone: phone,
      zone: zone,
      district: district,
      contractType: contractType,
      password: password,
    );
  }

  @override
  Future<Agent> getAgentById(String id) => _dataSource.fetchById(id);

  @override
  Future<Agent> suspendAgent(String id) => _dataSource.suspend(id);

  @override
  Future<Agent> reactivateAgent(String id) => _dataSource.reactivate(id);
}
