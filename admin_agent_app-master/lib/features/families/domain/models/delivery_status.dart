/// Statut de livraison du kit scolaire d'une famille.
enum DeliveryStatus { pending, inProgress, delivered }

extension DeliveryStatusLabel on DeliveryStatus {
  String get label => switch (this) {
    DeliveryStatus.pending => 'En attente',
    DeliveryStatus.inProgress => 'En route',
    DeliveryStatus.delivered => 'Livré',
  };
}
