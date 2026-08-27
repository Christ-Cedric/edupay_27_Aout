import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../families/domain/models/family_filter.dart';
import '../../../families/presentation/providers/families_providers.dart';
import '../../data/finance_repository.dart';
import '../../data/finance_repository_impl.dart';
import '../../domain/models/finance_summary.dart';

part 'finance_providers.g.dart';

@Riverpod(keepAlive: true)
FinanceRepository financeRepository(Ref ref) {
  return FinanceRepositoryImpl(ref.watch(familyRepositoryProvider));
}

/// Watch explicite de `familiesListProvider` pour que ce résumé se
/// recalcule automatiquement à chaque inscription/encaissement/validation
/// (mêmes invalidations que la liste des familles), sans avoir à dupliquer
/// `ref.invalidate(financeSummaryProvider)` dans chaque controller.
@riverpod
Future<FinanceSummary> financeSummary(Ref ref) {
  ref.watch(familiesListProvider(const FamilyFilter()));
  return ref.watch(financeRepositoryProvider).getSummary();
}
