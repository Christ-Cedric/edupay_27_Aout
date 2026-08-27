/// Contrat d'authentification (§5.2) séparé du [ParentRepository] : l'OTP et le
/// mot de passe ne concernent pas les données métier du parent.
///
/// - Inscription : [requestOtp] → [verifyOtp] → [register].
/// - Reconnexion : [login] (numéro + mot de passe, sans OTP).
abstract interface class AuthSession {
  Future<void> requestOtp(String phone);

  /// Demande l'envoi de l'OTP pour mot de passe oublié.
  Future<void> requestPasswordReset(String phone);

  /// Vérifie l'OTP et conserve le registrationToken pour l'inscription.
  Future<void> verifyOtp({required String phone, required String code});

  /// Finalise l'inscription (le numéro provient du registrationToken).
  /// Retourne le statut du compte créé (`pendingValidation` tant que l'admin
  /// n'a pas validé — voir `AuthStatus.pendingApproval`).
  Future<String> register({
    required String fullName,
    required String city,
    required String district,
    required String password,
  });

  /// Finalise la réinitialisation du mot de passe (le numéro provient du resetToken).
  Future<void> resetPassword({required String newPassword});

  /// Retourne le statut du compte connecté (voir [register]).
  Future<String> login({required String phone, required String password});

  /// Recharge une session persistée (redémarrage de l'app). Retourne `true`
  /// si un compte était déjà connecté, pour sauter l'écran de connexion.
  Future<bool> restoreSession();

  /// Enregistre le callback appelé quand la session expire hors d'une
  /// déconnexion volontaire (refresh token rejeté par le backend).
  void setSessionExpiredListener(void Function() listener);

  Future<void> signOut();

  /// Change le mot de passe (l'ancien est exigé, §5.2.4). Le backend révoque
  /// toutes les sessions et renvoie de nouveaux tokens : cet appareil reste
  /// connecté, les autres sont déconnectés.
  Future<void> changePassword({required String current, required String next});

  /// Liste les appareils/sessions actifs du compte (§5.2.6).
  Future<List<ActiveSession>> listSessions();

  /// Révoque une session distante (déconnecte l'appareil correspondant).
  Future<void> revokeSession(String id);

  /// Révoque TOUTES les sessions (déconnexion de tous les appareils, y compris
  /// celui-ci) puis purge la session locale.
  Future<void> revokeAllSessions();
}

/// Session active telle qu'exposée par `GET /auth/sessions` (§5.2.6).
class ActiveSession {
  const ActiveSession({
    required this.id,
    this.device,
    this.ip,
    this.lastUsedAt,
    this.createdAt,
    this.isCurrent = false,
  });

  final String id;
  final String? device;
  final String? ip;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;

  /// Appareil depuis lequel on consulte (heuristique : session la plus
  /// récemment utilisée). Non retirable individuellement dans l'UI.
  final bool isCurrent;
}
