// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicles_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vehicleDataSource)
final vehicleDataSourceProvider = VehicleDataSourceProvider._();

final class VehicleDataSourceProvider
    extends
        $FunctionalProvider<
          VehicleDataSource,
          VehicleDataSource,
          VehicleDataSource
        >
    with $Provider<VehicleDataSource> {
  VehicleDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleDataSourceHash();

  @$internal
  @override
  $ProviderElement<VehicleDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleDataSource create(Ref ref) {
    return vehicleDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleDataSource>(value),
    );
  }
}

String _$vehicleDataSourceHash() => r'c837dcc186b883b726f6c206b6da52c40ff7e5e8';

@ProviderFor(vehicleRepository)
final vehicleRepositoryProvider = VehicleRepositoryProvider._();

final class VehicleRepositoryProvider
    extends
        $FunctionalProvider<
          VehicleRepository,
          VehicleRepository,
          VehicleRepository
        >
    with $Provider<VehicleRepository> {
  VehicleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleRepositoryHash();

  @$internal
  @override
  $ProviderElement<VehicleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleRepository create(Ref ref) {
    return vehicleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleRepository>(value),
    );
  }
}

String _$vehicleRepositoryHash() => r'32019fede7f8dc6b30e2d634bb6376382c464b1f';

@ProviderFor(vehiclesList)
final vehiclesListProvider = VehiclesListProvider._();

final class VehiclesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransportVehicle>>,
          List<TransportVehicle>,
          FutureOr<List<TransportVehicle>>
        >
    with
        $FutureModifier<List<TransportVehicle>>,
        $FutureProvider<List<TransportVehicle>> {
  VehiclesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehiclesListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehiclesListHash();

  @$internal
  @override
  $FutureProviderElement<List<TransportVehicle>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TransportVehicle>> create(Ref ref) {
    return vehiclesList(ref);
  }
}

String _$vehiclesListHash() => r'818847f66973115f45c2937d40b01d1731d2717c';

@ProviderFor(vehicleDetail)
final vehicleDetailProvider = VehicleDetailFamily._();

final class VehicleDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<TransportVehicle>,
          TransportVehicle,
          FutureOr<TransportVehicle>
        >
    with $FutureModifier<TransportVehicle>, $FutureProvider<TransportVehicle> {
  VehicleDetailProvider._({
    required VehicleDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vehicleDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vehicleDetailHash();

  @override
  String toString() {
    return r'vehicleDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TransportVehicle> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TransportVehicle> create(Ref ref) {
    final argument = this.argument as String;
    return vehicleDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vehicleDetailHash() => r'4d965475fd1848898946f0ad1c5152b98b7ddeea';

final class VehicleDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TransportVehicle>, String> {
  VehicleDetailFamily._()
    : super(
        retry: null,
        name: r'vehicleDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VehicleDetailProvider call(String id) =>
      VehicleDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'vehicleDetailProvider';
}

@ProviderFor(VehicleCreateController)
final vehicleCreateControllerProvider = VehicleCreateControllerProvider._();

final class VehicleCreateControllerProvider
    extends $AsyncNotifierProvider<VehicleCreateController, TransportVehicle?> {
  VehicleCreateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleCreateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleCreateControllerHash();

  @$internal
  @override
  VehicleCreateController create() => VehicleCreateController();
}

String _$vehicleCreateControllerHash() =>
    r'5b18c869f97f4e183bf68475e855475e293e4127';

abstract class _$VehicleCreateController
    extends $AsyncNotifier<TransportVehicle?> {
  FutureOr<TransportVehicle?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransportVehicle?>, TransportVehicle?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransportVehicle?>, TransportVehicle?>,
              AsyncValue<TransportVehicle?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(VehicleEditController)
final vehicleEditControllerProvider = VehicleEditControllerProvider._();

final class VehicleEditControllerProvider
    extends $AsyncNotifierProvider<VehicleEditController, TransportVehicle?> {
  VehicleEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleEditControllerHash();

  @$internal
  @override
  VehicleEditController create() => VehicleEditController();
}

String _$vehicleEditControllerHash() =>
    r'41f52b551caa830f425b7c7d4c8791a0178ac8f4';

abstract class _$VehicleEditController
    extends $AsyncNotifier<TransportVehicle?> {
  FutureOr<TransportVehicle?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransportVehicle?>, TransportVehicle?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransportVehicle?>, TransportVehicle?>,
              AsyncValue<TransportVehicle?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(VehicleDeleteController)
final vehicleDeleteControllerProvider = VehicleDeleteControllerProvider._();

final class VehicleDeleteControllerProvider
    extends $AsyncNotifierProvider<VehicleDeleteController, void> {
  VehicleDeleteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleDeleteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleDeleteControllerHash();

  @$internal
  @override
  VehicleDeleteController create() => VehicleDeleteController();
}

String _$vehicleDeleteControllerHash() =>
    r'11a6364fb667869927089f27794c596c8fe03261';

abstract class _$VehicleDeleteController extends $AsyncNotifier<void> {
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
