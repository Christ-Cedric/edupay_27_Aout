import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/core/domain/burkina_city.dart';
import 'package:edupay_admin/features/agents/domain/models/agent.dart';
import 'package:edupay_admin/features/families/presentation/screens/direct_enrollment_screen.dart';

Agent _agent({
  required String name,
  required String zone,
  String? district,
}) => Agent(
  id: name,
  fullName: name,
  phone: '+22670000000',
  zone: zone,
  district: district,
  clientCount: 0,
  commission: 0,
  contractType: AgentContractType.volunteer,
  status: AgentStatus.active,
);

void main() {
  final ouagaCentre = _agent(
    name: 'Ouaga Centre',
    zone: 'Ouagadougou',
    district: 'Centre',
  );
  final ouagaBogodogo = _agent(
    name: 'Ouaga Bogodogo',
    zone: 'Ouagadougou',
    district: 'Bogodogo',
  );
  final koudougouAgent = _agent(name: 'Koudougou Agent', zone: 'Koudougou');

  final agents = [ouagaCentre, ouagaBogodogo, koudougouAgent];

  test('ville + quartier exacts → seul cet agent est proposé', () {
    final result = matchingAgents(agents, BurkinaCity.ouagadougou, 'Centre');
    expect(result, [ouagaCentre]);
  });

  test('quartier ne correspondant à aucun agent → repli sur la ville seule', () {
    final result = matchingAgents(
      agents,
      BurkinaCity.ouagadougou,
      'Quartier inconnu',
    );
    expect(result, containsAll([ouagaCentre, ouagaBogodogo]));
    expect(result, hasLength(2));
  });

  test('pas de quartier saisi → tous les agents de la ville', () {
    final result = matchingAgents(agents, BurkinaCity.ouagadougou, null);
    expect(result, containsAll([ouagaCentre, ouagaBogodogo]));
    expect(result, hasLength(2));
  });

  test('aucun agent dans cette ville → liste vide', () {
    final result = matchingAgents(agents, BurkinaCity.banfora, null);
    expect(result, isEmpty);
  });

  test('comparaison insensible à la casse et aux espaces', () {
    final result = matchingAgents(agents, BurkinaCity.ouagadougou, '  centre ');
    expect(result, [ouagaCentre]);
  });
}
