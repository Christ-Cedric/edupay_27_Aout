import 'package:edupay/features/parent/domain/school_catalogue.dart';

/// Catalogue factice pour les tests : mêmes montants que l'ancien modèle codé
/// en dur (Kit Basique=12000, Essentiel=18500, Premium=27000 pour 'CM2'), afin
/// de garder les tests déterministes sans dépendre du contenu réel du fichier
/// Excel officiel (voir school_catalogue.dart / tools/generate_catalogue.py).
const fakeCatalogueJson = '''
{
  "classes": ["CM2"],
  "levels": {
    "CM2": {
      "cycle": "Primaire",
      "kits": {
        "basic": {
          "price": 12000,
          "items": [
            {"id": "cahiers_basic", "category": "Cahiers", "label": "Cahiers", "quantity": 6, "unitPrice": 2000}
          ]
        },
        "comfort": {
          "price": 18500,
          "items": [
            {"id": "cahiers_comfort", "category": "Cahiers", "label": "Cahiers", "quantity": 1, "unitPrice": 18500}
          ]
        },
        "complete": {
          "price": 27000,
          "items": [
            {"id": "cahiers_complete", "category": "Cahiers", "label": "Cahiers", "quantity": 1, "unitPrice": 27000}
          ]
        }
      },
      "articles": [
        {"id": "cahiers", "category": "Cahiers", "label": "Cahiers", "quantity": 1, "unitPrice": 2000},
        {"id": "stylos", "category": "Stylos", "label": "Stylos", "quantity": 1, "unitPrice": 250},
        {"id": "sac", "category": "Accessoires", "label": "Sac à dos", "quantity": 1, "unitPrice": 8500}
      ]
    }
  }
}
''';

void loadFakeCatalogue() => SchoolCatalogue.loadFromJson(fakeCatalogueJson);
