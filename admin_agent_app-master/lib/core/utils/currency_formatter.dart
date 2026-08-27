import 'package:intl/intl.dart';

/// Formatte un montant en FCFA avec séparateur de milliers,
/// ex. `formatCurrency(1247800)` → "1 247 800 FCFA".
///
/// La locale fr_FR d'ICU regroupe les milliers avec une espace insécable
/// étroite (U+202F) ; on la normalise en espace standard (U+0020) pour un
/// rendu et des tests prévisibles.
String formatCurrency(num amount) {
  final grouped = NumberFormat.decimalPattern(
    'fr_FR',
  ).format(amount).replaceAll(' ', ' ').replaceAll(' ', ' ');
  return '$grouped FCFA';
}

/// Formatte un montant en version compacte pour les espaces réduits (KPI),
/// ex. `formatCompactCurrency(1200000)` → "1,2M F".
String formatCompactCurrency(num amount) {
  if (amount >= 1000000) {
    final millions = (amount / 100000).round() / 10;
    final text = millions == millions.roundToDouble()
        ? millions.toInt().toString()
        : millions.toStringAsFixed(1).replaceAll('.', ',');
    return '${text}M F';
  }
  if (amount >= 1000) {
    return '${(amount / 1000).round()}K F';
  }
  return '${amount.round()} F';
}
