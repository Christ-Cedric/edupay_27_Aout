import '../../../core/domain/school_level.dart';
import '../domain/models/kit.dart';

abstract interface class KitRepository {
  Future<List<Kit>> getKits();

  Future<Kit> getKitById(String id);

  /// `price` n'est jamais passé : toujours dérivé des fournitures (§ contrat
  /// 3.6, jamais saisi par l'admin).
  Future<Kit> createKit({
    required KitLevel level,
    required SchoolLevel schoolLevel,
    required List<KitItem> items,
  });

  Future<Kit> updateKit(Kit kit);

  /// Lance un [KitFailure] si des familles sont encore assignées à ce kit.
  Future<void> deleteKit(String id);

  Future<KitImportResult> importCatalog(String fileBase64);
}
