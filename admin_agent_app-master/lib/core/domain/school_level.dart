/// Classe/série réelle (motif `child_a` du prototype — app Client, écran
/// "Ajouter un enfant") — concept partagé entre les enfants d'une famille et
/// le catalogue de kits (un kit cible une classe précise, contrat §3.6).
///
/// Les 28 valeurs et leurs libellés reflètent le vrai catalogue fournisseur
/// (`EduPay_Catalogue_Fournitures_3Kits.xlsx`) — les libellés doivent rester
/// identiques à la colonne "Niveau" de ce fichier, utilisée pour faire
/// correspondre chaque ligne importée à la bonne classe. Déclarées par
/// cycle (Maternelle → Primaire → Collège → Lycée Général → Lycée
/// Technique) pour que les écrans qui itèrent `SchoolLevel.values` (le
/// catalogue de kits, notamment) restent groupés visuellement par cycle
/// sans code de regroupement supplémentaire.
enum SchoolLevel {
  petiteSection,
  moyenneSection,
  grandeSection,
  cp1,
  cp2,
  ce1,
  ce2,
  cm1,
  cm2,
  sixieme,
  cinquieme,
  quatrieme,
  troisieme,
  secondeA,
  secondeCD,
  premiereA,
  premiereC,
  premiereD,
  terminaleA1,
  terminaleA2,
  terminaleC,
  terminaleD,
  secondeG2,
  secondeF,
  premiereG2,
  premiereF,
  terminaleG2,
  terminaleF,
}

extension SchoolLevelLabel on SchoolLevel {
  String get label => switch (this) {
    SchoolLevel.petiteSection => 'Petite Section',
    SchoolLevel.moyenneSection => 'Moyenne Section',
    SchoolLevel.grandeSection => 'Grande Section',
    SchoolLevel.cp1 => 'CP1',
    SchoolLevel.cp2 => 'CP2',
    SchoolLevel.ce1 => 'CE1',
    SchoolLevel.ce2 => 'CE2',
    SchoolLevel.cm1 => 'CM1',
    SchoolLevel.cm2 => 'CM2',
    SchoolLevel.sixieme => '6ème',
    SchoolLevel.cinquieme => '5ème',
    SchoolLevel.quatrieme => '4ème',
    SchoolLevel.troisieme => '3ème',
    SchoolLevel.secondeA => '2nde A',
    SchoolLevel.secondeCD => '2nde C/D',
    SchoolLevel.premiereA => '1ère A',
    SchoolLevel.premiereC => '1ère C',
    SchoolLevel.premiereD => '1ère D',
    SchoolLevel.terminaleA1 => 'Terminale A1',
    SchoolLevel.terminaleA2 => 'Terminale A2',
    SchoolLevel.terminaleC => 'Terminale C',
    SchoolLevel.terminaleD => 'Terminale D',
    SchoolLevel.secondeG2 => '2nde G2',
    SchoolLevel.secondeF => '2nde F',
    SchoolLevel.premiereG2 => '1ère G2',
    SchoolLevel.premiereF => '1ère F',
    SchoolLevel.terminaleG2 => 'Terminale G2',
    SchoolLevel.terminaleF => 'Terminale F',
  };
}

/// Retrouve le niveau à partir de son libellé stocké tel quel côté backend
/// (une simple chaîne libre, pas un enum serveur) — `null` si le texte ne
/// correspond à aucun libellé connu (champ non renseigné ou donnée
/// historique).
SchoolLevel? schoolLevelFromLabel(String label) {
  for (final level in SchoolLevel.values) {
    if (level.label == label) return level;
  }
  return null;
}
