import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/core/utils/currency_formatter.dart';

void main() {
  group('formatCurrency', () {
    test('regroupe les milliers avec un espace et le suffixe FCFA', () {
      expect(formatCurrency(1247800), '1 247 800 FCFA');
    });

    test('fonctionne pour un petit montant', () {
      expect(formatCurrency(300), '300 FCFA');
    });
  });

  group('formatCompactCurrency', () {
    test('abrège les millions avec une décimale, ex. dashboard', () {
      expect(formatCompactCurrency(1200000), '1,2M F');
    });

    test('abrège un million rond sans décimale superflue', () {
      expect(formatCompactCurrency(2000000), '2M F');
    });

    test('abrège les milliers', () {
      expect(formatCompactCurrency(24700), '25K F');
    });

    test('laisse les petits montants tels quels', () {
      expect(formatCompactCurrency(300), '300 F');
    });
  });
}
