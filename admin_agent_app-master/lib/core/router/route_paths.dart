/// Chemins de routes typés — toute navigation doit référencer ces
/// constantes plutôt que des chaînes littérales.
abstract final class RoutePaths {
  RoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const sessionExpired = '/session-expired';

  static const adminDashboard = '/admin/dashboard';
  static const adminFamilies = '/admin/families';
  static const adminFinances = '/admin/finances';
  static const adminSettings = '/admin/settings';

  /// Galerie de composants du design-system — outil de développement,
  /// uniquement enregistré en debug (voir [app_router]).
  static const devWidgetGallery = '/dev/gallery';

  /// Déclencheurs de démonstration des écrans transversaux — pas de vraie
  /// condition backend pour les atteindre, uniquement enregistrés en debug.
  static const devMaintenance = '/dev/maintenance';
  static const devUpdateRequired = '/dev/update-required';
}
