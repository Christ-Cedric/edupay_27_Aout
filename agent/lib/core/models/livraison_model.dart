// =============================================================================
// CORE/MODELS/LIVRAISON_MODEL.DART — Modèle livraison aligné sur DeliveryDto
// =============================================================================

class LivraisonIssue {
  final String id;
  final String type;
  final String? description;
  final String? photoUrl;
  final String? status;
  final String createdAt;

  LivraisonIssue({
    required this.id,
    required this.type,
    this.description,
    this.photoUrl,
    this.status,
    required this.createdAt,
  });

  factory LivraisonIssue.fromJson(Map<String, dynamic> json) {
    return LivraisonIssue(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      photoUrl: json['photo_url'],
      status: json['status'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class LivraisonLocation {
  final double lat;
  final double lng;
  final String address;

  LivraisonLocation({required this.lat, required this.lng, required this.address});

  factory LivraisonLocation.fromJson(Map<String, dynamic> json) {
    return LivraisonLocation(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      address: json['address'] ?? '',
    );
  }
}

/// Correspond exactement au DeliveryDto renvoyé par le backend.
/// Les champs client (fullName, school...) doivent être récupérés
/// séparément depuis la liste des familles (AgentProvider.families).
class LivraisonModel {
  final String id;
  final String? childId;     // child_id
  final String kitId;        // kit_id
  final String status;       // preparation | shipped | out_for_delivery | delivered | receipt_confirmed
  final LivraisonLocation? location;
  final DateTime? signedAt;
  final DateTime? scheduledAt;
  final String? signature;
  final List<LivraisonIssue> issues;

  // Champs d'affichage enrichis en local (croisés avec ClientModel)
  String? clientFullName;
  String? childFirstName;
  String? childSchool;
  String? clientCity;

  LivraisonModel({
    required this.id,
    this.childId,
    required this.kitId,
    required this.status,
    this.location,
    this.signedAt,
    this.scheduledAt,
    this.signature,
    required this.issues,
    this.clientFullName,
    this.childFirstName,
    this.childSchool,
    this.clientCity,
  });

  // Converti le status backend en label affichable
  String get statusLabel {
    switch (status) {
      case 'preparation':      return 'En préparation';
      case 'shipped':          return 'Expédié';
      case 'out_for_delivery': return 'En cours de livraison';
      case 'delivered':        return 'Livré';
      case 'receipt_confirmed':return 'Réception confirmée';
      default:                 return 'Inconnu';
    }
  }

  bool get isDelivered => status == 'delivered' || status == 'receipt_confirmed';
  bool get isPending   => status == 'preparation' || status == 'shipped';

  /// Reference d'affichage : 8 premiers chars de l'id en majuscules
  String get reference => id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  factory LivraisonModel.fromJson(Map<String, dynamic> json) {
    return LivraisonModel(
      id: json['id'] ?? '',
      childId: json['child_id'],
      kitId: json['kit_id'] ?? '',
      status: json['status'] ?? 'preparation',
      location: json['location'] != null
          ? LivraisonLocation.fromJson(json['location'])
          : null,
      signedAt: json['signed_at'] != null
          ? DateTime.tryParse(json['signed_at'].toString())
          : null,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'].toString())
          : null,
      signature: json['signature'],
      issues: json['issues'] != null
          ? (json['issues'] as List).map((i) => LivraisonIssue.fromJson(i)).toList()
          : [],
    );
  }
}

/// Compatibilité rétrocompatible avec le code qui utilise encore LivraisonClient
/// Construit depuis les données croisées (famille + livraison).
class LivraisonClient {
  final String fullName;
  final String address;
  final String? schoolName;
  final String? childName;
  final String? clientStatus;

  LivraisonClient({
    required this.fullName,
    required this.address,
    this.schoolName,
    this.childName,
    this.clientStatus,
  });
}
