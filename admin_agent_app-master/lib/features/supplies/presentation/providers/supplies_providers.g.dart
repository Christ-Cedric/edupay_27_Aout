// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplies_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

@ProviderFor(supplyDataSource)
final supplyDataSourceProvider = SupplyDataSourceProvider._();

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

final class SupplyDataSourceProvider
    extends
        $FunctionalProvider<
          SupplyDataSource,
          SupplyDataSource,
          SupplyDataSource
        >
    with $Provider<SupplyDataSource> {
  /// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
  SupplyDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplyDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplyDataSourceHash();

  @$internal
  @override
  $ProviderElement<SupplyDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupplyDataSource create(Ref ref) {
    return supplyDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupplyDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupplyDataSource>(value),
    );
  }
}

String _$supplyDataSourceHash() => r'd457973a0d8372ac2fc07c59f35796ad1d5d335c';

@ProviderFor(supplyRepository)
final supplyRepositoryProvider = SupplyRepositoryProvider._();

final class SupplyRepositoryProvider
    extends
        $FunctionalProvider<
          SupplyRepository,
          SupplyRepository,
          SupplyRepository
        >
    with $Provider<SupplyRepository> {
  SupplyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplyRepositoryHash();

  @$internal
  @override
  $ProviderElement<SupplyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupplyRepository create(Ref ref) {
    return supplyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupplyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupplyRepository>(value),
    );
  }
}

String _$supplyRepositoryHash() => r'bb0ee516e0ac98e66d580c70558d321d6dc52179';

@ProviderFor(suppliesList)
final suppliesListProvider = SuppliesListProvider._();

final class SuppliesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Supply>>,
          List<Supply>,
          FutureOr<List<Supply>>
        >
    with $FutureModifier<List<Supply>>, $FutureProvider<List<Supply>> {
  SuppliesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suppliesListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suppliesListHash();

  @$internal
  @override
  $FutureProviderElement<List<Supply>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Supply>> create(Ref ref) {
    return suppliesList(ref);
  }
}

String _$suppliesListHash() => r'6ffc7fc2964046943e6ca86ef0d35baf7836e0b2';

@ProviderFor(supplyDetail)
final supplyDetailProvider = SupplyDetailFamily._();

final class SupplyDetailProvider
    extends $FunctionalProvider<AsyncValue<Supply>, Supply, FutureOr<Supply>>
    with $FutureModifier<Supply>, $FutureProvider<Supply> {
  SupplyDetailProvider._({
    required SupplyDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'supplyDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$supplyDetailHash();

  @override
  String toString() {
    return r'supplyDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Supply> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Supply> create(Ref ref) {
    final argument = this.argument as String;
    return supplyDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplyDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$supplyDetailHash() => r'03c70374a94c6bddad0b98f76b96eb8c95d4743b';

final class SupplyDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Supply>, String> {
  SupplyDetailFamily._()
    : super(
        retry: null,
        name: r'supplyDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SupplyDetailProvider call(String id) =>
      SupplyDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'supplyDetailProvider';
}

@ProviderFor(SupplyCreateController)
final supplyCreateControllerProvider = SupplyCreateControllerProvider._();

final class SupplyCreateControllerProvider
    extends $AsyncNotifierProvider<SupplyCreateController, Supply?> {
  SupplyCreateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplyCreateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplyCreateControllerHash();

  @$internal
  @override
  SupplyCreateController create() => SupplyCreateController();
}

String _$supplyCreateControllerHash() =>
    r'dbee89c96934afa2e730e937e2ab23c728957bb2';

abstract class _$SupplyCreateController extends $AsyncNotifier<Supply?> {
  FutureOr<Supply?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Supply?>, Supply?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Supply?>, Supply?>,
              AsyncValue<Supply?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SupplyEditController)
final supplyEditControllerProvider = SupplyEditControllerProvider._();

final class SupplyEditControllerProvider
    extends $AsyncNotifierProvider<SupplyEditController, Supply?> {
  SupplyEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplyEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplyEditControllerHash();

  @$internal
  @override
  SupplyEditController create() => SupplyEditController();
}

String _$supplyEditControllerHash() =>
    r'8e227773223cd5ada174821b2cf801ce75039519';

abstract class _$SupplyEditController extends $AsyncNotifier<Supply?> {
  FutureOr<Supply?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Supply?>, Supply?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Supply?>, Supply?>,
              AsyncValue<Supply?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SupplyDeleteController)
final supplyDeleteControllerProvider = SupplyDeleteControllerProvider._();

final class SupplyDeleteControllerProvider
    extends $AsyncNotifierProvider<SupplyDeleteController, void> {
  SupplyDeleteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplyDeleteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplyDeleteControllerHash();

  @$internal
  @override
  SupplyDeleteController create() => SupplyDeleteController();
}

String _$supplyDeleteControllerHash() =>
    r'b014314cab528de65921b3f122d3586cb614a896';

abstract class _$SupplyDeleteController extends $AsyncNotifier<void> {
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
