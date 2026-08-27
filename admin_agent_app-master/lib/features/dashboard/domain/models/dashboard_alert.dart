import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_alert.freezed.dart';

enum DashboardAlertSeverity { danger, warning, info }

/// Catégorie stable d'une alerte, indépendante du texte affiché (qui peut
/// changer de formulation) — sert à router vers le bon écran au tap.
/// `other` couvre un code futur inconnu du client (dégradation silencieuse
/// plutôt qu'un crash si le backend ajoute un type d'alerte non prévu ici).
enum DashboardAlertKind {
  pendingValidation,
  overduePayments,
  pendingDeliveries,
  seasonProgress,
  other,
}

/// Une carte d'alerte du dashboard (motif `.nt` du prototype), ex. impayés
/// critiques ou avancement de l'objectif de la saison.
@freezed
sealed class DashboardAlert with _$DashboardAlert {
  const factory DashboardAlert({
    required String title,
    required String subtitle,
    required DashboardAlertSeverity severity,
    required DashboardAlertKind kind,
  }) = _DashboardAlert;
}
