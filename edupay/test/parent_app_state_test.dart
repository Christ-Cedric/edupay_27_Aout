import 'package:edupay/features/parent/domain/auth_session.dart';
import 'package:edupay/features/parent/domain/parent_models.dart';
import 'package:edupay/features/parent/domain/parent_repository.dart';
import 'package:edupay/features/parent/domain/quota_engine.dart';
import 'package:edupay/features/parent/presentation/parent_app_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_catalogue.dart';

void main() {
  setUpAll(loadFakeCatalogue);

  test('a payment updates the saved amount and adds a receipt', () async {
    final state = ParentAppState(_Repository(), authSession: _AuthSession())
      ..children = const [
        ChildProfile(
          firstName: 'Awa',
          level: 'CM2',
          school: 'Centre',
          kitSelection: ChildKitSelection.standard(SchoolKit.basic),
          savedAmount: 100,
        ),
      ]
      ..plan = SavingsPlan.daily;

    final expectedInstallment = state.installmentAmount;
    await state.pay();

    expect(state.children.single.savedAmount, 100 + expectedInstallment);
    expect(state.contributions.single.amount, expectedInstallment);
    state.dispose();
  });

  test(
    'paying an exact multiple of the quota validates several quotas at once',
    () async {
      // Kit Basique (catalogue factice, 'CM2') = 12000 F. Quota figé à 2000 F.
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..children = const [
          ChildProfile(
            firstName: 'Awa',
            level: 'CM2',
            school: 'Centre',
            kitSelection: ChildKitSelection.standard(SchoolKit.basic),
            savedAmount: 0,
          ),
        ]
        ..plan = SavingsPlan.daily
        ..quotaState = QuotaState(
          quotaValue: 2000,
          subscriptionStartDate: DateTime.now(),
          frequency: SavingsPlan.daily,
        );

      // 12000 F = 6 quotas exactement (règle §3 : autant de quotas complets que
      // possible sont validés d'un coup).
      await state.pay(amount: 12000);

      expect(state.children.single.savedAmount, 12000);
      expect(state.quotasAcquired, 6);
      expect(state.pendingQuotaBalance, 0);
      // Le reçu affiche le montant réellement versé par le parent.
      expect(state.contributions.single.amount, 12000);
      state.dispose();
    },
  );

  test(
    'a payment smaller than the quota is held as a pending balance',
    () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..children = const [
          ChildProfile(
            firstName: 'Awa',
            level: 'CM2',
            school: 'Centre',
            kitSelection: ChildKitSelection.standard(SchoolKit.basic),
            savedAmount: 0,
          ),
        ]
        ..plan = SavingsPlan.daily
        ..quotaState = QuotaState(
          quotaValue: 2000,
          subscriptionStartDate: DateTime.now(),
          frequency: SavingsPlan.daily,
        );

      // Un paiement inférieur au quota crédite l'épargne (800 F) et conserve le solde de quota
      await state.pay(amount: 800);
      expect(state.children.single.savedAmount, 800);
      expect(state.quotasAcquired, 0);
      expect(state.pendingQuotaBalance, 800);

      // Le versement cumulé (800 + 1500 = 2300) complète 1 quota (2000 F),
      // avec un reliquat de 300 F, et l'épargne atteint 2300 F.
      await state.pay(amount: 1500);
      expect(state.children.single.savedAmount, 2300);
      expect(state.quotasAcquired, 1);
      expect(state.pendingQuotaBalance, 300);
      state.dispose();
    },
  );

  test('a kit funded at 75% or more is locked against changes', () async {
    // Kit Essentiel = 12000 ; 9000 = 75 % → verrouillé.
    final state = ParentAppState(_Repository(), authSession: _AuthSession())
      ..children = const [
        ChildProfile(
          firstName: 'Awa',
          level: 'CM2',
          school: 'Centre',
          kitSelection: ChildKitSelection.standard(SchoolKit.basic),
          savedAmount: 9000,
        ),
      ];

    expect(state.isKitLockedAt(0), isTrue);
    // Toute tentative de remplacement est ignorée.
    state.assignStandardKit(0, SchoolKit.complete);
    expect(state.children.single.kitSelection!.standardKit, SchoolKit.basic);
    // Laisse le _bootstrap asynchrone se terminer avant dispose (sinon il
    // appelle notifyListeners sur un notifier disposé).
    await Future<void>.delayed(Duration.zero);
    state.dispose();
  });

  test(
    'a child with any received payment is locked against kit changes',
    () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..children = const [
          ChildProfile(
            firstName: 'Awa',
            level: 'CM2',
            school: 'Centre',
            kitSelection: ChildKitSelection.standard(SchoolKit.basic),
            savedAmount: 100,
          ),
        ];

      expect(state.isKitLockedAt(0), isTrue);
      state.assignStandardKit(0, SchoolKit.complete);
      expect(state.children.single.kitSelection!.standardKit, SchoolKit.basic);
      await Future<void>.delayed(Duration.zero);
      state.dispose();
    },
  );

  test(
    'a child can be removed until it receives a contribution share',
    () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..signed = true
        ..children = const [
          // Ali a déjà reçu une part (savedAmount > 0) → verrouillé.
          ChildProfile(
            firstName: 'Ali',
            level: 'CM2',
            school: 'Centre',
            kitSelection: ChildKitSelection.standard(SchoolKit.basic),
            savedAmount: 3000,
          ),
          // Nouvel enfant, aucune part reçue → supprimable même après signature.
          ChildProfile(
            firstName: 'Biba',
            level: 'CE1',
            school: 'Centre',
            kitSelection: ChildKitSelection.standard(SchoolKit.basic),
            savedAmount: 0,
          ),
        ];

      expect(state.canRemoveChild(0), isFalse);
      expect(state.canRemoveChild(1), isTrue);

      await state.removeChild(1);
      expect(state.children.length, 1);
      expect(state.children.single.firstName, 'Ali');

      // Ali reste protégé.
      await state.removeChild(0);
      expect(state.children.length, 1);
      state.dispose();
    },
  );

  test('confirming receipt starts a fresh savings cycle', () async {
    final state = ParentAppState(_Repository(), authSession: _AuthSession())
      ..signed = true
      ..children = const [
        ChildProfile(
          firstName: 'Awa',
          level: 'CM2',
          school: 'Centre',
          kitSelection: ChildKitSelection.standard(SchoolKit.basic),
          savedAmount: 12000,
        ),
      ]
      ..contributions = const [
        Contribution(
          date: 'Aujourd’hui',
          method: 'Orange Money',
          reference: 'EP-RC-2026-0001',
          amount: 12000,
          success: true,
        ),
      ]
      ..quotaState = QuotaState(
        quotaValue: 2000,
        subscriptionStartDate: DateTime(2026, 1, 1),
        frequency: SavingsPlan.daily,
        quotasAcquired: 6,
      );

    await state.confirmDeliveryReceipt();

    // Compteurs à zéro, kits retirés, historique vidé, contrat à re-signer.
    expect(state.children.single.savedAmount, 0);
    expect(state.children.single.kitSelection, isNull);
    expect(state.contributions, isEmpty);
    expect(state.signed, isFalse);
    // L'enfant reste inscrit (même profil).
    expect(state.children.single.firstName, 'Awa');
    // Nouveau cycle => le quota figé de l'ancien cycle est effacé.
    expect(state.quotaState, isNull);
    state.dispose();
  });

  test(
    'confirmSubscriptionPlan freezes the quota once and never again',
    () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..children = const [
          ChildProfile(
            firstName: 'Awa',
            level: 'CM2',
            school: 'Centre',
            kitSelection: ChildKitSelection.standard(SchoolKit.basic),
            savedAmount: 0,
          ),
        ]
        ..plan = SavingsPlan.daily;

      await state.confirmSubscriptionPlan();
      final frozenQuota = state.quotaState;
      expect(frozenQuota, isNotNull);
      expect(state.installmentAmount, frozenQuota!.quotaValue);

      // Changer la fréquence (ex. depuis le profil) recalcule normalement
      // `savingsPlan.perPeriodAmount`, mais NE DOIT PAS re-figer le quota.
      state.selectPlan(SavingsPlan.monthly);
      await state.confirmSubscriptionPlan();

      expect(state.quotaState!.quotaValue, frozenQuota.quotaValue);
      state.dispose();
    },
  );

  test(
    'adding a new kit for a child recalculates the quota but keeps validated quotas',
    () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..children = const [
          ChildProfile(
            firstName: 'Awa',
            level: 'CM2',
            school: 'Centre',
            kitSelection: ChildKitSelection.standard(SchoolKit.basic),
            savedAmount: 0,
          ),
        ]
        ..plan = SavingsPlan.daily;

      await state.confirmSubscriptionPlan();
      final initialQuota = state.quotaState!.quotaValue;

      // Un quota est validé pour Awa avant tout nouveau kit.
      await state.pay(amount: initialQuota);
      expect(state.quotasAcquired, 1);
      final awaSavedBefore = state.children.single.savedAmount;

      // Un deuxième enfant est ajouté PUIS reçoit un kit : le montant total
      // des kits change => la prochaine confirmation doit recalculer.
      state.children = [
        ...state.children,
        const ChildProfile(
          firstName: 'Biba',
          level: 'CM2',
          school: 'Centre',
          savedAmount: 0,
        ),
      ];
      await state.confirmSubscriptionPlan();
      // Aucun kit pour Biba : le total n'a pas changé, pas de recalcul.
      expect(state.quotaState!.quotaValue, initialQuota);

      state.assignStandardKit(1, SchoolKit.comfort);
      await state.confirmSubscriptionPlan();

      // Le total des kits a changé => la valeur du quota est recalculée.
      expect(state.quotaState!.quotaValue, isNot(initialQuota));
      // Le quota déjà validé pour Awa reste définitivement acquis.
      expect(state.quotasAcquired, 1);
      expect(state.children.first.savedAmount, awaSavedBefore);
      state.dispose();
    },
  );

  test(
    'home loading does not replace a profile entered during onboarding',
    () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..profile = const ParentProfile(
          fullName: 'Profil local',
          phone: '1',
          city: 'Bobo',
          district: '10',
        );

      await state.loadHomeData();

      expect(state.profile!.fullName, 'Profil local');
      state.dispose();
    },
  );

  test(
    'USSD mobile money payment increments progress bar immediately and records successful contribution',
    () async {
      final state = ParentAppState(_Repository(), authSession: _AuthSession())
        ..children = const [
          ChildProfile(
            firstName: 'Awa',
            level: 'CM2',
            school: 'Centre',
            kitSelection: ChildKitSelection.standard(SchoolKit.basic),
            savedAmount: 0,
            kitSavedAmount: 0,
            tuitionAmount: 50000,
            tuitionSavedAmount: 0,
          ),
        ]
        ..paymentMethod = PaymentMethod.orangeMoney
        ..plan = SavingsPlan.daily;

      expect(state.progress, 0);
      expect(state.totalSaved, 0);

      // Paiement USSD de 5 000 F ciblant les fournitures (kit basic = 12 000 F)
      await state.pay(amount: 5000, targetGoalType: SavingsGoalType.supplies);

      // Vérifications immédiates :
      // 1. Statut de paiement réussi
      expect(state.paymentState.status, RequestStatus.success);
      // 2. Reçu enregistré comme réussi
      expect(state.contributions.first.success, isTrue);
      expect(state.contributions.first.amount, 5000);
      // 3. Montant épargné pour le kit et total incrémenté
      expect(state.children.single.kitSavedAmount, 5000);
      expect(state.children.single.savedAmount, 5000);
      expect(state.totalSaved, 5000);
      // 4. Progression incrémentée
      expect(state.progress, greaterThan(0));

      // 2ème paiement USSD de 7 000 F complétant les 12 000 F du kit
      await state.pay(amount: 7000, targetGoalType: SavingsGoalType.supplies);

      expect(state.children.single.kitSavedAmount, 12000);
      expect(state.children.single.savedAmount, 12000);
      expect(state.totalSaved, 12000);

      // 3ème paiement USSD de 10 000 F sur la scolarité (ne touche pas au kit)
      await state.pay(amount: 10000, targetGoalType: SavingsGoalType.registration);

      expect(state.children.single.kitSavedAmount, 12000);
      expect(state.children.single.tuitionSavedAmount, 10000);
      expect(state.children.single.savedAmount, 22000);
      expect(state.totalSaved, 22000);

      state.dispose();
    },
  );
}

class _Repository implements ParentRepository {
  @override
  Future<void> confirmSubscriptionPlan(String frequency, {String? signature}) async {}

  @override
  Future<List<ChildProfile>> getChildren() async => const [];

  @override
  Future<List<TransportVehicle>> getVehicles() async => const [];

  @override
  Future<AppSeason?> getCurrentSeason() async => null;

  @override
  Future<List<dynamic>> fetchKitsForClass(String classLabel) async => const [];

  @override
  Future<List<Contribution>> getContributions() async => const [];

  @override
  Future<ParentProfile> getProfile() async => const ParentProfile(
    fullName: 'Fake',
    phone: '0',
    city: 'Fake',
    district: '0',
  );

  @override
  Future<void> removeChild(ChildProfile child) async {}

  @override
  Future<Contribution> recordContribution(Contribution contribution) async =>
      contribution;

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
  Future<List<NotificationItem>> getNotifications() async => const [];

  @override
  Future<void> markNotificationRead(String id) async {}

  @override
  Future<RefundRequest> requestRefund({String? reason}) async =>
      RefundRequest(id: '1', reference: 'RMB-TEST', amount: 0, reason: reason ?? '', status: 'requested');
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
  Future<void> changePassword({
    required String current,
    required String next,
  }) async {}

  @override
  Future<List<ActiveSession>> listSessions() async => const [];

  @override
  Future<void> revokeSession(String id) async {}

  @override
  Future<void> revokeAllSessions() async {}
}
