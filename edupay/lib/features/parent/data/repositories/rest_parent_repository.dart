import '../../domain/parent_models.dart';
import '../../domain/parent_repository.dart';
import '../services/parent_api_service.dart';

class RestParentRepository implements ParentRepository {
  const RestParentRepository(this._service);

  final ParentApiService _service;

  @override
  Future<void> confirmSubscriptionPlan(String frequency, {String? signature}) =>
      _service.confirmSubscriptionPlan(frequency, signature: signature);

  @override
  Future<List<ChildProfile>> getChildren() => _service.getChildren();

  @override
  Future<List<TransportVehicle>> getVehicles() => _service.getVehicles();

  @override
  Future<AppSeason?> getCurrentSeason() => _service.getCurrentSeason();

  @override
  Future<List<dynamic>> fetchKitsForClass(String classLabel) =>
      _service.fetchKitsForClass(classLabel);

  @override
  Future<List<Contribution>> getContributions() => _service.getContributions();

  @override
  Future<ParentProfile> getProfile() => _service.getProfile();

  @override
  Future<void> removeChild(ChildProfile child) => _service.removeChild(child);

  @override
  Future<Contribution> recordContribution(Contribution contribution) =>
      _service.recordContribution(contribution);

  @override
  Future<ChildProfile> saveChild(ChildProfile child) =>
      _service.saveChild(child);

  @override
  Future<ChildProfile> updateChild(ChildProfile child) =>
      _service.updateChild(child);

  @override
  Future<void> setChildTuition(String childId, int amount) =>
      _service.setChildTuition(childId, amount);

  @override
  Future<void> setChildTransport(String childId, int amount, String? type) =>
      _service.setChildTransport(childId, amount, type);

  @override
  Future<ParentProfile> saveProfile(ParentProfile profile) =>
      _service.saveProfile(profile);

  @override
  Future<DeliveryOrder> getDelivery() => _service.getDelivery();

  @override
  Future<DeliveryOrder> sendDeliveryLocation({
    required double lat,
    required double lng,
    required String address,
  }) => _service.sendDeliveryLocation(lat: lat, lng: lng, address: address);

  @override
  Future<DeliveryOrder> confirmDeliveryReceipt({String? signature}) =>
      _service.confirmDeliveryReceipt(signature: signature);

  @override
  Future<void> reportDeliveryIssue({
    required DeliveryIssueType type,
    required String description,
    String? photoUrl,
  }) => _service.reportDeliveryIssue(
    type: type,
    description: description,
    photoUrl: photoUrl,
  );

  @override
  Future<List<NotificationItem>> getNotifications() =>
      _service.getNotifications();

  @override
  Future<void> markNotificationRead(String id) =>
      _service.markNotificationRead(id);

  @override
  Future<RefundRequest> requestRefund({String? reason}) =>
      _service.requestRefund(reason: reason);
}
