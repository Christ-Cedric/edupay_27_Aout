import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/agents/data/fake_agent_data_source.dart';
import 'package:edupay_admin/features/agents/domain/models/agent.dart';

void main() {
  test('fetchAll renvoie les agents du prototype (écran ad_ag)', () async {
    final agents = await FakeAgentDataSource().fetchAll();
    expect(agents, hasLength(3));
    expect(agents.map((a) => a.fullName), contains('Konate Ali'));
  });

  test(
    'create ajoute un agent volontaire par défaut sans clients ni commission',
    () async {
      final dataSource = FakeAgentDataSource();
      final agent = await dataSource.create(
        fullName: 'Test Agent',
        phone: '+226 00 00 00 00',
        zone: 'Koudougou',
        contractType: AgentContractType.paid,
        password: 'test123456',
      );

      expect(agent.clientCount, 0);
      expect(agent.commission, 0);
      expect(agent.contractType, AgentContractType.paid);

      final all = await dataSource.fetchAll();
      expect(all, hasLength(4));
    },
  );
}
