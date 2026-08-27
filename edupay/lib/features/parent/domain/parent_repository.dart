import 'parent_models.dart';

abstract class ParentRepository {
  Future<ParentProfile> getProfile();
  Future<List<ChildProfile>> getChildren();

  /// Kits standards réels du backend pour une classe (voir
  /// `SchoolCatalogue.applyBackendKits`) — remplace le catalogue statique
  /// embarqué comme source du prix affiché/signé par le parent.
  Future<List<dynamic>> fetchKitsForClass(String classLabel);
  Future<List<Contribution>> getContributions();

  /// Persists profile changes.
  Future<ParentProfile> saveProfile(ParentProfile profile);

  /// Persists a child and returns the canonical server representation.
  Future<ChildProfile> saveChild(ChildProfile child);

  /// Updates an existing child (kit/level/school) on the backend. Upsert by
  /// first name: recreates it server-side if it is missing.
  Future<ChildProfile> updateChild(ChildProfile child);
  Future<void> setChildTuition(String childId, int amount);
  Future<void> setChildTransport(String childId, int amount, String? type);

  Future<void> removeChild(ChildProfile child);

  Future<void> confirmSubscriptionPlan(String frequency, {String? signature});

  Future<Contribution> recordContribution(Contribution contribution);

  // ── Livraison ──────────────────────────────────────────
  Future<DeliveryOrder> getDelivery();
  Future<DeliveryOrder> sendDeliveryLocation({
    required double lat,
    required double lng,
    required String address,
  });
  Future<DeliveryOrder> confirmDeliveryReceipt({String? signature});
  Future<void> reportDeliveryIssue({
    required DeliveryIssueType type,
    required String description,
    String? photoUrl,
  });

  // ── Notifications ───────────────────────────────────────
  Future<List<NotificationItem>> getNotifications();
  Future<void> markNotificationRead(String id);

  // ── Remboursements ─────────────────────────────────────
  Future<RefundRequest> requestRefund({String? reason});
}
