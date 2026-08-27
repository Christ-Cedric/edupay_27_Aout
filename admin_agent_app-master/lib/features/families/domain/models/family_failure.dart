/// Échec d'une opération sur une famille (montant invalide, solde
/// insuffisant...).
///
/// Exception simple plutôt que modèle freezed : une erreur n'est pas une
/// valeur de domaine à comparer/copier, juste un signal d'échec avec un
/// message destiné à l'UI.
class FamilyFailure implements Exception {
  const FamilyFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
