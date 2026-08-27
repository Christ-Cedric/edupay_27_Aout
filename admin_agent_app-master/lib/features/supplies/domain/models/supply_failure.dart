/// Échec d'une opération sur une fourniture.
///
/// Exception simple plutôt que modèle freezed : une erreur n'est pas une
/// valeur de domaine à comparer/copier, juste un signal d'échec avec un
/// message destiné à l'UI.
class SupplyFailure implements Exception {
  const SupplyFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
