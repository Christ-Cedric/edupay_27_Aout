// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'families_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

@ProviderFor(familyDataSource)
final familyDataSourceProvider = FamilyDataSourceProvider._();

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

final class FamilyDataSourceProvider
    extends
        $FunctionalProvider<
          FamilyDataSource,
          FamilyDataSource,
          FamilyDataSource
        >
    with $Provider<FamilyDataSource> {
  /// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
  FamilyDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyDataSourceHash();

  @$internal
  @override
  $ProviderElement<FamilyDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FamilyDataSource create(Ref ref) {
    return familyDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyDataSource>(value),
    );
  }
}

String _$familyDataSourceHash() => r'0d97177eb14c4221c320801e06232b620493b587';

@ProviderFor(familyRepository)
final familyRepositoryProvider = FamilyRepositoryProvider._();

final class FamilyRepositoryProvider
    extends
        $FunctionalProvider<
          FamilyRepository,
          FamilyRepository,
          FamilyRepository
        >
    with $Provider<FamilyRepository> {
  FamilyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyRepositoryHash();

  @$internal
  @override
  $ProviderElement<FamilyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FamilyRepository create(Ref ref) {
    return familyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyRepository>(value),
    );
  }
}

String _$familyRepositoryHash() => r'1377c6016081faa1f75b8b838a47ad5421f307a7';

@ProviderFor(familiesList)
final familiesListProvider = FamiliesListFamily._();

final class FamiliesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Family>>,
          List<Family>,
          FutureOr<List<Family>>
        >
    with $FutureModifier<List<Family>>, $FutureProvider<List<Family>> {
  FamiliesListProvider._({
    required FamiliesListFamily super.from,
    required FamilyFilter super.argument,
  }) : super(
         retry: null,
         name: r'familiesListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$familiesListHash();

  @override
  String toString() {
    return r'familiesListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Family>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Family>> create(Ref ref) {
    final argument = this.argument as FamilyFilter;
    return familiesList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FamiliesListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$familiesListHash() => r'fdeaca05d1c01e3eb294706b0ac28824fefc5fdd';

final class FamiliesListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Family>>, FamilyFilter> {
  FamiliesListFamily._()
    : super(
        retry: null,
        name: r'familiesListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FamiliesListProvider call(FamilyFilter filter) =>
      FamiliesListProvider._(argument: filter, from: this);

  @override
  String toString() => r'familiesListProvider';
}

@ProviderFor(familyDetail)
final familyDetailProvider = FamilyDetailFamily._();

final class FamilyDetailProvider
    extends $FunctionalProvider<AsyncValue<Family>, Family, FutureOr<Family>>
    with $FutureModifier<Family>, $FutureProvider<Family> {
  FamilyDetailProvider._({
    required FamilyDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'familyDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$familyDetailHash();

  @override
  String toString() {
    return r'familyDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Family> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Family> create(Ref ref) {
    final argument = this.argument as String;
    return familyDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FamilyDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$familyDetailHash() => r'8e1d95bf72a2da1b5a9b9011f2fe74118e82a5c2';

final class FamilyDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Family>, String> {
  FamilyDetailFamily._()
    : super(
        retry: null,
        name: r'familyDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FamilyDetailProvider call(String id) =>
      FamilyDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'familyDetailProvider';
}

@ProviderFor(pendingValidationList)
final pendingValidationListProvider = PendingValidationListProvider._();

final class PendingValidationListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Family>>,
          List<Family>,
          FutureOr<List<Family>>
        >
    with $FutureModifier<List<Family>>, $FutureProvider<List<Family>> {
  PendingValidationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingValidationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingValidationListHash();

  @$internal
  @override
  $FutureProviderElement<List<Family>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Family>> create(Ref ref) {
    return pendingValidationList(ref);
  }
}

String _$pendingValidationListHash() =>
    r'02b344f85cdea0be88e0ec70ee7d14643d781c99';

/// Gère l'inscription directe d'une famille (motif `ad_in` du prototype).

@ProviderFor(EnrollmentController)
final enrollmentControllerProvider = EnrollmentControllerProvider._();

/// Gère l'inscription directe d'une famille (motif `ad_in` du prototype).
final class EnrollmentControllerProvider
    extends $AsyncNotifierProvider<EnrollmentController, Family?> {
  /// Gère l'inscription directe d'une famille (motif `ad_in` du prototype).
  EnrollmentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enrollmentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enrollmentControllerHash();

  @$internal
  @override
  EnrollmentController create() => EnrollmentController();
}

String _$enrollmentControllerHash() =>
    r'5b60d27b800cd8040602236df3c5093ab2b262a3';

/// Gère l'inscription directe d'une famille (motif `ad_in` du prototype).

abstract class _$EnrollmentController extends $AsyncNotifier<Family?> {
  FutureOr<Family?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Family?>, Family?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Family?>, Family?>,
              AsyncValue<Family?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Approuve/rejette les comptes en attente de validation (règle métier
/// ajoutée par le client, absente du prototype — voir mémo de validation).

@ProviderFor(ValidationController)
final validationControllerProvider = ValidationControllerProvider._();

/// Approuve/rejette les comptes en attente de validation (règle métier
/// ajoutée par le client, absente du prototype — voir mémo de validation).
final class ValidationControllerProvider
    extends $AsyncNotifierProvider<ValidationController, void> {
  /// Approuve/rejette les comptes en attente de validation (règle métier
  /// ajoutée par le client, absente du prototype — voir mémo de validation).
  ValidationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'validationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$validationControllerHash();

  @$internal
  @override
  ValidationController create() => ValidationController();
}

String _$validationControllerHash() =>
    r'05808d7aa7cb906f972aa5ad7d4ad5f1998d8c26';

/// Approuve/rejette les comptes en attente de validation (règle métier
/// ajoutée par le client, absente du prototype — voir mémo de validation).

abstract class _$ValidationController extends $AsyncNotifier<void> {
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

/// Enregistre un encaissement cash (dossier famille → « Enregistrer un
/// encaissement »).

@ProviderFor(RecordContributionController)
final recordContributionControllerProvider =
    RecordContributionControllerProvider._();

/// Enregistre un encaissement cash (dossier famille → « Enregistrer un
/// encaissement »).
final class RecordContributionControllerProvider
    extends $AsyncNotifierProvider<RecordContributionController, Family?> {
  /// Enregistre un encaissement cash (dossier famille → « Enregistrer un
  /// encaissement »).
  RecordContributionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordContributionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordContributionControllerHash();

  @$internal
  @override
  RecordContributionController create() => RecordContributionController();
}

String _$recordContributionControllerHash() =>
    r'a69ef3500210f252780307d3fa97bf36739dbc53';

/// Enregistre un encaissement cash (dossier famille → « Enregistrer un
/// encaissement »).

abstract class _$RecordContributionController extends $AsyncNotifier<Family?> {
  FutureOr<Family?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Family?>, Family?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Family?>, Family?>,
              AsyncValue<Family?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Ajout/modification/retrait d'un enfant et choix de son kit pour la saison
/// en cours (dossier famille → « Enfants ») — un enfant persiste
/// indépendamment des saisons ; le kit, lui, est choisi séparément, saison
/// par saison.

@ProviderFor(ChildController)
final childControllerProvider = ChildControllerProvider._();

/// Ajout/modification/retrait d'un enfant et choix de son kit pour la saison
/// en cours (dossier famille → « Enfants ») — un enfant persiste
/// indépendamment des saisons ; le kit, lui, est choisi séparément, saison
/// par saison.
final class ChildControllerProvider
    extends $AsyncNotifierProvider<ChildController, Family?> {
  /// Ajout/modification/retrait d'un enfant et choix de son kit pour la saison
  /// en cours (dossier famille → « Enfants ») — un enfant persiste
  /// indépendamment des saisons ; le kit, lui, est choisi séparément, saison
  /// par saison.
  ChildControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'childControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$childControllerHash();

  @$internal
  @override
  ChildController create() => ChildController();
}

String _$childControllerHash() => r'1fee6dd86dffa2a5fcafb52057c8286294805bbd';

/// Ajout/modification/retrait d'un enfant et choix de son kit pour la saison
/// en cours (dossier famille → « Enfants ») — un enfant persiste
/// indépendamment des saisons ; le kit, lui, est choisi séparément, saison
/// par saison.

abstract class _$ChildController extends $AsyncNotifier<Family?> {
  FutureOr<Family?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Family?>, Family?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Family?>, Family?>,
              AsyncValue<Family?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
