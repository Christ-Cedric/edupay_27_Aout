import '../../families/data/family_repository.dart';
import '../../families/domain/models/family.dart';
import '../../families/domain/models/family_filter.dart';
import '../../families/domain/models/family_status.dart';
import '../../families/domain/models/savings_plan.dart';
import '../domain/models/finance_summary.dart';
import 'finance_repository.dart';

/// Le bilan financier est entièrement dérivé des familles (le solde cotisé
/// de chaque famille porte déjà le montant collecté) — pas de source de
/// données propre, contrairement aux autres repositories.
class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl(this._familyRepository);

  final FamilyRepository _familyRepository;

  @override
  Future<FinanceSummary> getSummary() async {
    final families = await _familyRepository.getFamilies(const FamilyFilter());

    final totalCollected = families.fold<double>(
      0,
      (sum, f) => sum + f.balance,
    );
    final activeFamilies = families
        .where((f) => f.status == FamilyStatus.active)
        .length;

    final byCity = <String, List<Family>>{};
    for (final family in families) {
      byCity.putIfAbsent(family.city, () => []).add(family);
    }
    final byPlan = <SavingsPlan, List<Family>>{};
    for (final family in families) {
      byPlan.putIfAbsent(family.plan, () => []).add(family);
    }

    return FinanceSummary(
      totalCollected: totalCollected,
      activeFamilies: activeFamilies,
      byCity: [
        for (final entry in byCity.entries)
          CityBreakdown(
            city: entry.key,
            familyCount: entry.value.length,
            amount: entry.value.fold(0, (sum, f) => sum + f.balance),
          ),
      ],
      byPlan: [
        for (final entry in byPlan.entries)
          PlanBreakdown(
            plan: entry.key,
            familyCount: entry.value.length,
            amount: entry.value.fold(0, (sum, f) => sum + f.balance),
          ),
      ],
    );
  }
}
