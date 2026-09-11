import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Couleurs principales EduPay
  static const Color background = Color(0xFF0A1628);
  static const Color cardBg = Color(0xFF0D1D34);
  static const Color cardBg2 = Color(0xFF111D30);

  static const Color green = Color(0xFF00C853);
  static const Color greenDark = Color(0xFF145530);
  static const Color gold = Color(0xFFFFD600);
  static const Color red = Color(0xFFE53935);
  static const Color blue = Color(0xFF5DA5FF);
  static const Color orange = Color(0xFFFF6600);

  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white35 = Color(0x59FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white07 = Color(0x12FFFFFF);
  static const Color white05 = Color(0x0DFFFFFF);

  // Tags
  static const Color tagGreenBg = Color(0x2600C853);
  static const Color tagYellowBg = Color(0x26FFD600);
  static const Color tagRedBg = Color(0x26E53935);
  static const Color tagBlueBg = Color(0x265DA5FF);

  // Bordures
  static const Color borderDefault = Color(0x26FFFFFF);
  static const Color borderGreen = Color(0x33C853FF);
  static const Color divider = Color(0x0FFFFFFF);

  // Header agent
  static const Color agentHeaderBg = Color(0xFF00C853);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.green,
        secondary: AppColors.gold,
        surface: AppColors.cardBg,
        error: AppColors.red,
      ),
      // Montserrat comme police globale de l'application
      textTheme: GoogleFonts.montserratTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(color: AppColors.white70, fontWeight: FontWeight.w700),
          bodySmall: TextStyle(color: AppColors.white50, fontWeight: FontWeight.w700),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: GoogleFonts.montserrat(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.white70),
      ),
      useMaterial3: true,
    );
  }

  // Text styles Montserrat (titres)
  static TextStyle montserrat({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w800,
    Color color = AppColors.white,
  }) =>
      GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  // Text styles Open Sans (corps) - Redirigé vers Montserrat pour cohérence globale
  static TextStyle openSans({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w700, // Mis en gras foncé (w700) par défaut pour plus de lisibilité
    Color color = AppColors.white,
  }) =>
      GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
}
