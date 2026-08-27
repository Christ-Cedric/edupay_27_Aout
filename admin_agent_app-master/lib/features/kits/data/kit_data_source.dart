import '../../../core/domain/school_level.dart';
import '../domain/models/kit.dart';

/// Contrat de source de données du catalogue de kits — seam mock ↔ REST.
abstract interface class KitDataSource {
  Future<List<Kit>> fetchAll();

  Future<Kit> fetchById(String id);

  /// `price` n'est jamais passé : toujours dérivé des fournitures côté source.
  Future<Kit> create({
    required KitLevel level,
    required SchoolLevel schoolLevel,
    required List<KitItem> items,
  });

  Future<Kit> update(Kit kit);

  Future<void> delete(String id);

  /// Importe le catalogue fournisseur depuis un fichier Excel (encodé en
  /// base64) — jamais de suppression, upsert par (classe, variant).
  Future<KitImportResult> importCatalog(String fileBase64);
}
