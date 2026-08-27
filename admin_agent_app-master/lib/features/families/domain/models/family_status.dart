/// Statut d'une famille.
///
/// `pendingValidation`/`rejected` n'existent pas dans le prototype — ajoutés
/// pour la règle métier confirmée par le client : l'admin doit valider tout
/// compte auto-inscrit avant activation (voir mémo de validation du plan).
enum FamilyStatus { pendingValidation, active, lateOverdue, rejected }
