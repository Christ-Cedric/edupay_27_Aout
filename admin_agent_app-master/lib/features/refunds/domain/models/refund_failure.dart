/// Échec d'une opération sur un remboursement (introuvable...).
///
/// Exception simple plutôt que modèle freezed : une erreur n'est pas une
/// valeur de domaine à comparer/copier, juste un signal d'échec avec un
/// message destiné à l'UI.
class RefundFailure implements Exception {
  const RefundFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
