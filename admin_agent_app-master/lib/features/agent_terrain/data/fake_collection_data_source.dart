import '../domain/models/collection.dart';
import '../domain/models/collection_mode.dart';
import 'collection_data_source.dart';

/// Source de données en mémoire, seedée avec l'historique de cotisations du
/// prototype (bas de la fiche client `ag_fi`). Mode `mock` du seam
/// [CollectionDataSource].
class FakeCollectionDataSource implements CollectionDataSource {
  final List<Collection> _collections = [
    Collection(
      id: 'col-1',
      familyId: 'fam-1',
      familyName: 'Aminata Kabore',
      agentName: 'Konate Ali',
      amount: 2000,
      mode: CollectionMode.cash,
      collectedAt: DateTime.now().subtract(const Duration(days: 1)),
      receiptNumber: 'EP-RC-2026-0148',
    ),
    Collection(
      id: 'col-2',
      familyId: 'fam-1',
      familyName: 'Aminata Kabore',
      agentName: 'Konate Ali',
      amount: 2000,
      mode: CollectionMode.cash,
      collectedAt: DateTime.now(),
      receiptNumber: 'EP-RC-2026-0149',
    ),
  ];

  @override
  Future<List<Collection>> fetchForFamily(String familyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _collections.where((c) => c.familyId == familyId).toList();
  }

  @override
  Future<List<Collection>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_collections);
  }
}
