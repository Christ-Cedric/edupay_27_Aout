import '../../../../app/network/api_client.dart';
import '../../../../app/network/api_routes.dart';
import '../../domain/parent_models.dart';

/// Maps the REST contract to app models. It has no dependency on widgets and
/// can be exercised with a fake [ApiClient] before a real HTTP transport exists.
class ParentApiService {
  ParentApiService(this._client);

  final ApiClient _client;

  Map<String, String>? _kitLevelById;
  String? _lastDeliveryChildId;

  Future<ParentProfile> getProfile() async {
    // Try to fetch the richer family DTO (contains `family_code`) when available.
    try {
      final family = await _client.get(ApiRoutes.family);
      return ParentProfile.fromJson(family);
    } catch (_) {
      // Fallback to the lighter profile endpoint
      return ParentProfile.fromJson(await _client.get(ApiRoutes.profile));
    }
  }

  Future<List<ChildProfile>> getChildren() async {
    final response = await _client.get(ApiRoutes.children);
    await _loadKitLevels();
    final items = response['data'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) => _withBackendKit(
            ChildProfile.fromJson(item as Map<String, dynamic>),
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Contribution>> getContributions() async {
    final response = await _client.get(ApiRoutes.contributions);
    final items = response['data'] as List<dynamic>? ?? const [];
    return items
        .map((item) => Contribution.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ParentProfile> saveProfile(ParentProfile profile) async =>
      ParentProfile.fromJson(
        await _client.patch(
          ApiRoutes.profile,
          body: {
            'full_name': profile.fullName,
            'city': profile.city,
            'district': profile.district,
          },
        ),
      );

  Future<ChildProfile> saveChild(ChildProfile child) async {
    // Le backend renvoie la famille complète après création, et non l'enfant
    // isolé. On récupère donc sa représentation canonique dans cette réponse.
    final family = await _client.post(
      ApiRoutes.children,
      body: {
        'first_name': child.firstName,
        'level': child.level,
        'school': child.school,
      },
    );
    return _childFromFamily(family, firstName: child.firstName);
  }

  Future<ChildProfile> updateChild(ChildProfile child) async {
    final childId = _requireChildId(child);
    await _client.patch(
      ApiRoutes.child(childId),
      body: {'level': child.level, 'school': child.school},
    );
    await _assignKitIfSelected(childId, child.level, child.kitSelection);
    // Fetch the updated family to ensure the returned child has the correct kit goal
    final family = await _client.get(ApiRoutes.family);
    return _childFromFamily(family, id: childId);
  }

  Future<void> setChildTuition(String childId, int amount) async {
    await _client.post(
      '${ApiRoutes.child(childId)}/tuition',
      body: {'amount': amount},
    );
  }

  Future<void> setChildTransport(
    String childId,
    int amount,
    String? type,
  ) async {
    await _client.post(
      '${ApiRoutes.child(childId)}/transport',
      body: {'amount': amount, if (type != null) 'type': type},
    );
  }

  Future<void> removeChild(ChildProfile child) =>
      _client.delete(ApiRoutes.child(_requireChildId(child)));

  Future<void> confirmSubscriptionPlan(
    String frequency, {
    String? signature,
  }) async => _client.post(
    ApiRoutes.subscriptionConfirmation,
    body: {'frequency': frequency, 'signature': ?signature},
  );

  Future<Contribution> recordContribution(Contribution contribution) async {
    final body = {
      'amount': contribution.amount,
      // Les paiements self-service acceptent uniquement ces trois codes.
      'method': _paymentMethodCode(contribution.method),
      if (contribution.targetGoalType != null)
        'targetGoalType': contribution.targetGoalType,
    };
    // ignore: avoid_print
    print('[EduPay] 📤 POST ${ApiRoutes.contributions} body=$body');
    final response = await _client.post(ApiRoutes.contributions, body: body);
    // ignore: avoid_print
    print('[EduPay] 📥 Réponse serveur: $response');
    return Contribution.fromJson(response);
  }

  // ── Livraison ──────────────────────────────────────────
  Future<DeliveryOrder> getDelivery() async =>
      _deliveryFromResponse(await _client.get(ApiRoutes.delivery));

  Future<DeliveryOrder> sendDeliveryLocation({
    required double lat,
    required double lng,
    required String address,
  }) async => _deliveryFromResponse(
    await _client.post(
      ApiRoutes.deliveryLocation,
      body: {'lat': lat, 'lng': lng, 'address': address},
    ),
  );

  Future<DeliveryOrder> confirmDeliveryReceipt({String? signature}) async =>
      _deliveryFromResponse(
        await _client.post(
          ApiRoutes.deliveryConfirmReceipt,
          body: signature != null ? {'signature': signature} : null,
        ),
      );

  Future<void> reportDeliveryIssue({
    required DeliveryIssueType type,
    required String description,
    String? photoUrl,
  }) async {
    // L'API exige l'enfant concerné. L'écran actuel ne permet pas encore de
    // le sélectionner ; une livraison ne peut donc pas être signalée sans ce
    // contexte serveur.
    if (_lastDeliveryChildId == null) await getDelivery();
    final childId = _lastDeliveryChildId;
    if (childId == null)
      throw StateError(
        'Aucune livraison disponible pour signaler un problème.',
      );
    final body = <String, dynamic>{
      'child_id': childId,
      'type': type.backendCode,
      'description': description,
    };
    if (photoUrl != null) body['photo_url'] = photoUrl;
    await _client.post(ApiRoutes.deliveryIssues, body: body);
  }

  // ── Notifications ───────────────────────────────────────
  Future<List<NotificationItem>> getNotifications() async {
    final response = await _client.get(ApiRoutes.notifications);
    final items = response['data'] as List<dynamic>? ?? const [];
    return items
        .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationRead(String id) =>
      _client.patch(ApiRoutes.notificationRead(id));

  // ── Remboursements ─────────────────────────────────────
  /// Le montant et la référence de dossier sont déterminés côté serveur
  /// depuis la session (jamais recalculés côté client) — voir
  /// `RefundRequest`. Seul le motif est envoyé.
  Future<RefundRequest> requestRefund({String? reason}) async {
    final body = <String, dynamic>{
      'reason': reason?.trim().isNotEmpty == true
          ? reason!.trim()
          : 'Demande du parent',
    };
    final response = await _client.post(ApiRoutes.refunds, body: body);
    return RefundRequest.fromJson(response);
  }

  String _requireChildId(ChildProfile child) {
    final id = child.id;
    if (id == null || id.isEmpty) {
      throw StateError(
        'Identifiant serveur de l’enfant manquant. Rechargez vos données puis réessayez.',
      );
    }
    return id;
  }

  ChildProfile _childFromFamily(
    Map<String, dynamic> family, {
    String? id,
    String? firstName,
  }) {
    final children = family['children'] as List<dynamic>? ?? const [];
    Map<String, dynamic>? item;
    for (final value in children) {
      final child = value as Map<String, dynamic>;
      if (id != null ? child['id'] == id : child['first_name'] == firstName) {
        item = child;
        break;
      }
    }
    if (item == null)
      throw StateError(
        'La réponse du serveur ne contient pas l’enfant attendu.',
      );
    return ChildProfile.fromJson(item);
  }

  DeliveryOrder _deliveryFromResponse(Map<String, dynamic> response) {
    final deliveries = response['data'] as List<dynamic>? ?? const [];
    if (deliveries.isEmpty) throw StateError('Aucune livraison disponible.');
    final delivery = deliveries.first as Map<String, dynamic>;
    _lastDeliveryChildId = delivery['child_id'] as String?;
    return DeliveryOrder.fromJson(delivery);
  }

  String _paymentMethodCode(String method) => switch (method) {
    'Orange Money' => 'orangeMoney',
    'Moov Money' => 'moovMoney',
    // Le cash ne passe jamais par cette route self-service (contrat backend
    // §payments : `selfContributionSchema` n'accepte que orangeMoney/moovMoney/
    // wave, "le cash passe par l'agent") — échouer bruyamment plutôt que de
    // mentir en soumettant une méthode différente de celle choisie.
    _ => throw StateError(
      'La méthode "$method" ne peut pas être utilisée pour un paiement en ligne. '
      'Les paiements en espèces se font uniquement avec un agent.',
    ),
  };

  Future<void> _assignKitIfSelected(
    String childId,
    String level,
    ChildKitSelection? selection,
  ) async {
    if (selection == null) return;
    if (selection.type == KitSelectionType.custom) {
      throw UnsupportedError(
        'Le catalogue personnalisé local ne peut pas être envoyé au catalogue serveur. Choisissez un kit standard.',
      );
    }
    final expectedLevel = switch (selection.standardKit!) {
      SchoolKit.basic => 'basic',
      SchoolKit.comfort => 'intermediate',
      SchoolKit.complete => 'premium',
    };
    // Filtré par la classe de l'ENFANT (level_scope) : un même tarif
    // (basic/intermediate/premium) correspond à un kit différent — donc un
    // prix différent — par classe. Chercher dans tout le catalogue sans ce
    // filtre risquerait d'assigner le kit d'une autre classe.
    final kits = await fetchKitsForClass(level);
    String? kitId;
    for (final item in kits) {
      if (item is Map<String, dynamic> && item['level'] == expectedLevel) {
        kitId = item['id'] as String?;
        break;
      }
    }
    if (kitId == null) {
      throw StateError(
        'Le catalogue serveur ne contient pas le kit sélectionné pour la classe "$level".',
      );
    }
    await _client.post(ApiRoutes.childKit(childId), body: {'kit_id': kitId});
  }

  /// Kits standards (basic/intermediate/premium) réellement enregistrés côté
  /// backend pour [classLabel] — source de vérité du prix, à la place du
  /// catalogue statique embarqué (voir `SchoolCatalogue.applyBackendKits`).
  Future<List<dynamic>> fetchKitsForClass(String classLabel) async {
    final response = await _client.get(
      '${ApiRoutes.catalogKits}?level_scope=${Uri.encodeQueryComponent(classLabel)}',
    );
    return response['data'] as List<dynamic>? ?? const [];
  }

  Future<void> _loadKitLevels() async {
    if (_kitLevelById != null) return;
    final response = await _client.get(ApiRoutes.catalogKits);
    final kits = response['data'] as List<dynamic>? ?? const [];
    _kitLevelById = {
      for (final item in kits)
        if (item is Map<String, dynamic> &&
            item['id'] is String &&
            item['level'] is String)
          item['id'] as String: item['level'] as String,
    };
  }

  ChildProfile _withBackendKit(ChildProfile child, Map<String, dynamic> json) {
    final kitId = json['kit_id'] as String?;
    final level = kitId == null ? null : _kitLevelById?[kitId];
    final selection = switch (level) {
      'basic' => const ChildKitSelection.standard(SchoolKit.basic),
      'intermediate' => const ChildKitSelection.standard(SchoolKit.comfort),
      'premium' => const ChildKitSelection.standard(SchoolKit.complete),
      _ => child.kitSelection,
    };
    return ChildProfile(
      id: child.id,
      firstName: child.firstName,
      level: child.level,
      school: child.school,
      savedAmount: child.savedAmount,
      targetAmount: child.targetAmount,
      kitSelection: selection,
      tuitionAmount: child.tuitionAmount,
      tuitionSavedAmount: child.tuitionSavedAmount,
      transportAmount: child.transportAmount,
      transportSavedAmount: child.transportSavedAmount,
      transportType: child.transportType,
      kitSavedAmount: child.kitSavedAmount,
    );
  }
}
