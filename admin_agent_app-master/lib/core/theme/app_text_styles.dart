import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Styles de texte de l'app.
///
/// Montserrat (ExtraBold/Bold) pour les titres, montants et boutons ;
/// Open Sans (Regular/SemiBold/Bold) pour le corps de texte — conforme à la
/// charte graphique du client. Toujours utiliser ces styles plutôt que de
/// composer un [TextStyle] ad hoc dans un écran.
abstract final class AppTextStyles {
  AppTextStyles._();

  static const String _montserrat = 'Montserrat';
  static const String _openSans = 'OpenSans';

  static const TextStyle h1 = TextStyle(
    fontFamily: _montserrat,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _montserrat,
    fontWeight: FontWeight.w800,
    fontSize: 18,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle headerTitle = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const TextStyle kpiNumber = TextStyle(
    fontFamily: _montserrat,
    fontWeight: FontWeight.w800,
    fontSize: 20,
    color: AppColors.gold,
    height: 1.1,
  );

  static const TextStyle kpiLabel = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    color: AppColors.textTertiary,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    letterSpacing: .6,
    color: AppColors.textTertiary,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    letterSpacing: .4,
    color: AppColors.green,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.textQuaternary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _montserrat,
    fontWeight: FontWeight.w800,
    fontSize: 14,
  );

  static const TextStyle tag = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w700,
    fontSize: 11,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w600,
    fontSize: 10,
  );

  static const TextStyle errorText = TextStyle(
    fontFamily: _openSans,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.danger,
  );

  static const TextStyle avatarInitials = TextStyle(
    fontFamily: _montserrat,
    fontWeight: FontWeight.w800,
  );
}
