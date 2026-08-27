// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refunds_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

@ProviderFor(refundDataSource)
final refundDataSourceProvider = RefundDataSourceProvider._();

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

final class RefundDataSourceProvider
    extends
        $FunctionalProvider<
          RefundDataSource,
          RefundDataSource,
          RefundDataSource
        >
    with $Provider<RefundDataSource> {
  /// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
  RefundDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refundDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refundDataSourceHash();

  @$internal
  @override
  $ProviderElement<RefundDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RefundDataSource create(Ref ref) {
    return refundDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefundDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefundDataSource>(value),
    );
  }
}

String _$refundDataSourceHash() => r'24addf15b3ae88b669a8510dfb2a7be351d19455';

@ProviderFor(refundRepository)
final refundRepositoryProvider = RefundRepositoryProvider._();

final class RefundRepositoryProvider
    extends
        $FunctionalProvider<
          RefundRepository,
          RefundRepository,
          RefundRepository
        >
    with $Provider<RefundRepository> {
  RefundRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refundRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refundRepositoryHash();

  @$internal
  @override
  $ProviderElement<RefundRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RefundRepository create(Ref ref) {
    return refundRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefundRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefundRepository>(value),
    );
  }
}

String _$refundRepositoryHash() => r'87523717d50eb3c75f158d9a86e26a690a0386f7';

@ProviderFor(pendingRefunds)
final pendingRefundsProvider = PendingRefundsProvider._();

final class PendingRefundsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RefundRequest>>,
          List<RefundRequest>,
          FutureOr<List<RefundRequest>>
        >
    with
        $FutureModifier<List<RefundRequest>>,
        $FutureProvider<List<RefundRequest>> {
  PendingRefundsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRefundsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRefundsHash();

  @$internal
  @override
  $FutureProviderElement<List<RefundRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RefundRequest>> create(Ref ref) {
    return pendingRefunds(ref);
  }
}

String _$pendingRefundsHash() => r'c1759bfc55028c7aebd2b632e8300e89f9c4fce5';

@ProviderFor(refundDetail)
final refundDetailProvider = RefundDetailFamily._();

final class RefundDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<RefundDetail>,
          RefundDetail,
          FutureOr<RefundDetail>
        >
    with $FutureModifier<RefundDetail>, $FutureProvider<RefundDetail> {
  RefundDetailProvider._({
    required RefundDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'refundDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$refundDetailHash();

  @override
  String toString() {
    return r'refundDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RefundDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RefundDetail> create(Ref ref) {
    final argument = this.argument as String;
    return refundDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RefundDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$refundDetailHash() => r'760705b04cc01a1415687bdbfc46643c19a0e2dd';

final class RefundDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RefundDetail>, String> {
  RefundDetailFamily._()
    : super(
        retry: null,
        name: r'refundDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RefundDetailProvider call(String id) =>
      RefundDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'refundDetailProvider';
}

@ProviderFor(refundMonthSummary)
final refundMonthSummaryProvider = RefundMonthSummaryProvider._();

final class RefundMonthSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<RefundMonthSummary>,
          RefundMonthSummary,
          FutureOr<RefundMonthSummary>
        >
    with
        $FutureModifier<RefundMonthSummary>,
        $FutureProvider<RefundMonthSummary> {
  RefundMonthSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refundMonthSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refundMonthSummaryHash();

  @$internal
  @override
  $FutureProviderElement<RefundMonthSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RefundMonthSummary> create(Ref ref) {
    return refundMonthSummary(ref);
  }
}

String _$refundMonthSummaryHash() =>
    r'bd3f2ee6233acf7a7cd00c91f37671e9c7096602';

@ProviderFor(RefundValidationController)
final refundValidationControllerProvider =
    RefundValidationControllerProvider._();

final class RefundValidationControllerProvider
    extends $AsyncNotifierProvider<RefundValidationController, void> {
  RefundValidationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refundValidationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refundValidationControllerHash();

  @$internal
  @override
  RefundValidationController create() => RefundValidationController();
}

String _$refundValidationControllerHash() =>
    r'ccec1e174c0b2044668ee42bd7e8938d971dd18a';

abstract class _$RefundValidationController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
