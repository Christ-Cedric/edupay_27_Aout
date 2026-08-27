import 'package:edupay/app/router/app_router.dart';
import 'package:edupay/features/parent/domain/auth_session.dart';
import 'package:edupay/features/parent/domain/parent_models.dart';
import 'package:edupay/features/parent/domain/parent_repository.dart';
import 'package:edupay/features/parent/presentation/parent_app_state.dart';
import 'package:edupay/features/parent/presentation/parent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_catalogue.dart';

class _Repository implements ParentRepository {
  @override
  Future<void> confirmSubscriptionPlan(String frequency, {String? signature}) async {}
  @override
  Future<List<ChildProfile>> getChildren() async => const [];
  @override
  Future<List<dynamic>> fetchKitsForClass(String classLabel) async => const [];
  @override
  Future<List<Contribution>> getContributions() async => const [];
  @override
  Future<ParentProfile> getProfile() async =>
      const ParentProfile(fullName: 'Fake', phone: '0', city: 'Fake', district: '0');
  @override
  Future<void> removeChild(ChildProfile child) async {}
  @override
  Future<Contribution> recordContribution(Contribution contribution) async => contribution;
  @override
  Future<ChildProfile> saveChild(ChildProfile child) async => child;
  @override
  Future<ChildProfile> updateChild(ChildProfile child) async => child;
  @override
  Future<void> setChildTuition(String childId, int amount) async {}
  @override
  Future<void> setChildTransport(String childId, int amount, String? type) async {}
  @override
  Future<ParentProfile> saveProfile(ParentProfile profile) async => profile;
  @override
  Future<DeliveryOrder> getDelivery() async => DeliveryOrder(
        registrationDate: DateTime(2026, 6, 24),
        orderDate: DateTime(2026, 8, 10),
        status: DeliveryStatus.preparation,
      );
  @override
  Future<DeliveryOrder> sendDeliveryLocation({
    required double lat,
    required double lng,
    required String address,
  }) => getDelivery();
  @override
  Future<DeliveryOrder> confirmDeliveryReceipt({String? signature}) => getDelivery();
  @override
  Future<void> reportDeliveryIssue({
    required DeliveryIssueType type,
    required String description,
    String? photoUrl,
  }) async {}
  @override
  Future<RefundRequest> requestRefund({String? reason}) async =>
      RefundRequest(id: '1', reference: 'RMB-TEST', amount: 0, reason: reason ?? '', status: 'requested');
  @override
  Future<List<NotificationItem>> getNotifications() async => const [];
  @override
  Future<void> markNotificationRead(String id) async {}
}

class _FakeAuth implements AuthSession {
  @override
  Future<bool> restoreSession() async => false;
  @override
  void setSessionExpiredListener(void Function() listener) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

/// Only fails the test on a real exception — RenderFlex overflows at the fixed
/// test surface are layout noise, not the bug we're hunting.
void expectNoRealException(WidgetTester tester, String where) {
  final error = tester.takeException();
  if (error == null) return;
  final message = error.toString();
  if (message.contains('overflowed')) return; // ignore layout overflow
  fail('Exception at $where: $error');
}

void main() {
  setUpAll(loadFakeCatalogue);

  testWidgets('subscription routes navigate without a TypeError', (tester) async {
    tester.view.physicalSize = const Size(1400, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = ParentAppState(_Repository(), authSession: _FakeAuth());
    await tester.pump();
    state.authStatus = AuthStatus.authenticated;
    state.children = const [
      ChildProfile(firstName: 'Awa', level: 'CM2', school: 'École A', savedAmount: 0),
    ];

    final router = AppRouter.create(state);
    await tester.pumpWidget(
      ParentScope(state: state, child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
    expectNoRealException(tester, 'startup');

    const routes = [
      '/app/children',
      '/app/plan',
      '/app/plan/edit',
      '/app/children/kits',
      '/app/children/kits/custom/0',
      '/app/contract',
    ];
    for (final route in routes) {
      router.go(route);
      await tester.pumpAndSettle();
      expectNoRealException(tester, route);
    }

    // Assign a kit then walk to the contract + success screens.
    state.assignStandardKit(0, SchoolKit.comfort);
    state.setContractAgreed(true);
    router.go('/app/contract');
    await tester.pumpAndSettle();
    expectNoRealException(tester, 'contract signed');

    router.go('/app/plan-success');
    await tester.pumpAndSettle();
    expectNoRealException(tester, 'plan-success');
  });
}
