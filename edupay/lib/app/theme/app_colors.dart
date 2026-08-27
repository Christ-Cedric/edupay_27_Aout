import 'package:flutter/material.dart';

/// Ancres de marque, indépendantes du mode (Dark/Light).
///
/// Les couleurs qui doivent s'adapter au mode vivent dans [AppPalette]. On lit
/// ces tokens via `context.palette` plutôt que des couleurs codées en dur.
class AppColors {
  const AppColors._();

  // Marque
  static const nightBlue = Color(0xFF0A1628);
  static const brightGreen = Color(0xFF00C853);
  static const sunYellow = Color(0xFFFFD600);

  // Accents sémantiques transverses (lisibles sur fond clair comme sombre)
  static const danger = Color(0xFFE53935);
  static const info = Color(0xFF2F80ED);

  // Surfaces sombres historiques (défauts / références)
  static const surface = Color(0xFF0D1D34);
  static const surfaceSoft = Color(0xFF13253F);
  static const textMuted = Color(0xFF9AA5B4);
  static const page = Color(0xFFF0F4F8);
}

/// Système de couleurs sémantiques résolu selon le mode. Chaque token décrit un
/// RÔLE (fond, surface, texte, action…), pas une teinte — ce qui permet une
/// inversion Dark↔Light cohérente sans toucher aux widgets.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.elevated,
    required this.textPrimary,
    required this.textMuted,
    required this.onSurfaceBase,
    required this.primary,
    required this.onPrimary,
    required this.accentGreen,
    required this.accentYellow,
    required this.danger,
    required this.onDanger,
    required this.hairline,
    required this.successBg,
    required this.successFg,
    required this.errorBg,
    required this.errorFg,
    required this.warningBg,
    required this.warningFg,
    required this.infoBg,
    required this.infoFg,
  });

  final Brightness brightness;

  /// Fond d'écran principal.
  final Color background;

  /// Surface d'une carte / d'un panneau posé sur [background].
  final Color surface;

  /// Surface secondaire (remplissage de champ, chip, pavé numérique).
  final Color surfaceSoft;

  /// Surface surélevée (feuille modale, carte flottante).
  final Color elevated;

  /// Texte principal.
  final Color textPrimary;

  /// Texte tertiaire discret (légendes, valeurs secondaires).
  final Color textMuted;

  /// Base des superpositions à opacité (texte/bordure/voile) : blanche en Dark,
  /// bleu nuit en Light. Utilisée par [onSurface].
  final Color onSurfaceBase;

  /// Couleur d'action primaire (fond du bouton principal) et son texte.
  final Color primary;
  final Color onPrimary;

  /// Accents de marque adaptés à la lisibilité du mode.
  final Color accentGreen;
  final Color accentYellow;

  /// Action destructive.
  final Color danger;
  final Color onDanger;

  /// Filet / bordure par défaut d'une carte.
  final Color hairline;

  /// Messages de validation : fond teinté + texte lisible.
  final Color successBg, successFg;
  final Color errorBg, errorFg;
  final Color warningBg, warningFg;
  final Color infoBg, infoFg;

  bool get isDark => brightness == Brightness.dark;

  /// Superposition sur la surface à l'opacité voulue (texte/bordure/voile).
  /// Conserve un rendu Dark identique tout en s'inversant en Light.
  Color onSurface(double alpha) => onSurfaceBase.withValues(alpha: alpha);

  /// Ombre portée, plus discrète en Light.
  Color shadow(double alpha) =>
      (isDark ? Colors.black : const Color(0xFF1B2A45)).withValues(
        alpha: alpha,
      );

  // ─────────────────────────────── Instances

  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0A1628),
    surface: Color(0xFF0D1D34),
    surfaceSoft: Color(0xFF13253F),
    elevated: Color(0xFF102038),
    textPrimary: Colors.white,
    textMuted: Color(0xFF9AA5B4),
    onSurfaceBase: Colors.white,
    primary: Color(0xFFFFD600), // CTA jaune sur fond sombre
    onPrimary: Color(0xFF0A1628),
    accentGreen: Color(0xFF00C853),
    accentYellow: Color(0xFFFFD600),
    danger: Color(0xFFE53935),
    onDanger: Colors.white,
    hairline: Color(0xFF22324C),
    successBg: Color(0xFF10331F),
    successFg: Color(0xFF4ADE80),
    errorBg: Color(0xFF3A1B1B),
    errorFg: Color(0xFFFF6B6B),
    warningBg: Color(0xFF382D12),
    warningFg: Color(0xFFF5B849),
    infoBg: Color(0xFF162B47),
    infoFg: Color(0xFF6FA8F5),
  );

  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF4F7FB), // blanc cassé doux (anti-éblouissement)
    surface: Color(0xFFFAFAFC), // Off-white to avoid pure white cliche
    surfaceSoft: Color(0xFFEDF1F7),
    elevated: Color(0xFFFAFAFC), // Off-white to avoid pure white cliche
    textPrimary: Color(0xFF12233B),
    textMuted: Color(0xFF64748B),
    onSurfaceBase: Color(0xFF12233B),
    primary: Color(0xFF0A1628), // CTA bleu nuit sur fond clair (contraste fort)
    onPrimary: Colors.white,
    accentGreen: Color(0xFF0BA150), // vert assombri, lisible sur blanc
    accentYellow: Color(
      0xFFC98A00,
    ), // jaune assombri pour texte/icône sur blanc
    danger: Color(0xFFDC2626),
    onDanger: Colors.white,
    hairline: Color(0xFFE3E9F0),
    successBg: Color(0xFFE6F7EE),
    successFg: Color(0xFF0B7A3E),
    errorBg: Color(0xFFFDECEC),
    errorFg: Color(0xFFC62828),
    warningBg: Color(0xFFFEF4E3),
    warningFg: Color(0xFFB45309),
    infoBg: Color(0xFFE8F1FD),
    infoFg: Color(0xFF1B5FBF),
  );

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? elevated,
    Color? textPrimary,
    Color? textMuted,
    Color? onSurfaceBase,
    Color? primary,
    Color? onPrimary,
    Color? accentGreen,
    Color? accentYellow,
    Color? danger,
    Color? onDanger,
    Color? hairline,
    Color? successBg,
    Color? successFg,
    Color? errorBg,
    Color? errorFg,
    Color? warningBg,
    Color? warningFg,
    Color? infoBg,
    Color? infoFg,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      elevated: elevated ?? this.elevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      onSurfaceBase: onSurfaceBase ?? this.onSurfaceBase,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accentGreen: accentGreen ?? this.accentGreen,
      accentYellow: accentYellow ?? this.accentYellow,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      hairline: hairline ?? this.hairline,
      successBg: successBg ?? this.successBg,
      successFg: successFg ?? this.successFg,
      errorBg: errorBg ?? this.errorBg,
      errorFg: errorFg ?? this.errorFg,
      warningBg: warningBg ?? this.warningBg,
      warningFg: warningFg ?? this.warningFg,
      infoBg: infoBg ?? this.infoBg,
      infoFg: infoFg ?? this.infoFg,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    // Interpolation couleur par couleur : toute l'interface se fond en douceur
    // d'un mode à l'autre. La `brightness` bascule à mi-parcours.
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceSoft: mix(surfaceSoft, other.surfaceSoft),
      elevated: mix(elevated, other.elevated),
      textPrimary: mix(textPrimary, other.textPrimary),
      textMuted: mix(textMuted, other.textMuted),
      onSurfaceBase: mix(onSurfaceBase, other.onSurfaceBase),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      accentGreen: mix(accentGreen, other.accentGreen),
      accentYellow: mix(accentYellow, other.accentYellow),
      danger: mix(danger, other.danger),
      onDanger: mix(onDanger, other.onDanger),
      hairline: mix(hairline, other.hairline),
      successBg: mix(successBg, other.successBg),
      successFg: mix(successFg, other.successFg),
      errorBg: mix(errorBg, other.errorBg),
      errorFg: mix(errorFg, other.errorFg),
      warningBg: mix(warningBg, other.warningBg),
      warningFg: mix(warningFg, other.warningFg),
      infoBg: mix(infoBg, other.infoBg),
      infoFg: mix(infoFg, other.infoFg),
    );
  }
}

extension AppPaletteX on BuildContext {
  /// Raccourci de lecture des tokens sémantiques : `context.palette.surface`.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
