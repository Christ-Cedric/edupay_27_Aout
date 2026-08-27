import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/core/domain/school_level.dart';

void main() {
  test('SchoolLevel a exactement 28 valeurs (catalogue fournisseur réel)', () {
    expect(SchoolLevel.values, hasLength(28));
  });

  test('schoolLevelFromLabel retrouve chaque niveau depuis son libellé exact', () {
    for (final level in SchoolLevel.values) {
      expect(schoolLevelFromLabel(level.label), level);
    }
  });

  test('schoolLevelFromLabel couvre les classes de chaque cycle', () {
    expect(schoolLevelFromLabel('Petite Section'), SchoolLevel.petiteSection);
    expect(schoolLevelFromLabel('CM2'), SchoolLevel.cm2);
    expect(schoolLevelFromLabel('3ème'), SchoolLevel.troisieme);
    expect(schoolLevelFromLabel('Terminale D'), SchoolLevel.terminaleD);
    // Lycée Technique : cycle absent de l'ancien modèle générique.
    expect(schoolLevelFromLabel('2nde G2'), SchoolLevel.secondeG2);
    expect(schoolLevelFromLabel('Terminale F'), SchoolLevel.terminaleF);
  });

  test('schoolLevelFromLabel renvoie null pour un libellé inconnu', () {
    expect(schoolLevelFromLabel('Classe inexistante'), isNull);
    expect(schoolLevelFromLabel(''), isNull);
  });
}
