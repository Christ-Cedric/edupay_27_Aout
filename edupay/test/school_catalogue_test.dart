import 'package:edupay/features/parent/domain/parent_models.dart';
import 'package:edupay/features/parent/domain/school_catalogue.dart';
import 'package:edupay/features/parent/presentation/parent_app_state.dart';
import 'package:edupay/features/parent/domain/auth_session.dart';
import 'package:edupay/features/parent/domain/parent_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_catalogue.dart';

void main() {
  setUpAll(loadFakeCatalogue);

  group('SchoolCatalogue', () {
    test('isValidClass accepte exactement les classes du catalogue', () {
      expect(SchoolCatalogue.isValidClass('CM2'), isTrue);
      expect(SchoolCatalogue.isValidClass('cm2'), isFalse); // casse exacte
      expect(SchoolCatalogue.isValidClass('CM3'), isFalse); // classe inconnue
    });

    test('resolve un kit standard renvoie le prix/contenu de la classe', () {
      final resolved = SchoolCatalogue.resolve(
        'CM2',
        const ChildKitSelection.standard(SchoolKit.basic),
      );
      expect(resolved, isNotNull);
      expect(resolved!.price, 12000);
      expect(resolved.lineItems, isNotEmpty);
    });

    test('resolve renvoie null pour une classe inconnue', () {
      final resolved = SchoolCatalogue.resolve(
        'Inconnue',
        const ChildKitSelection.standard(SchoolKit.basic),
      );
      expect(resolved, isNull);
    });

    test('resolve un kit personnalisé additionne les articles choisis', () {
      final resolved = SchoolCatalogue.resolve(
        'CM2',
        const ChildKitSelection.custom({'cahiers': 2, 'stylos': 3}),
      );
      expect(resolved, isNotNull);
      // cahiers: 2 x 2000 = 4000 ; stylos: 3 x 250 = 750.
      expect(resolved!.price, 4000 + 750);
      expect(resolved.lineItems, hasLength(2));
    });

    test('articlesFor renvoie tous les articles de la classe', () {
      expect(SchoolCatalogue.articlesFor('CM2'), hasLength(3));
      expect(SchoolCatalogue.articlesFor('Inconnue'), isEmpty);
    });
  });

  group('ParentAppState.addChild — validation de la classe', () {
    test('refuse une classe absente du catalogue officiel', () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..childNameController.text = 'Awa'
        ..childLevelController.text = 'Classe Fantaisiste'
        ..childSchoolController.text = 'École A';

      final added = await state.addChild();

      expect(added, isFalse);
      expect(state.children, isEmpty);
      state.dispose();
    });

    test('accepte une classe exacte du catalogue officiel', () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..childNameController.text = 'Awa'
        ..childLevelController.text = 'CM2'
        ..childSchoolController.text = 'École A';

      final added = await state.addChild();

      expect(added, isTrue);
      expect(state.children.single.level, 'CM2');
      state.dispose();
    });
  });
}

class _Repository implements ParentRepository {
  @override
  Future<void> confirmSubscriptionPlan(String frequency, {String? signature}) async {}
  @override
  Future<List<ChildProfile>> getChildren() async => const [];
  @override
  Future<List<TransportVehicle>> getVehicles() async => const [];
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

class _AuthSession implements AuthSession {
  @override
  Future<void> requestOtp(String phone) async {}
  @override
  Future<void> requestPasswordReset(String phone) async {}
  @override
  Future<void> verifyOtp({required String phone, required String code}) async {}
  @override
  Future<void> resetPassword({required String newPassword}) async {}

  @override
  Future<String> register({
    required String fullName,
    required String city,
    required String district,
    required String password,
  }) async => 'active';
  @override
  Future<String> login({required String phone, required String password}) async => 'active';
  @override
  Future<bool> restoreSession() async => false;
  @override
  void setSessionExpiredListener(void Function() listener) {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> changePassword({required String current, required String next}) async {}
  @override
  Future<List<ActiveSession>> listSessions() async => const [];
  @override
  Future<void> revokeSession(String id) async {}
  @override
  Future<void> revokeAllSessions() async {}
}
