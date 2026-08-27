import 'package:freezed_annotation/freezed_annotation.dart';

part 'refund_detail.freezed.dart';

/// Statut d'une demande de remboursement.
enum RefundStatus { requested, processing, approved, rejected, refunded }

extension RefundStatusLabel on RefundStatus {
  String get label => switch (this) {
    RefundStatus.requested => 'En attente',
    RefundStatus.processing => 'En cours',
    RefundStatus.approved => 'Approuvé',
    RefundStatus.rejected => 'Rejeté',
    RefundStatus.refunded => 'Remboursé',
  };
}

/// Détail d'une demande de remboursement, y compris déjà traitée (dossier
/// remboursement). Modèle séparé de [RefundRequest] (liste des demandes en
/// attente) pour ne pas alourdir ce dernier avec des champs propres au détail.
@freezed
sealed class RefundDetail with _$RefundDetail {
  const factory RefundDetail({
    required String id,
    required String reference,
    required String familyName,
    required double amount,
    required String reason,
    required RefundStatus status,
    String? processedByAdminName,
    required DateTime createdAt,
  }) = _RefundDetail;
}
