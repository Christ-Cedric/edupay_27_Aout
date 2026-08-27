// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kits_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

@ProviderFor(kitDataSource)
final kitDataSourceProvider = KitDataSourceProvider._();

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

final class KitDataSourceProvider
    extends $FunctionalProvider<KitDataSource, KitDataSource, KitDataSource>
    with $Provider<KitDataSource> {
  /// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
  KitDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitDataSourceHash();

  @$internal
  @override
  $ProviderElement<KitDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KitDataSource create(Ref ref) {
    return kitDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KitDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KitDataSource>(value),
    );
  }
}

String _$kitDataSourceHash() => r'27af05d0c4f24c7e77de50bdba55cb924519917b';

@ProviderFor(kitRepository)
final kitRepositoryProvider = KitRepositoryProvider._();

final class KitRepositoryProvider
    extends $FunctionalProvider<KitRepository, KitRepository, KitRepository>
    with $Provider<KitRepository> {
  KitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitRepositoryHash();

  @$internal
  @override
  $ProviderElement<KitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KitRepository create(Ref ref) {
    return kitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KitRepository>(value),
    );
  }
}

String _$kitRepositoryHash() => r'71059a5235f9438ee73ab5ebe88c2820d7ab90e5';

@ProviderFor(kitsList)
final kitsListProvider = KitsListProvider._();

final class KitsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Kit>>,
          List<Kit>,
          FutureOr<List<Kit>>
        >
    with $FutureModifier<List<Kit>>, $FutureProvider<List<Kit>> {
  KitsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitsListHash();

  @$internal
  @override
  $FutureProviderElement<List<Kit>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Kit>> create(Ref ref) {
    return kitsList(ref);
  }
}

String _$kitsListHash() => r'a4f7cabba1f588232db6046791cb5f988aa5b656';

@ProviderFor(kitDetail)
final kitDetailProvider = KitDetailFamily._();

final class KitDetailProvider
    extends $FunctionalProvider<AsyncValue<Kit>, Kit, FutureOr<Kit>>
    with $FutureModifier<Kit>, $FutureProvider<Kit> {
  KitDetailProvider._({
    required KitDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'kitDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$kitDetailHash();

  @override
  String toString() {
    return r'kitDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Kit> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Kit> create(Ref ref) {
    final argument = this.argument as String;
    return kitDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is KitDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$kitDetailHash() => r'b7978963f934a5bda12b3c8e6e29b7fbbc3a670c';

final class KitDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Kit>, String> {
  KitDetailFamily._()
    : super(
        retry: null,
        name: r'kitDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  KitDetailProvider call(String id) =>
      KitDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'kitDetailProvider';
}

@ProviderFor(KitEditController)
final kitEditControllerProvider = KitEditControllerProvider._();

final class KitEditControllerProvider
    extends $AsyncNotifierProvider<KitEditController, Kit?> {
  KitEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitEditControllerHash();

  @$internal
  @override
  KitEditController create() => KitEditController();
}

String _$kitEditControllerHash() => r'6da7911cbf311bc42b3fa9fe9cf851152e486e95';

abstract class _$KitEditController extends $AsyncNotifier<Kit?> {
  FutureOr<Kit?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Kit?>, Kit?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Kit?>, Kit?>,
              AsyncValue<Kit?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(KitCreateController)
final kitCreateControllerProvider = KitCreateControllerProvider._();

final class KitCreateControllerProvider
    extends $AsyncNotifierProvider<KitCreateController, Kit?> {
  KitCreateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitCreateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitCreateControllerHash();

  @$internal
  @override
  KitCreateController create() => KitCreateController();
}

String _$kitCreateControllerHash() =>
    r'42d6f4f1ef12d20dfdfa8167ffa48be8b5ce20bd';

abstract class _$KitCreateController extends $AsyncNotifier<Kit?> {
  FutureOr<Kit?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Kit?>, Kit?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Kit?>, Kit?>,
              AsyncValue<Kit?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(KitDeleteController)
final kitDeleteControllerProvider = KitDeleteControllerProvider._();

final class KitDeleteControllerProvider
    extends $AsyncNotifierProvider<KitDeleteController, void> {
  KitDeleteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitDeleteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitDeleteControllerHash();

  @$internal
  @override
  KitDeleteController create() => KitDeleteController();
}

String _$kitDeleteControllerHash() =>
    r'e54066c8dda4f907240475b1bb1a47feec423acc';

abstract class _$KitDeleteController extends $AsyncNotifier<void> {
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

@ProviderFor(KitImportController)
final kitImportControllerProvider = KitImportControllerProvider._();

final class KitImportControllerProvider
    extends $AsyncNotifierProvider<KitImportController, KitImportResult?> {
  KitImportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitImportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitImportControllerHash();

  @$internal
  @override
  KitImportController create() => KitImportController();
}

String _$kitImportControllerHash() =>
    r'75e839903084611a69572bd7bbe9fa6b66307e09';

abstract class _$KitImportController extends $AsyncNotifier<KitImportResult?> {
  FutureOr<KitImportResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<KitImportResult?>, KitImportResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<KitImportResult?>, KitImportResult?>,
              AsyncValue<KitImportResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
