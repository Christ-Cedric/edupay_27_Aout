/// Ville principale du Burkina Faso — liste fermée utilisée pour la zone
/// d'un agent et, par dérivation, la ville de la famille qui lui est
/// assignée (une famille n'a pas de ville indépendante de son agent).
enum BurkinaCity {
  ouagadougou,
  boboDioulasso,
  koudougou,
  ouahigouya,
  banfora,
  kaya,
  tenkodogo,
  fadaNGourma,
  dedougou,
  gaoua,
  reo,
  sabou,
  imasgo,
  poa,
  ramongo,

}

extension BurkinaCityLabel on BurkinaCity {
  String get label => switch (this) {
    BurkinaCity.ouagadougou => 'Ouagadougou',
    BurkinaCity.boboDioulasso => 'Bobo-Dioulasso',
    BurkinaCity.koudougou => 'Koudougou',
    BurkinaCity.ouahigouya => 'Ouahigouya',
    BurkinaCity.banfora => 'Banfora',
    BurkinaCity.kaya => 'Kaya',
    BurkinaCity.tenkodogo => 'Tenkodogo',
    BurkinaCity.fadaNGourma => 'Fada N\'Gourma',
    BurkinaCity.dedougou => 'Dédougou',
    BurkinaCity.gaoua => 'Gaoua',
    BurkinaCity.reo => 'Reo',
    BurkinaCity.sabou => 'Sabou',
    BurkinaCity.imasgo => 'Imasgo',
    BurkinaCity.poa => 'Poa',
    BurkinaCity.ramongo => 'Ramongo',
  };
}

/// Retrouve la ville à partir de son libellé (ex. la `zone` d'un agent,
/// stockée telle quelle côté backend) — `null` si aucune correspondance.
BurkinaCity? burkinaCityFromLabel(String label) {
  for (final city in BurkinaCity.values) {
    if (city.label == label) return city;
  }
  return null;
}
