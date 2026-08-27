/// Échec d'une opération sur un agent (introuvable, déjà suspendu...).
///
/// Exception simple plutôt que modèle freezed : une erreur n'est pas une
/// valeur de domaine à comparer/copier, juste un signal d'échec avec un
/// message destiné à l'UI.
class AgentFailure implements Exception {
  const AgentFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
