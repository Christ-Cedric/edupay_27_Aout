import '../../../core/domain/school_level.dart';
import '../../families/data/family_repository.dart';
import '../../families/domain/models/family_filter.dart';
import '../domain/models/kit.dart';
import '../domain/models/kit_failure.dart';
import 'kit_data_source.dart';
import 'kit_repository.dart';

class KitRepositoryImpl implements KitRepository {
  KitRepositoryImpl(this._dataSource, this._familyRepository);

  final KitDataSource _dataSource;
  final FamilyRepository _familyRepository;

  @override
  Future<List<Kit>> getKits() => _dataSource.fetchAll();

  @override
  Future<Kit> getKitById(String id) => _dataSource.fetchById(id);

  @override
  Future<Kit> createKit({
    required KitLevel level,
    required SchoolLevel schoolLevel,
    required List<KitItem> items,
  }) {
    return _dataSource.create(level: level, schoolLevel: schoolLevel, items: items);
  }

  @override
  Future<Kit> updateKit(Kit kit) => _dataSource.update(kit);

  @override
  Future<void> deleteKit(String id) async {
    // Un kit est assigné par enfant (§7 #2 du contrat), pas par famille.
    final families = await _familyRepository.getFamilies(const FamilyFilter());
    final inUseCount = families
        .expand((f) => f.children)
        .where((c) => c.kitId == id)
        .length;
    if (inUseCount > 0) {
      throw KitFailure(
        'Ce kit est assigné à $inUseCount enfant(s) — impossible de le '
        'supprimer.',
      );
    }
    await _dataSource.delete(id);
  }

  @override
  Future<KitImportResult> importCatalog(String fileBase64) =>
      _dataSource.importCatalog(fileBase64);
}
