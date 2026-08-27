// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(financeRepository)
final financeRepositoryProvider = FinanceRepositoryProvider._();

final class FinanceRepositoryProvider
    extends
        $FunctionalProvider<
          FinanceRepository,
          FinanceRepository,
          FinanceRepository
        >
    with $Provider<FinanceRepository> {
  FinanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financeRepositoryHash();

  @$internal
  @override
  $ProviderElement<FinanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FinanceRepository create(Ref ref) {
    return financeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinanceRepository>(value),
    );
  }
}

String _$financeRepositoryHash() => r'd63aa182e35fdf3fa0b235d02189e863d0e1f8c5';

/// Watch explicite de `familiesListProvider` pour que ce résumé se
/// recalcule automatiquement à chaque inscription/encaissement/validation
/// (mêmes invalidations que la liste des familles), sans avoir à dupliquer
/// `ref.invalidate(financeSummaryProvider)` dans chaque controller.

@ProviderFor(financeSummary)
final financeSummaryProvider = FinanceSummaryProvider._();

/// Watch explicite de `familiesListProvider` pour que ce résumé se
/// recalcule automatiquement à chaque inscription/encaissement/validation
/// (mêmes invalidations que la liste des familles), sans avoir à dupliquer
/// `ref.invalidate(financeSummaryProvider)` dans chaque controller.

final class FinanceSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<FinanceSummary>,
          FinanceSummary,
          FutureOr<FinanceSummary>
        >
    with $FutureModifier<FinanceSummary>, $FutureProvider<FinanceSummary> {
  /// Watch explicite de `familiesListProvider` pour que ce résumé se
  /// recalcule automatiquement à chaque inscription/encaissement/validation
  /// (mêmes invalidations que la liste des familles), sans avoir à dupliquer
  /// `ref.invalidate(financeSummaryProvider)` dans chaque controller.
  FinanceSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financeSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financeSummaryHash();

  @$internal
  @override
  $FutureProviderElement<FinanceSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FinanceSummary> create(Ref ref) {
    return financeSummary(ref);
  }
}

String _$financeSummaryHash() => r'4a515b1bde18776ece42884c33cd37f328d488e9';
