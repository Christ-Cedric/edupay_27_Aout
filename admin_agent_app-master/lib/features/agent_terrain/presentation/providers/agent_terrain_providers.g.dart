// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_terrain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

@ProviderFor(collectionDataSource)
final collectionDataSourceProvider = CollectionDataSourceProvider._();

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

final class CollectionDataSourceProvider
    extends
        $FunctionalProvider<
          CollectionDataSource,
          CollectionDataSource,
          CollectionDataSource
        >
    with $Provider<CollectionDataSource> {
  /// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
  CollectionDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionDataSourceHash();

  @$internal
  @override
  $ProviderElement<CollectionDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollectionDataSource create(Ref ref) {
    return collectionDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionDataSource>(value),
    );
  }
}

String _$collectionDataSourceHash() =>
    r'0fb6109c443a50a9bf9b36f151d085938712de96';

@ProviderFor(collectionRepository)
final collectionRepositoryProvider = CollectionRepositoryProvider._();

final class CollectionRepositoryProvider
    extends
        $FunctionalProvider<
          CollectionRepository,
          CollectionRepository,
          CollectionRepository
        >
    with $Provider<CollectionRepository> {
  CollectionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CollectionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollectionRepository create(Ref ref) {
    return collectionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionRepository>(value),
    );
  }
}

String _$collectionRepositoryHash() =>
    r'73e3b59a00024ea1ba71a7b3db29df8c7d587d22';

@ProviderFor(familyCollectionHistory)
final familyCollectionHistoryProvider = FamilyCollectionHistoryFamily._();

final class FamilyCollectionHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Collection>>,
          List<Collection>,
          FutureOr<List<Collection>>
        >
    with $FutureModifier<List<Collection>>, $FutureProvider<List<Collection>> {
  FamilyCollectionHistoryProvider._({
    required FamilyCollectionHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'familyCollectionHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$familyCollectionHistoryHash();

  @override
  String toString() {
    return r'familyCollectionHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Collection>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Collection>> create(Ref ref) {
    final argument = this.argument as String;
    return familyCollectionHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FamilyCollectionHistoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$familyCollectionHistoryHash() =>
    r'9b105b25000216ad62fc5acccb3b9d5d5dd0f33a';

final class FamilyCollectionHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Collection>>, String> {
  FamilyCollectionHistoryFamily._()
    : super(
        retry: null,
        name: r'familyCollectionHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FamilyCollectionHistoryProvider call(String familyId) =>
      FamilyCollectionHistoryProvider._(argument: familyId, from: this);

  @override
  String toString() => r'familyCollectionHistoryProvider';
}
