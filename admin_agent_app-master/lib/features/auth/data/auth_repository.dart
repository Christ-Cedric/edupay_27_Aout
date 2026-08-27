import '../domain/models/session.dart';
import '../domain/models/user_role.dart';

/// Interface d'accès à l'authentification — seul point à modifier quand le
/// vrai backend arrivera (remplacer l'implémentation qui construit
/// [FakeAuthDataSource] par une qui appelle une API réelle via Dio).
abstract interface class AuthRepository {
  /// Lance un [AuthFailure] si le téléphone/mot de passe est invalide.
  Future<Session> login({required String phone, required String password});

  Future<void> logout();

  /// Restaure une session déjà persistée localement (démarrage de l'app),
  /// ou `null` si aucune session valide n'est stockée.
  Future<Session?> restoreSession();

  /// Modifie le téléphone et/ou le mot de passe du compte connecté
  /// (écran "Mon compte") ; laisse [newPassword] à `null` pour ne pas le
  /// changer.
  Future<Session> updateCredentials({
    required String currentPhone,
    required String newPhone,
    String? newPassword,
  });

  /// Crée un nouveau compte de connexion (ex. agent terrain créé par
  /// l'admin), qui définit lui-même le mot de passe initial.
  Future<void> registerAccount({
    required String phone,
    required String displayName,
    required String password,
    required UserRole role,
  });
}
