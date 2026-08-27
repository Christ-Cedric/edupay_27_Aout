import '../domain/models/delivery_status.dart';
import '../domain/models/family.dart';
import '../domain/models/family_failure.dart';
import '../domain/models/family_filter.dart';
import '../domain/models/family_status.dart';
import '../domain/models/savings_plan.dart';
import 'family_data_source.dart';

/// Prix des kits seedés (miroir de `FakeKitDataSource`, pas d'accès
/// cross-feature depuis cette source de données) — sert uniquement à
/// répartir un objectif plausible par enfant dans les données mock.
const _mockKitPrices = {
  'kit-basic': 12000.0,
  'kit-intermediate': 18500.0,
  'kit-premium': 27000.0,
};

/// Répartit un total (objectif ou solde) sur [count] enfants du même kit —
/// juste pour que les données mock restent cohérentes, pas une vraie règle
/// métier (le backend, lui, additionne des `SavingsGoal` réels par enfant).
List<FamilyChild> _mockChildren({
  required String familyId,
  required List<String> firstNames,
  required List<String> levels,
  required String school,
  required String kitId,
  required double totalTarget,
  required double totalSaved,
}) {
  final count = firstNames.length;
  return List.generate(
    count,
    (i) => FamilyChild(
      id: '$familyId-child-${i + 1}',
      firstName: firstNames[i],
      level: levels[i],
      school: school,
      kitId: kitId,
      targetAmount: totalTarget / count,
      savedAmount: totalSaved / count,
    ),
  );
}

/// Source de données en mémoire, seedée avec les familles du prototype
/// (écrans `ad_fa`/`ad_do`) et deux comptes auto-inscrits en attente de
/// validation (règle métier ajoutée par le client, absente du prototype).
/// Mode `mock` du seam [FamilyDataSource].
class FakeFamilyDataSource implements FamilyDataSource {
  final List<Family> _families = [
    Family(
      id: 'fam-1',
      fullName: 'Aminata Kabore',
      phone: '+226 76 12 34 56',
      city: 'Koudougou',
      plan: SavingsPlan.weekly,
      balance: 24700,
      targetAmount: 39800,
      children: _mockChildren(
        familyId: 'fam-1',
        firstNames: const ['Awa', 'Boureima'],
        levels: const ['CM2', 'CE1'],
        school: 'École Centre - Koudougou',
        kitId: 'kit-intermediate',
        totalTarget: 39800,
        totalSaved: 24700,
      ),
      status: FamilyStatus.active,
      deliveryStatus: DeliveryStatus.pending,
      assignedAgentName: 'Konate Ali',
      registeredAt: DateTime(2026, 6, 24),
    ),
    Family(
      id: 'fam-2',
      fullName: 'Sawadogo Wendyam',
      phone: '+226 70 22 33 44',
      city: 'Koudougou',
      plan: SavingsPlan.daily,
      balance: 8100,
      targetAmount: 18000,
      children: _mockChildren(
        familyId: 'fam-2',
        firstNames: const ['Rasmane'],
        levels: const ['CM1'],
        school: 'École Centre - Koudougou',
        kitId: 'kit-basic',
        totalTarget: 18000,
        totalSaved: 8100,
      ),
      status: FamilyStatus.active,
      deliveryStatus: DeliveryStatus.pending,
      assignedAgentName: 'Konate Ali',
      registeredAt: DateTime(2026, 6, 20),
    ),
    Family(
      id: 'fam-3',
      fullName: 'Bila Ouedraogo',
      phone: '+226 78 55 66 77',
      city: 'Koudougou',
      plan: SavingsPlan.weekly,
      balance: 8000,
      targetAmount: 16000,
      children: _mockChildren(
        familyId: 'fam-3',
        firstNames: const ['Salamata'],
        levels: const ['6ème'],
        school: 'Collège Municipal - Koudougou',
        kitId: 'kit-intermediate',
        totalTarget: 16000,
        totalSaved: 8000,
      ),
      status: FamilyStatus.lateOverdue,
      deliveryStatus: DeliveryStatus.pending,
      assignedAgentName: 'Konate Ali',
      registeredAt: DateTime(2026, 5, 10),
    ),
    Family(
      id: 'fam-4',
      fullName: 'Kabore Fatoumata',
      phone: '+226 65 88 99 00',
      city: 'Ouagadougou',
      plan: SavingsPlan.monthly,
      balance: 18500,
      targetAmount: 18500,
      children: _mockChildren(
        familyId: 'fam-4',
        firstNames: const ['Fatao', 'Idrissa', 'Salif'],
        levels: const ['Terminale', '3ème', 'CP'],
        school: 'Lycée Provincial - Ouagadougou',
        kitId: 'kit-premium',
        totalTarget: 18500,
        totalSaved: 18500,
      ),
      status: FamilyStatus.active,
      deliveryStatus: DeliveryStatus.delivered,
      assignedAgentName: 'Sana Wendyam',
      registeredAt: DateTime(2026, 4, 2),
    ),
    Family(
      id: 'fam-5',
      fullName: 'Ouedraogo Marie',
      phone: '+226 70 45 67 89',
      city: 'Koudougou',
      plan: SavingsPlan.weekly,
      balance: 0,
      targetAmount: 18500,
      children: _mockChildren(
        familyId: 'fam-5',
        firstNames: const ['Marie Jr'],
        levels: const ['CM2'],
        school: 'École Centre - Koudougou',
        kitId: 'kit-intermediate',
        totalTarget: 18500,
        totalSaved: 0,
      ),
      status: FamilyStatus.pendingValidation,
      deliveryStatus: DeliveryStatus.pending,
      registeredAt: DateTime(2026, 7, 10),
    ),
    Family(
      id: 'fam-6',
      fullName: 'Zongo Ibrahim',
      phone: '+226 65 44 55 66',
      city: 'Ouagadougou',
      plan: SavingsPlan.daily,
      balance: 0,
      targetAmount: 12000,
      children: _mockChildren(
        familyId: 'fam-6',
        firstNames: const ['Ibrahim Jr'],
        levels: const ['CE2'],
        school: 'École Publique - Ouagadougou',
        kitId: 'kit-basic',
        totalTarget: 12000,
        totalSaved: 0,
      ),
      status: FamilyStatus.pendingValidation,
      deliveryStatus: DeliveryStatus.pending,
      registeredAt: DateTime(2026, 7, 12),
    ),
  ];

  @override
  Future<List<Family>> fetchAll(FamilyFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _families.where((family) {
      final matchesQuery =
          filter.query.isEmpty ||
          family.fullName.toLowerCase().contains(filter.query.toLowerCase());
      final matchesStatus =
          filter.status == null || family.status == filter.status;
      final matchesCity = filter.city == null || family.city == filter.city;
      final matchesAgent =
          filter.assignedAgentName == null ||
          family.assignedAgentName == filter.assignedAgentName;
      return matchesQuery && matchesStatus && matchesCity && matchesAgent;
    }).toList();
  }

  @override
  Future<Family> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _families.firstWhere((f) => f.id == id);
  }

  @override
  Future<Family> enroll({
    required String fullName,
    required String phone,
    required SavingsPlan plan,
    required List<ChildEnrollmentInput> children,
    String? assignedAgentName,
    required String city,
    String? district,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final id = 'fam-${_families.length + 1}';
    final familyChildren = [
      for (var i = 0; i < children.length; i++)
        FamilyChild(
          id: '$id-child-${i + 1}',
          firstName: children[i].firstName,
          level: children[i].level ?? '',
          school: children[i].school ?? '',
          kitId: children[i].kitId,
          targetAmount: _mockKitPrices[children[i].kitId] ?? 18500,
          savedAmount: 0,
        ),
    ];
    final family = Family(
      id: id,
      fullName: fullName,
      phone: phone,
      city: city,
      district: district,
      plan: plan,
      balance: 0,
      targetAmount: familyChildren.fold(0, (sum, c) => sum + (c.targetAmount ?? 0)),
      children: familyChildren,
      status: FamilyStatus.active,
      deliveryStatus: DeliveryStatus.pending,
      assignedAgentName: assignedAgentName,
      registeredAt: DateTime.now(),
    );
    _families.add(family);
    return family;
  }

  @override
  Future<void> approve(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _replace(id, (f) => f.copyWith(status: FamilyStatus.active));
  }

  @override
  Future<void> reject(String id, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _replace(
      id,
      (f) => f.copyWith(status: FamilyStatus.rejected, rejectionReason: reason),
    );
  }

  @override
  Future<Family> recordCashContribution({
    required String familyId,
    required int amount,
    String? collectedByAgentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final family = await fetchById(familyId);
    // Même règle que le backend (payments.service.ts) : un compte doit être
    // actif pour recevoir un encaissement.
    if (family.status == FamilyStatus.pendingValidation) {
      throw const FamilyFailure(
        "Ce compte est en attente de validation — impossible d'enregistrer une cotisation avant son approbation.",
      );
    }
    if (family.status != FamilyStatus.active) {
      throw const FamilyFailure(
        "Ce compte n'est pas actif — impossible d'enregistrer une cotisation.",
      );
    }
    final remaining = family.targetAmount - family.balance;
    if (amount > remaining) {
      throw FamilyFailure(
        'Le montant dépasse le besoin restant (${remaining.round()} FCFA).',
      );
    }
    _replace(familyId, (f) => f.copyWith(balance: f.balance + amount));
    return fetchById(familyId);
  }

  @override
  Future<void> reportIncident(String familyId, String note) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<Family> addChild({
    required String familyId,
    required String firstName,
    String? level,
    String? school,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final child = FamilyChild(
      id: '$familyId-child-${DateTime.now().microsecondsSinceEpoch}',
      firstName: firstName,
      level: level ?? '',
      school: school ?? '',
    );
    _replace(familyId, (f) => f.copyWith(children: [...f.children, child]));
    return fetchById(familyId);
  }

  @override
  Future<Family> updateChild({
    required String familyId,
    required String childId,
    String? level,
    String? school,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _replace(
      familyId,
      (f) => f.copyWith(
        children: [
          for (final c in f.children)
            if (c.id == childId)
              c.copyWith(level: level ?? c.level, school: school ?? c.school)
            else
              c,
        ],
      ),
    );
    return fetchById(familyId);
  }

  @override
  Future<Family> removeChild({required String familyId, required String childId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final family = await fetchById(familyId);
    final child = family.children.firstWhere((c) => c.id == childId);
    // Même règle que le backend : un enfant qui a déjà un objectif (donc un
    // historique de cotisation, même soldé) ne peut pas être retiré.
    if (child.hasKitThisSeason) {
      throw const FamilyFailure(
        'Impossible de retirer cet enfant : il a déjà un historique de cotisation.',
      );
    }
    _replace(
      familyId,
      (f) => f.copyWith(
        children: f.children.where((c) => c.id != childId).toList(),
      ),
    );
    return fetchById(familyId);
  }

  @override
  Future<Family> assignKit({
    required String familyId,
    required String childId,
    required String kitId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final targetAmount = _mockKitPrices[kitId] ?? 18500;
    _replace(
      familyId,
      (f) => f.copyWith(
        children: [
          for (final c in f.children)
            if (c.id == childId)
              c.copyWith(kitId: kitId, targetAmount: targetAmount, savedAmount: c.savedAmount ?? 0)
            else
              c,
        ],
      ),
    );
    return fetchById(familyId);
  }

  void _replace(String id, Family Function(Family) update) {
    final index = _families.indexWhere((f) => f.id == id);
    if (index != -1) _families[index] = update(_families[index]);
  }
}
