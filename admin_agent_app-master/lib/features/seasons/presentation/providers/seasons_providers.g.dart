// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seasons_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

@ProviderFor(seasonDataSource)
final seasonDataSourceProvider = SeasonDataSourceProvider._();

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

final class SeasonDataSourceProvider
    extends
        $FunctionalProvider<
          SeasonDataSource,
          SeasonDataSource,
          SeasonDataSource
        >
    with $Provider<SeasonDataSource> {
  /// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
  SeasonDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seasonDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seasonDataSourceHash();

  @$internal
  @override
  $ProviderElement<SeasonDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeasonDataSource create(Ref ref) {
    return seasonDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeasonDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeasonDataSource>(value),
    );
  }
}

String _$seasonDataSourceHash() => r'e4707b26f674e5d93261590c926153766fddf808';

@ProviderFor(seasonRepository)
final seasonRepositoryProvider = SeasonRepositoryProvider._();

final class SeasonRepositoryProvider
    extends
        $FunctionalProvider<
          SeasonRepository,
          SeasonRepository,
          SeasonRepository
        >
    with $Provider<SeasonRepository> {
  SeasonRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seasonRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seasonRepositoryHash();

  @$internal
  @override
  $ProviderElement<SeasonRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeasonRepository create(Ref ref) {
    return seasonRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeasonRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeasonRepository>(value),
    );
  }
}

String _$seasonRepositoryHash() => r'89ad2fd4bdba2ec754b04c58e4637e8a884cc179';

@ProviderFor(currentSeason)
final currentSeasonProvider = CurrentSeasonProvider._();

final class CurrentSeasonProvider
    extends $FunctionalProvider<AsyncValue<Season>, Season, FutureOr<Season>>
    with $FutureModifier<Season>, $FutureProvider<Season> {
  CurrentSeasonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSeasonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSeasonHash();

  @$internal
  @override
  $FutureProviderElement<Season> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Season> create(Ref ref) {
    return currentSeason(ref);
  }
}

String _$currentSeasonHash() => r'1ec2503cea289dd0542b65d7116e05a0b6cb7ca0';

@ProviderFor(seasonsList)
final seasonsListProvider = SeasonsListProvider._();

final class SeasonsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Season>>,
          List<Season>,
          FutureOr<List<Season>>
        >
    with $FutureModifier<List<Season>>, $FutureProvider<List<Season>> {
  SeasonsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seasonsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seasonsListHash();

  @$internal
  @override
  $FutureProviderElement<List<Season>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Season>> create(Ref ref) {
    return seasonsList(ref);
  }
}

String _$seasonsListHash() => r'726747942753dccb774cd1b299aeab646c158a79';

@ProviderFor(SeasonEditController)
final seasonEditControllerProvider = SeasonEditControllerProvider._();

final class SeasonEditControllerProvider
    extends $AsyncNotifierProvider<SeasonEditController, Season?> {
  SeasonEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seasonEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seasonEditControllerHash();

  @$internal
  @override
  SeasonEditController create() => SeasonEditController();
}

String _$seasonEditControllerHash() =>
    r'85a8edf4fad75634174c3e10a3f48f76703d6654';

abstract class _$SeasonEditController extends $AsyncNotifier<Season?> {
  FutureOr<Season?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Season?>, Season?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Season?>, Season?>,
              AsyncValue<Season?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Création d'une nouvelle saison et bascule de la saison courante — motif
/// "Gestion des saisons" (écran `SeasonsListScreen`/`NewSeasonScreen`).

@ProviderFor(SeasonCreateController)
final seasonCreateControllerProvider = SeasonCreateControllerProvider._();

/// Création d'une nouvelle saison et bascule de la saison courante — motif
/// "Gestion des saisons" (écran `SeasonsListScreen`/`NewSeasonScreen`).
final class SeasonCreateControllerProvider
    extends $AsyncNotifierProvider<SeasonCreateController, Season?> {
  /// Création d'une nouvelle saison et bascule de la saison courante — motif
  /// "Gestion des saisons" (écran `SeasonsListScreen`/`NewSeasonScreen`).
  SeasonCreateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seasonCreateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seasonCreateControllerHash();

  @$internal
  @override
  SeasonCreateController create() => SeasonCreateController();
}

String _$seasonCreateControllerHash() =>
    r'285252515ab84c934ee3481eace0c643e4fb4de8';

/// Création d'une nouvelle saison et bascule de la saison courante — motif
/// "Gestion des saisons" (écran `SeasonsListScreen`/`NewSeasonScreen`).

abstract class _$SeasonCreateController extends $AsyncNotifier<Season?> {
  FutureOr<Season?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Season?>, Season?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Season?>, Season?>,
              AsyncValue<Season?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SeasonSwitchController)
final seasonSwitchControllerProvider = SeasonSwitchControllerProvider._();

final class SeasonSwitchControllerProvider
    extends $AsyncNotifierProvider<SeasonSwitchController, void> {
  SeasonSwitchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seasonSwitchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seasonSwitchControllerHash();

  @$internal
  @override
  SeasonSwitchController create() => SeasonSwitchController();
}

String _$seasonSwitchControllerHash() =>
    r'b21f14350450f9b8b1db61f20cc252740de27bc3';

abstract class _$SeasonSwitchController extends $AsyncNotifier<void> {
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
