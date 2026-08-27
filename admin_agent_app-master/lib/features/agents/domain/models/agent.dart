import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent.freezed.dart';

enum AgentContractType { volunteer, paid }

extension AgentContractTypeLabel on AgentContractType {
  String get label => switch (this) {
    AgentContractType.volunteer => 'Volontaire (commission uniquement)',
    AgentContractType.paid => 'Rémunéré (indemnité fixe)',
  };
}

/// Statut de connexion d'un agent. Un agent créé par l'admin est toujours
/// actif immédiatement — seule la transition actif ↔ suspendu existe.
enum AgentStatus { active, suspended }

extension AgentStatusLabel on AgentStatus {
  String get label => switch (this) {
    AgentStatus.active => 'Actif',
    AgentStatus.suspended => 'Suspendu',
  };
}

/// Un agent terrain (motif `ad_ag`/`ad_na` du prototype).
@freezed
sealed class Agent with _$Agent {
  const factory Agent({
    required String id,
    required String fullName,
    required String phone,
    required String zone,
    String? district,
    required int clientCount,
    required double commission,
    required AgentContractType contractType,
    required AgentStatus status,
  }) = _Agent;
}
