import 'package:flutter/material.dart';

/// Couleurs de l'app EduP@y.
///
/// `brand*` reproduit la charte graphique officielle du client (3 couleurs
/// non négociables). `danger`/`info` sont des couleurs sémantiques
/// fonctionnelles (retour système) absentes de la charte de marque — à ne
/// pas confondre avec elle.
abstract final class AppColors {
  AppColors._();

  // --- Marque officielle (charte graphique EduP@y) ---
  static const Color navy = Color(0xFF0A1628);
  static const Color green = Color(0xFF00C853);
  static const Color gold = Color(0xFFFFD600);

  // --- Surfaces ---
  static const Color surface = Color(0xFF0D1D34);
  static const Color surfaceBorder = Color(0x14FFFFFF);
  static const Color surfaceSubtle = Color(0x0DFFFFFF);
  static const Color surfaceFaint = Color(0x0AFFFFFF);

  // --- Sémantique fonctionnelle (hors charte de marque) ---
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF5DA5FF);

  // --- Texte (sur fond navy) ---
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textTertiary = Color(0x80FFFFFF);
  static const Color textQuaternary = Color(0x66FFFFFF);
  static const Color textDisabled = Color(0x4DFFFFFF);

  // --- Champs de saisie ---
  static const Color inputFill = Color(0x12FFFFFF);
  static const Color inputBorder = Color(0x26FFFFFF);
}
