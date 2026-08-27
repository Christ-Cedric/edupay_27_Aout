/// Échelle d'espacement standard de l'app.
abstract final class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Charte graphique EduP@y, principe non négociable n°1 :
  /// toute zone tactile doit mesurer au moins 48×48 px.
  static const double minTapTarget = 48;
}
