/// Échec d'authentification (identifiants invalides, compte introuvable...).
///
/// Exception simple plutôt que modèle freezed : une erreur n'est pas une
/// valeur de domaine à comparer/copier, juste un signal d'échec avec un
/// message destiné à l'UI.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
