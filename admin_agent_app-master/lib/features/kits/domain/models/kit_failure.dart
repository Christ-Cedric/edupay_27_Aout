/// Échec d'une opération sur un kit (ex. suppression d'un kit encore
/// assigné à des familles).
///
/// Exception simple plutôt que modèle freezed : une erreur n'est pas une
/// valeur de domaine à comparer/copier, juste un signal d'échec avec un
/// message destiné à l'UI.
class KitFailure implements Exception {
  const KitFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
