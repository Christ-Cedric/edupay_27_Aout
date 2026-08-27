import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/agent_data_source.dart';
import '../../data/agent_repository.dart';
import '../../data/agent_repository_impl.dart';
import '../../data/fake_agent_data_source.dart';
import '../../data/rest_agent_data_source.dart';
import '../../domain/models/agent.dart';

part 'agents_providers.g.dart';

/// Composition root de la feature : choisit la source de données selon
/// l'environnement. Mock par défaut (aucun backend requis).
@Riverpod(keepAlive: true)
AgentDataSource agentDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeAgentDataSource();
  }
  return RestAgentDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
AgentRepository agentRepository(Ref ref) {
  return AgentRepositoryImpl(ref.watch(agentDataSourceProvider));
}

@riverpod
Future<List<Agent>> agentsList(Ref ref) {
  return ref.watch(agentRepositoryProvider).getAgents();
}

@riverpod
Future<Agent> agentDetail(Ref ref, String id) {
  return ref.watch(agentRepositoryProvider).getAgentById(id);
}

@riverpod
class NewAgentController extends _$NewAgentController {
  @override
  FutureOr<Agent?> build() => null;

  Future<void> create({
    required String fullName,
    required String phone,
    required String password,
    required String zone,
    String? district,
    required AgentContractType contractType,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final agent = await ref
          .read(agentRepositoryProvider)
          .createAgent(
            fullName: fullName,
            phone: phone,
            zone: zone,
            district: district,
            contractType: contractType,
            password: password,
          );
      // Invalidé dès la création de l'agent : si l'enregistrement du
      // compte de connexion échoue juste après, la liste doit quand même
      // refléter l'agent nouvellement créé plutôt que de rester périmée
      // pendant que l'UI affiche une erreur.
      ref.invalidate(agentsListProvider);
      await ref
          .read(authRepositoryProvider)
          .registerAccount(
            phone: phone,
            displayName: fullName,
            password: password,
            role: UserRole.agent,
          );
      return agent;
    });
  }
}

/// Suspend/réactive un agent (dossier détail agent).
@riverpod
class AgentStatusController extends _$AgentStatusController {
  @override
  FutureOr<void> build() {}

  Future<void> suspend(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(agentRepositoryProvider).suspendAgent(id);
      ref.invalidate(agentsListProvider);
      ref.invalidate(agentDetailProvider(id));
    });
  }

  Future<void> reactivate(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(agentRepositoryProvider).reactivateAgent(id);
      ref.invalidate(agentsListProvider);
      ref.invalidate(agentDetailProvider(id));
    });
  }
}
