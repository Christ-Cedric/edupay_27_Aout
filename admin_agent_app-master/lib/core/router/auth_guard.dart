import 'package:riverpod/riverpod.dart';

import '../../features/auth/domain/models/session.dart';
import '../../features/auth/domain/models/user_role.dart';
import 'route_paths.dart';

/// Décision de redirection pure, indépendante de [BuildContext]/GoRouter —
/// testable directement avec de simples valeurs (voir stratégie de tests du
/// plan). Le routeur ne fait qu'appeler cette fonction.
String? authGuardRedirect({
  required AsyncValue<Session?> sessionState,
  required String location,
}) {
  if (location == RoutePaths.devWidgetGallery) return null;

  // Le splash n'est une destination valide que pendant la restauration de
  // session — une fois résolue, seul `/login` reste valide sans session.
  if (sessionState.isLoading) {
    return location == RoutePaths.splash ? null : RoutePaths.splash;
  }

  final session = sessionState.value;
  // Séparation des apps : seul un compte admin peut obtenir une session ici
  // (voir `AuthRepositoryImpl.login`, qui rejette déjà tout autre rôle avant
  // même de créer une session). Un rôle non-admin ne peut donc apparaître que
  // via une session restaurée d'avant ce changement (persistance obsolète) —
  // traité comme non authentifié plutôt que laissé accéder aux écrans admin.
  if (session == null || session.role != UserRole.admin) {
    return location == RoutePaths.login ? null : RoutePaths.login;
  }

  final isAuthRoute =
      location == RoutePaths.splash || location == RoutePaths.login;
  if (isAuthRoute) return RoutePaths.adminDashboard;

  return null;
}
