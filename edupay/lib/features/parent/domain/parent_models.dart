enum SavingsPlan { daily, weekly, monthly }

/// Les 3 paliers de kit du fichier Excel officiel (colonnes « Kit Basique »,
/// « Kit Essentiel », « Kit Premium »). Le nom du palier est fixe (il n'y en a
/// que 3, structurellement) ; en revanche son CONTENU et son PRIX dépendent de
/// la classe de l'enfant et viennent exclusivement du catalogue
/// ([SchoolCatalogue] dans `school_catalogue.dart`) — voir [ChildKitResolution].
enum SchoolKit { basic, comfort, complete }

enum SavingsGoalType {
  supplies,
  registration,
  exam,
  transport,
  canteen,
  uniform,
}

extension SavingsGoalTypeExt on SavingsGoalType {
  String get title => switch (this) {
    SavingsGoalType.supplies => 'Fournitures',
    SavingsGoalType.registration => 'Scolarité',
    SavingsGoalType.exam => 'Examen',
    SavingsGoalType.transport => 'Déplacement',
    SavingsGoalType.canteen => 'Cantine',
    SavingsGoalType.uniform => 'Tenue',
  };

  String get backendCode => name;
}

extension SchoolKitLabel on SchoolKit {
  String get title => switch (this) {
    SchoolKit.basic => 'Kit Basique',
    SchoolKit.comfort => 'Kit Essentiel',
    SchoolKit.complete => 'Kit Premium',
  };
}

enum KitSelectionType { standard, custom }

/// L'intention de choix de kit d'un enfant : soit un des 3 paliers standards,
/// soit un ensemble d'articles choisis à la carte (identifiés par leur [id]
/// dans le catalogue de la classe de l'enfant). Ce type ne porte AUCUN prix ni
/// contenu détaillé : ceux-ci dépendent de la classe et sont résolus via
/// `SchoolCatalogue.resolve` / `ChildProfile.resolvedKit` (school_catalogue.dart).
class ChildKitSelection {
  const ChildKitSelection.standard(SchoolKit kit)
    : type = KitSelectionType.standard,
      standardKit = kit,
      customItemIds = const {};

  const ChildKitSelection.custom(Map<String, int> items)
    : type = KitSelectionType.custom,
      standardKit = null,
      customItemIds = items;

  final KitSelectionType type;
  final SchoolKit? standardKit;

  /// Quantités par identifiant d'article du catalogue (clé = [CatalogueArticle.id]).
  final Map<String, int> customItemIds;

  /// Titre indépendant de la classe (nom du palier, ou « Kit personnalisé »).
  /// Pour le prix/contenu détaillé, voir [ChildKitResolution.resolvedKit].
  String get title => switch (type) {
    KitSelectionType.standard => standardKit!.title,
    KitSelectionType.custom => 'Kit personnalisé',
  };

  factory ChildKitSelection.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'standard';
    if (type == 'custom') {
      final items = (json['items'] as List<dynamic>? ?? const [])
          .map((item) => item as Map<String, dynamic>)
          .fold<Map<String, int>>({}, (map, item) {
            final articleId = item['article_id'] as String?;
            if (articleId != null) {
              map[articleId] = (item['quantity'] as num? ?? 1).toInt();
            }
            return map;
          });
      return ChildKitSelection.custom(items);
    }
    return ChildKitSelection.standard(
      SchoolKit.values.byName(
        json['kit_id'] as String? ?? SchoolKit.comfort.name,
      ),
    );
  }

  Map<String, dynamic> toJson() => switch (type) {
    KitSelectionType.standard => {
      'type': 'standard',
      'kit_id': standardKit!.name,
    },
    KitSelectionType.custom => {
      'type': 'custom',
      'items': customItemIds.entries
          .map((entry) => {'article_id': entry.key, 'quantity': entry.value})
          .toList(),
    },
  };
}

enum PaymentMethod { orangeMoney, moovMoney, cashAgent }

String ussdCodeFor(PaymentMethod method, int amount) {
  if (amount <= 0) {
    throw ArgumentError.value(amount, 'amount', 'must be greater than zero');
  }
  return switch (method) {
    PaymentMethod.orangeMoney => '*144*10*541515907*$amount#',
    PaymentMethod.moovMoney => '*555*1*2*72006904*$amount#',
    PaymentMethod.cashAgent => throw ArgumentError(
      'Cash payment has no USSD code.',
    ),
  };
}

/// Seuil de verrouillage d'un kit : dès qu'un kit atteint cette part de son
/// financement (75 %), il ne peut plus être modifié, remplacé ni supprimé, afin
/// de garantir la stabilité de la commande avant sa finalisation.
const double kKitLockThreshold = 0.75;

class ParentProfile {
  const ParentProfile({
    required this.fullName,
    required this.phone,
    required this.city,
    required this.district,
    this.familyCode,
    this.status,
  });

  final String fullName;
  final String phone;
  final String city;
  final String district;
  final String? familyCode;

  /// Statut du compte (`pendingValidation`/`active`/`rejected`/`suspended`,
  /// ou dérivé `lateOverdue` selon l'endpoint) — sert uniquement à détecter
  /// la transition `pendingValidation` → `active` (voir `AuthStatus.pendingApproval`).
  final String? status;

  /// Contenu brut du QR — le code famille tel quel, sans enrobage JSON.
  /// Doit rester strictement identique au format que génère l'app agent
  /// (`AgQrCodeClientScreen._qrData`) : c'est ce texte brut que le scanner
  /// agent (`ag_qr_scanner_screen.dart::_processQrData`) reconnaît nativement,
  /// sans dépendre du chemin de repli JSON.
  String get qrPayload => familyCode ?? '';

  factory ParentProfile.fromJson(Map<String, dynamic> json) => ParentProfile(
    fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    city: json['city'] as String? ?? '',
    district: json['district'] as String? ?? '',
    familyCode:
        (json['familyCode'] as String?) ?? (json['family_code'] as String?),
    status: json['status'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'phone': phone,
    'city': city,
    'district': district,
  };
}

class ChildProfile {
  const ChildProfile({
    this.id,
    required this.firstName,
    required this.level,
    required this.school,
    required this.savedAmount,
    this.targetAmount,
    this.kitSelection,
    this.kitSavedAmount = 0,
    this.tuitionAmount = 0,
    this.tuitionSavedAmount = 0,
    this.transportAmount = 0,
    this.transportSavedAmount = 0,
    this.transportType,
  });

  /// Identifiant opaque attribué par le backend. Il est indispensable pour
  /// modifier/supprimer l'enfant : le prénom n'est pas une clé API.
  final String? id;
  final String firstName;
  final String level;
  final String school;

  /// Null until Étape 2 of the subscription flow assigns a kit to this
  /// child — a child can exist (and be listed under "Mes enfants") before
  /// any kit or plan decision is made.
  final ChildKitSelection? kitSelection;
  final int savedAmount; // Global saved amount

  /// Objectif calculé côté serveur pour le kit de cet enfant
  final int? targetAmount;
  final int kitSavedAmount;

  /// Objectif scolarité (frais de scolarité saisis par le parent).
  final int tuitionAmount;
  final int tuitionSavedAmount;

  /// Objectif moyen de déplacement (montant saisi par le parent).
  final int transportAmount;
  final int transportSavedAmount;

  /// Type de moyen de déplacement (ex: Vélo, Moto, Transport scolaire...).
  final String? transportType;

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    id: json['id'] as String?,
    firstName:
        json['firstName'] as String? ?? json['first_name'] as String? ?? '',
    level: json['level'] as String? ?? '',
    school: json['school'] as String? ?? '',
    kitSelection: json['kit_selection'] != null
        ? ChildKitSelection.fromJson(
            json['kit_selection'] as Map<String, dynamic>,
          )
        : null,
    savedAmount:
        (json['savedAmount'] as num? ?? json['saved_amount'] as num? ?? 0)
            .toInt(),
    targetAmount:
        (json['targetAmount'] as num? ?? json['target_amount'] as num?)
            ?.toInt(),
    kitSavedAmount:
        (json['kitSavedAmount'] as num? ??
                json['kit_saved_amount'] as num? ??
                0)
            .toInt(),
    tuitionAmount:
        (json['tuitionAmount'] as num? ?? json['tuition_amount'] as num? ?? 0)
            .toInt(),
    tuitionSavedAmount:
        (json['tuitionSavedAmount'] as num? ??
                json['tuition_saved_amount'] as num? ??
                0)
            .toInt(),
    transportAmount:
        (json['transportAmount'] as num? ??
                json['transport_amount'] as num? ??
                0)
            .toInt(),
    transportSavedAmount:
        (json['transportSavedAmount'] as num? ??
                json['transport_saved_amount'] as num? ??
                0)
            .toInt(),
    transportType:
        json['transportType'] as String? ?? json['transport_type'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'level': level,
    'school': school,
    'kit_selection': kitSelection?.toJson(),
    'saved_amount': savedAmount,
    if (targetAmount != null) 'target_amount': targetAmount,
    'kit_saved_amount': kitSavedAmount,
    'tuition_amount': tuitionAmount,
    'tuition_saved_amount': tuitionSavedAmount,
    'transport_amount': transportAmount,
    'transport_saved_amount': transportSavedAmount,
    if (transportType != null) 'transport_type': transportType,
  };

  ChildProfile copyWith({
    int? savedAmount,
    int? targetAmount,
    int? kitSavedAmount,
    ChildKitSelection? kitSelection,
    int? tuitionAmount,
    int? tuitionSavedAmount,
    int? transportAmount,
    int? transportSavedAmount,
    String? transportType,
  }) => ChildProfile(
    id: id,
    firstName: firstName,
    level: level,
    school: school,
    kitSelection: kitSelection ?? this.kitSelection,
    savedAmount: savedAmount ?? this.savedAmount,
    targetAmount: targetAmount ?? this.targetAmount,
    kitSavedAmount: kitSavedAmount ?? this.kitSavedAmount,
    tuitionAmount: tuitionAmount ?? this.tuitionAmount,
    tuitionSavedAmount: tuitionSavedAmount ?? this.tuitionSavedAmount,
    transportAmount: transportAmount ?? this.transportAmount,
    transportSavedAmount: transportSavedAmount ?? this.transportSavedAmount,
    transportType: transportType ?? this.transportType,
  );
}

/// One child's share of a [Contribution], recorded from the prorata split
/// computed at payment time so per-child contribution history stays
/// available (Étape 5 de BUSINESS_RULES.md).
/// Demande de remboursement telle que renvoyée par le backend
/// (`POST /parents/me/refunds`) — `amount`/`reference` sont TOUJOURS calculés
/// côté serveur (solde disponible − frais de saison), jamais par le client :
/// ne jamais les recalculer localement pour l'affichage (contrat §, voir
/// `refunds.service.ts::requestRefund`).
class RefundRequest {
  const RefundRequest({
    required this.id,
    required this.reference,
    required this.amount,
    required this.reason,
    required this.status,
  });

  final String id;
  final String reference;
  final int amount;
  final String reason;
  final String status;

  factory RefundRequest.fromJson(Map<String, dynamic> json) => RefundRequest(
    id: json['id'] as String? ?? '',
    reference: json['reference'] as String? ?? '',
    amount: (json['amount'] as num? ?? 0).toInt(),
    reason: json['reason'] as String? ?? '',
    status: json['status'] as String? ?? 'requested',
  );
}

/// Notification serveur réelle (`GET /parents/me/notifications`) — titre/corps
/// déjà rédigés côté backend (français, prêts à l'affichage), `type` sert
/// uniquement à choisir une icône/tonalité côté client (voir
/// `notifications.service.ts::NotificationType`).
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        readAt: (json['read_at'] as String?) != null
            ? DateTime.tryParse(json['read_at'] as String)
            : null,
      );

  NotificationItem markedRead(DateTime at) => NotificationItem(
    id: id,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    readAt: at,
  );
}

class ContributionAllocation {
  const ContributionAllocation({
    required this.childFirstName,
    required this.amount,
  });

  final String childFirstName;
  final int amount;

  factory ContributionAllocation.fromJson(Map<String, dynamic> json) =>
      ContributionAllocation(
        childFirstName: json['child_first_name'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toInt(),
      );

  Map<String, dynamic> toJson() => {
    'child_first_name': childFirstName,
    'amount': amount,
  };
}

class Contribution {
  const Contribution({
    required this.date,
    required this.method,
    required this.reference,
    required this.amount,
    required this.success,
    this.targetGoalType,
    this.allocations = const [],
  });

  final String date;
  final String method;
  final String reference;
  final int amount;
  final bool success;
  final String? targetGoalType;
  final List<ContributionAllocation> allocations;

  factory Contribution.fromJson(Map<String, dynamic> json) => Contribution(
    date: json['date'] as String? ?? json['created_at'] as String? ?? '',
    method: json['method'] as String? ?? '',
    reference: json['reference'] as String? ?? '',
    amount: (json['amount'] as num? ?? 0).toInt(),
    success: json['success'] as bool? ?? json['status'] == 'confirmed',
    targetGoalType: json['target_goal_type'] as String?,
    allocations: (json['allocations'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              ContributionAllocation.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'method': method,
    'reference': reference,
    'amount': amount,
    'success': success,
    if (targetGoalType != null) 'targetGoalType': targetGoalType,
    'allocations': allocations
        .map((allocation) => allocation.toJson())
        .toList(),
  };
}

extension SavingsPlanLabel on SavingsPlan {
  String get title => switch (this) {
    SavingsPlan.daily => 'Journalier',
    SavingsPlan.weekly => 'Hebdomadaire',
    SavingsPlan.monthly => 'Mensuel',
  };

  int get amount => switch (this) {
    SavingsPlan.daily => 300,
    SavingsPlan.weekly => 2000,
    SavingsPlan.monthly => 8500,
  };

  String get period => switch (this) {
    SavingsPlan.daily => 'jour',
    SavingsPlan.weekly => 'semaine',
    SavingsPlan.monthly => 'mois',
  };
}

/// Display constant for the school year the current subscription covers.
const String kSchoolYear = '2026-2027';

enum DeliveryStatus {
  preparation,
  shipped,
  outForDelivery,
  delivered,
  receiptConfirmed,
}

extension DeliveryStatusLabel on DeliveryStatus {
  String get title => switch (this) {
    DeliveryStatus.preparation => 'Préparation',
    DeliveryStatus.shipped => 'Expédiée',
    DeliveryStatus.outForDelivery => 'En livraison',
    DeliveryStatus.delivered => 'Livrée',
    DeliveryStatus.receiptConfirmed => 'Réception confirmée',
  };
}

/// Correspondance avec les codes du backend (snake_case).
DeliveryStatus deliveryStatusFromCode(String? code) => switch (code) {
  'shipped' => DeliveryStatus.shipped,
  'out_for_delivery' => DeliveryStatus.outForDelivery,
  'delivered' => DeliveryStatus.delivered,
  'receipt_confirmed' => DeliveryStatus.receiptConfirmed,
  _ => DeliveryStatus.preparation,
};

/// A delivery pin sent BY THE PARENT so the delivery agent knows where to
/// bring the order (not the agent's own position).
class DeliveryLocation {
  const DeliveryLocation({
    required this.lat,
    required this.lng,
    required this.address,
    required this.sentAt,
  });

  final double lat;
  final double lng;
  final String address;
  final DateTime sentAt;

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) =>
      DeliveryLocation(
        lat: (json['lat'] as num? ?? 0).toDouble(),
        lng: (json['lng'] as num? ?? 0).toDouble(),
        address: json['address'] as String? ?? '',
        sentAt:
            DateTime.tryParse(json['sent_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'address': address,
    'sent_at': sentAt.toIso8601String(),
  };
}

class DeliveryOrder {
  const DeliveryOrder({
    required this.registrationDate,
    required this.orderDate,
    required this.status,
    this.location,
  });

  final DateTime registrationDate;
  final DateTime orderDate;
  final DeliveryStatus status;
  final DeliveryLocation? location;

  DeliveryOrder copyWith({
    DeliveryStatus? status,
    DeliveryLocation? location,
  }) => DeliveryOrder(
    registrationDate: registrationDate,
    orderDate: orderDate,
    status: status ?? this.status,
    location: location ?? this.location,
  );

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    final registration = DateTime.tryParse(
      json['registration_date'] as String? ??
          json['created_at'] as String? ??
          '',
    );
    final order = DateTime.tryParse(
      json['order_date'] as String? ?? json['scheduled_at'] as String? ?? '',
    );
    return DeliveryOrder(
      registrationDate: registration ?? DateTime.now(),
      orderDate: order ?? registration ?? DateTime.now(),
      status: deliveryStatusFromCode(json['status'] as String?),
      location: json['location'] != null
          ? DeliveryLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}

enum DeliveryIssueType {
  notReceived,
  missingItem,
  damagedItem,
  lateDelivery,
  other,
}

extension DeliveryIssueTypeLabel on DeliveryIssueType {
  String get title => switch (this) {
    DeliveryIssueType.notReceived => 'Livraison non reçue',
    DeliveryIssueType.missingItem => 'Article manquant',
    DeliveryIssueType.damagedItem => 'Article endommagé',
    DeliveryIssueType.lateDelivery => 'Retard de livraison',
    DeliveryIssueType.other => 'Autre problème',
  };

  /// Code enum attendu par le backend.
  String get backendCode => switch (this) {
    DeliveryIssueType.notReceived => 'notReceived',
    DeliveryIssueType.missingItem => 'missingItem',
    DeliveryIssueType.damagedItem => 'damagedItem',
    DeliveryIssueType.lateDelivery => 'lateDelivery',
    DeliveryIssueType.other => 'other',
  };
}

class DeliveryIssueReport {
  const DeliveryIssueReport({
    required this.type,
    required this.description,
    required this.createdAt,
    this.photoPath,
  });

  final DeliveryIssueType type;
  final String description;
  final String? photoPath;
  final DateTime createdAt;
}
