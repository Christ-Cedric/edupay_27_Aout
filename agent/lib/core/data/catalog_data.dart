class CatalogItem {
  final String id;
  final String name;
  final int unitPrice;
  final String unit;
  
  // Quantités par défaut par niveau scolaire (clé: 'CP1', 'CE1', etc.)
  final Map<String, int> defaultQuantities;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.unit = 'Unité',
    this.defaultQuantities = const {},
  });

  int getQtyForClass(String classLevel) {
    // Normalisation de la classe (ex: '6e' -> '6e', '6ème' -> '6e')
    String normalized = classLevel.trim().toUpperCase();
    if (normalized.startsWith('6')) normalized = '6E';
    if (normalized.startsWith('5')) normalized = '5E';
    if (normalized.startsWith('4')) normalized = '4E';
    if (normalized.startsWith('3')) normalized = '3E';
    
    return defaultQuantities[normalized] ?? 0;
  }
}

class CatalogCategory {
  final String name;
  final List<CatalogItem> items;

  const CatalogCategory({
    required this.name,
    required this.items,
  });
}

class CatalogData {
  static const List<CatalogCategory> categories = [
    CatalogCategory(
      name: 'Cahiers & Protège-cahiers',
      items: [
        CatalogItem(
          id: 'cahier_100',
          name: 'Cahier de 100 pages',
          unitPrice: 350,
          defaultQuantities: {'CP1': 2, 'CP2': 2, 'CE1': 4, 'CE2': 4, 'CM1': 4, 'CM2': 4, '6E': 5, '5E': 5, '4E': 6, '3E': 6, '2NDE': 8, '1ERE': 8, 'TLE A': 8, 'TLE D': 8},
        ),
        CatalogItem(
          id: 'cahier_200',
          name: 'Cahier de 200 pages',
          unitPrice: 650,
          defaultQuantities: {'CE1': 1, 'CE2': 1, 'CM1': 3, 'CM2': 3, '6E': 4, '5E': 4, '4E': 5, '3E': 5, '2NDE': 6, '1ERE': 6, 'TLE A': 6, 'TLE D': 6},
        ),
        CatalogItem(
          id: 'cahier_300',
          name: 'Cahier de 300 pages',
          unitPrice: 950,
          defaultQuantities: {'6E': 1, '5E': 1, '4E': 2, '3E': 2, '2NDE': 4, '1ERE': 4, 'TLE A': 4, 'TLE D': 4},
        ),
        CatalogItem(
          id: 'cahier_tp',
          name: 'Cahier de TP',
          unitPrice: 500,
          defaultQuantities: {'CM1': 1, 'CM2': 1, '6E': 1, '5E': 1, '4E': 2, '3E': 2, '2NDE': 2, '1ERE': 2, 'TLE A': 1, 'TLE D': 2},
        ),
        CatalogItem(
          id: 'protege_cahier_gm',
          name: 'Protège cahier (Grand format)',
          unitPrice: 150,
          defaultQuantities: {'6E': 5, '5E': 5, '4E': 6, '3E': 6, '2NDE': 8, '1ERE': 8, 'TLE A': 8, 'TLE D': 8},
        ),
        CatalogItem(
          id: 'protege_cahier_pm',
          name: 'Protège cahier (Petit format)',
          unitPrice: 100,
          defaultQuantities: {'CP1': 2, 'CP2': 2, 'CE1': 5, 'CE2': 5, 'CM1': 7, 'CM2': 7, '6E': 4, '5E': 4, '4E': 4, '3E': 4},
        ),
      ],
    ),
    CatalogCategory(
      name: 'Matériel de traçage & d\'écriture',
      items: [
        CatalogItem(
          id: 'stylo_bleu',
          name: 'Stylo à bille Bleu',
          unitPrice: 100,
          defaultQuantities: {'CP1': 0, 'CP2': 0, 'CE1': 2, 'CE2': 2, 'CM1': 2, 'CM2': 2, '6E': 3, '5E': 3, '4E': 3, '3E': 3, '2NDE': 3, '1ERE': 3, 'TLE A': 3, 'TLE D': 3},
        ),
        CatalogItem(
          id: 'stylo_rouge',
          name: 'Stylo à bille Rouge',
          unitPrice: 100,
          defaultQuantities: {'CP1': 0, 'CP2': 0, 'CE1': 1, 'CE2': 1, 'CM1': 1, 'CM2': 1, '6E': 2, '5E': 2, '4E': 2, '3E': 2, '2NDE': 2, '1ERE': 2, 'TLE A': 2, 'TLE D': 2},
        ),
        CatalogItem(
          id: 'stylo_vert',
          name: 'Stylo à bille Vert',
          unitPrice: 100,
          defaultQuantities: {'CE1': 1, 'CE2': 1, 'CM1': 1, 'CM2': 1, '6E': 1, '5E': 1, '4E': 1, '3E': 1, '2NDE': 1, '1ERE': 1, 'TLE A': 1, 'TLE D': 1},
        ),
        CatalogItem(
          id: 'crayon',
          name: 'Crayon à papier (HB)',
          unitPrice: 50,
          defaultQuantities: {'CP1': 2, 'CP2': 2, 'CE1': 2, 'CE2': 2, 'CM1': 2, 'CM2': 2, '6E': 1, '5E': 1, '4E': 1, '3E': 1, '2NDE': 1, '1ERE': 1, 'TLE A': 1, 'TLE D': 1},
        ),
        CatalogItem(
          id: 'gomme',
          name: 'Gomme blanche',
          unitPrice: 100,
          defaultQuantities: {'CP1': 1, 'CP2': 1, 'CE1': 1, 'CE2': 1, 'CM1': 1, 'CM2': 1, '6E': 1, '5E': 1, '4E': 1, '3E': 1, '2NDE': 1, '1ERE': 1, 'TLE A': 1, 'TLE D': 1},
        ),
        CatalogItem(
          id: 'ensemble_geo',
          name: 'Ensemble géométrique (Règle, équerre, compas)',
          unitPrice: 500,
          defaultQuantities: {'CM1': 1, 'CM2': 1, '6E': 1, '5E': 1, '4E': 1, '3E': 1, '2NDE': 1, '1ERE': 1, 'TLE A': 1, 'TLE D': 1},
        ),
        CatalogItem(
          id: 'ardoise',
          name: 'Ardoise à craie',
          unitPrice: 300,
          defaultQuantities: {'CP1': 1, 'CP2': 1, 'CE1': 1, 'CE2': 1},
        ),
        CatalogItem(
          id: 'boite_craie_blanche',
          name: 'Boîte de craie blanche',
          unitPrice: 500,
          defaultQuantities: {'CP1': 1, 'CP2': 1, 'CE1': 1, 'CE2': 1},
        ),
        CatalogItem(
          id: 'boite_craie_couleur',
          name: 'Boîte de craie couleur',
          unitPrice: 500,
          defaultQuantities: {'CP1': 1, 'CP2': 1},
        ),
        CatalogItem(
          id: 'crayons_couleur',
          name: 'Boîte de crayons de couleur (12)',
          unitPrice: 600,
          defaultQuantities: {'CP1': 1, 'CP2': 1, 'CE1': 1, 'CE2': 1, 'CM1': 1, 'CM2': 1, '6E': 1, '5E': 1},
        ),
      ],
    ),
    CatalogCategory(
      name: 'Sacs & Divers',
      items: [
        CatalogItem(
          id: 'sac_dos',
          name: 'Sac au dos scolaire',
          unitPrice: 3500,
          defaultQuantities: {'CP1': 1, 'CP2': 1, 'CE1': 1, 'CE2': 1, 'CM1': 1, 'CM2': 1, '6E': 1, '5E': 1, '4E': 1, '3E': 1},
        ),
        CatalogItem(
          id: 'gourde',
          name: 'Gourde isotherme',
          unitPrice: 1500,
          defaultQuantities: {'CP1': 1, 'CP2': 1, 'CE1': 1, 'CE2': 1, 'CM1': 1, 'CM2': 1},
        ),
        CatalogItem(
          id: 'tenue_kaki',
          name: 'Tenue Kaki (Tissu au mètre)',
          unitPrice: 2000,
          unit: 'Mètre',
          defaultQuantities: {'CP1': 2, 'CP2': 2, 'CE1': 2, 'CE2': 2, 'CM1': 3, 'CM2': 3, '6E': 3, '5E': 3, '4E': 4, '3E': 4},
        ),
      ],
    ),
  ];
}
