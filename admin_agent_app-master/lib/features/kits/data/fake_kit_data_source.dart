import '../../../core/domain/school_level.dart';
import '../domain/models/kit.dart';
import '../domain/models/kit_failure.dart';
import 'kit_data_source.dart';

/// Source de données en mémoire, seedée avec quelques kits réalistes (pas le
/// catalogue complet — 84 kits — qui n'a de sens qu'importé depuis le vrai
/// fichier fournisseur). Mode `mock` du seam [KitDataSource].
class FakeKitDataSource implements KitDataSource {
  final List<Kit> _kits = [
    // Ids historiques conservés tels quels (référencés par les familles
    // mock et plusieurs tests).
    Kit(
      id: 'kit-basic',
      level: KitLevel.basic,
      schoolLevel: SchoolLevel.cp1,
      price: computeItemsTotal(const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '5 cahiers',
          quantity: 5,
          unit: 'unité',
          unitPrice: 500,
        ),
        KitItem(
          category: 'Ardoise',
          label: 'Ardoise',
          quantity: 1,
          unit: 'unité',
          unitPrice: 1500,
        ),
        KitItem(
          category: 'Écriture',
          label: 'Stylos',
          quantity: 4,
          unit: 'unité',
          unitPrice: 250,
        ),
        KitItem(
          category: 'Écriture',
          label: 'Crayons',
          quantity: 3,
          unit: 'unité',
          unitPrice: 200,
        ),
      ]),
      items: const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '5 cahiers',
          quantity: 5,
          unit: 'unité',
          unitPrice: 500,
        ),
        KitItem(
          category: 'Ardoise',
          label: 'Ardoise',
          quantity: 1,
          unit: 'unité',
          unitPrice: 1500,
        ),
        KitItem(
          category: 'Écriture',
          label: 'Stylos',
          quantity: 4,
          unit: 'unité',
          unitPrice: 250,
        ),
        KitItem(
          category: 'Écriture',
          label: 'Crayons',
          quantity: 3,
          unit: 'unité',
          unitPrice: 200,
        ),
      ],
    ),
    Kit(
      id: 'kit-intermediate',
      level: KitLevel.intermediate,
      schoolLevel: SchoolLevel.cm2,
      price: computeItemsTotal(const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '8 cahiers 192 pages',
          quantity: 8,
          unit: 'unité',
          unitPrice: 800,
        ),
        KitItem(
          category: 'Ardoise',
          label: 'Ardoise + craie',
          quantity: 1,
          unit: 'unité',
          unitPrice: 1500,
        ),
        KitItem(
          category: 'Trousse',
          label: 'Trousse complète',
          quantity: 1,
          unit: 'unité',
          unitPrice: 3500,
        ),
        KitItem(
          category: 'Cartable',
          label: 'Cartable simple',
          quantity: 1,
          unit: 'unité',
          unitPrice: 6000,
        ),
      ]),
      items: const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '8 cahiers 192 pages',
          quantity: 8,
          unit: 'unité',
          unitPrice: 800,
        ),
        KitItem(
          category: 'Ardoise',
          label: 'Ardoise + craie',
          quantity: 1,
          unit: 'unité',
          unitPrice: 1500,
        ),
        KitItem(
          category: 'Trousse',
          label: 'Trousse complète',
          quantity: 1,
          unit: 'unité',
          unitPrice: 3500,
        ),
        KitItem(
          category: 'Cartable',
          label: 'Cartable simple',
          quantity: 1,
          unit: 'unité',
          unitPrice: 6000,
        ),
      ],
    ),
    Kit(
      id: 'kit-premium',
      level: KitLevel.premium,
      schoolLevel: SchoolLevel.terminaleD,
      price: computeItemsTotal(const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '10 cahiers',
          quantity: 10,
          unit: 'unité',
          unitPrice: 800,
        ),
        KitItem(
          category: 'Cartable',
          label: 'Sac à dos marqué',
          quantity: 1,
          unit: 'unité',
          unitPrice: 9000,
        ),
        KitItem(
          category: 'Géométrie (BAC)',
          label: 'Géométrie complète',
          quantity: 1,
          unit: 'lot',
          unitPrice: 4500,
        ),
      ]),
      items: const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '10 cahiers',
          quantity: 10,
          unit: 'unité',
          unitPrice: 800,
        ),
        KitItem(
          category: 'Cartable',
          label: 'Sac à dos marqué',
          quantity: 1,
          unit: 'unité',
          unitPrice: 9000,
        ),
        KitItem(
          category: 'Géométrie (BAC)',
          label: 'Géométrie complète',
          quantity: 1,
          unit: 'lot',
          unitPrice: 4500,
        ),
      ],
    ),
    // Kits supplémentaires : CM2 a ses 3 variants pour illustrer le
    // catalogue classe × variant (contrat §3.6) au-delà d'un seul exemple.
    Kit(
      id: 'kit-cm2-basic',
      level: KitLevel.basic,
      schoolLevel: SchoolLevel.cm2,
      price: computeItemsTotal(const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '6 cahiers 96 pages',
          quantity: 6,
          unit: 'unité',
          unitPrice: 400,
        ),
        KitItem(
          category: 'Ardoise',
          label: 'Ardoise',
          quantity: 1,
          unit: 'unité',
          unitPrice: 1500,
        ),
        KitItem(
          category: 'Trousse',
          label: 'Trousse simple',
          quantity: 1,
          unit: 'unité',
          unitPrice: 2000,
        ),
      ]),
      items: const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '6 cahiers 96 pages',
          quantity: 6,
          unit: 'unité',
          unitPrice: 400,
        ),
        KitItem(
          category: 'Ardoise',
          label: 'Ardoise',
          quantity: 1,
          unit: 'unité',
          unitPrice: 1500,
        ),
        KitItem(
          category: 'Trousse',
          label: 'Trousse simple',
          quantity: 1,
          unit: 'unité',
          unitPrice: 2000,
        ),
      ],
    ),
    Kit(
      id: 'kit-cm2-premium',
      level: KitLevel.premium,
      schoolLevel: SchoolLevel.cm2,
      price: computeItemsTotal(const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '10 cahiers',
          quantity: 10,
          unit: 'unité',
          unitPrice: 800,
        ),
        KitItem(
          category: 'Cartable',
          label: 'Cartable renforcé',
          quantity: 1,
          unit: 'unité',
          unitPrice: 8000,
        ),
        KitItem(
          category: 'Géométrie',
          label: 'Géométrie complète',
          quantity: 1,
          unit: 'lot',
          unitPrice: 3000,
        ),
      ]),
      items: const [
        KitItem(
          category: 'Cahiers & Écriture',
          label: '10 cahiers',
          quantity: 10,
          unit: 'unité',
          unitPrice: 800,
        ),
        KitItem(
          category: 'Cartable',
          label: 'Cartable renforcé',
          quantity: 1,
          unit: 'unité',
          unitPrice: 8000,
        ),
        KitItem(
          category: 'Géométrie',
          label: 'Géométrie complète',
          quantity: 1,
          unit: 'lot',
          unitPrice: 3000,
        ),
      ],
    ),
  ];

  @override
  Future<List<Kit>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_kits);
  }

  @override
  Future<Kit> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _kits.firstWhere(
      (k) => k.id == id,
      orElse: () => throw KitFailure('Kit introuvable : $id'),
    );
  }

  @override
  Future<Kit> create({
    required KitLevel level,
    required SchoolLevel schoolLevel,
    required List<KitItem> items,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final kit = Kit(
      id: 'kit-${_kits.length + 1}',
      level: level,
      schoolLevel: schoolLevel,
      price: computeItemsTotal(items),
      items: items,
    );
    _kits.add(kit);
    return kit;
  }

  @override
  Future<Kit> update(Kit kit) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _kits.indexWhere((k) => k.id == kit.id);
    final saved = kit.copyWith(price: computeItemsTotal(kit.items));
    if (index != -1) _kits[index] = saved;
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _kits.removeWhere((k) => k.id == id);
  }

  @override
  Future<KitImportResult> importCatalog(String fileBase64) async {
    // Mode mock : le parsing du fichier Excel est fait côté serveur
    // (`exceljs`), rien d'équivalent ici — on ne simule qu'un résultat vide.
    await Future.delayed(const Duration(milliseconds: 500));
    return const KitImportResult(
      created: 0,
      updated: 0,
      warnings: [
        'Mode démo : l\'import de catalogue nécessite le backend réel.',
      ],
    );
  }
}
