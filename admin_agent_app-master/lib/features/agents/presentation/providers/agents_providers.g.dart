// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agents_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root de la feature : choisit la source de données selon
/// l'environnement. Mock par défaut (aucun backend requis).

@ProviderFor(agentDataSource)
final agentDataSourceProvider = AgentDataSourceProvider._();

/// Composition root de la feature : choisit la source de données selon
/// l'environnement. Mock par défaut (aucun backend requis).

final class AgentDataSourceProvider
    extends
        $FunctionalProvider<AgentDataSource, AgentDataSource, AgentDataSource>
    with $Provider<AgentDataSource> {
  /// Composition root de la feature : choisit la source de données selon
  /// l'environnement. Mock par défaut (aucun backend requis).
  AgentDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentDataSourceHash();

  @$internal
  @override
  $ProviderElement<AgentDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AgentDataSource create(Ref ref) {
    return agentDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgentDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgentDataSource>(value),
    );
  }
}

String _$agentDataSourceHash() => r'b59b04ad7ab6e2b33915a2767b0d95586566d0da';

@ProviderFor(agentRepository)
final agentRepositoryProvider = AgentRepositoryProvider._();

final class AgentRepositoryProvider
    extends
        $FunctionalProvider<AgentRepository, AgentRepository, AgentRepository>
    with $Provider<AgentRepository> {
  AgentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentRepositoryHash();

  @$internal
  @override
  $ProviderElement<AgentRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AgentRepository create(Ref ref) {
    return agentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgentRepository>(value),
    );
  }
}

String _$agentRepositoryHash() => r'b554598531f4c6d85aca59e49399995d0e768644';

@ProviderFor(agentsList)
final agentsListProvider = AgentsListProvider._();

final class AgentsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Agent>>,
          List<Agent>,
          FutureOr<List<Agent>>
        >
    with $FutureModifier<List<Agent>>, $FutureProvider<List<Agent>> {
  AgentsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentsListHash();

  @$internal
  @override
  $FutureProviderElement<List<Agent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Agent>> create(Ref ref) {
    return agentsList(ref);
  }
}

String _$agentsListHash() => r'7c100e844910d3ff299fc55550fe0226d987867c';

@ProviderFor(agentDetail)
final agentDetailProvider = AgentDetailFamily._();

final class AgentDetailProvider
    extends $FunctionalProvider<AsyncValue<Agent>, Agent, FutureOr<Agent>>
    with $FutureModifier<Agent>, $FutureProvider<Agent> {
  AgentDetailProvider._({
    required AgentDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'agentDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentDetailHash();

  @override
  String toString() {
    return r'agentDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Agent> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Agent> create(Ref ref) {
    final argument = this.argument as String;
    return agentDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentDetailHash() => r'677ce3540cb8ca3620b246e873d792ca3de00c2c';

final class AgentDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Agent>, String> {
  AgentDetailFamily._()
    : super(
        retry: null,
        name: r'agentDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AgentDetailProvider call(String id) =>
      AgentDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'agentDetailProvider';
}

@ProviderFor(NewAgentController)
final newAgentControllerProvider = NewAgentControllerProvider._();

final class NewAgentControllerProvider
    extends $AsyncNotifierProvider<NewAgentController, Agent?> {
  NewAgentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newAgentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newAgentControllerHash();

  @$internal
  @override
  NewAgentController create() => NewAgentController();
}

String _$newAgentControllerHash() =>
    r'8bf1f4c838fc9a54a5694406778464cac8c10b92';

abstract class _$NewAgentController extends $AsyncNotifier<Agent?> {
  FutureOr<Agent?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Agent?>, Agent?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Agent?>, Agent?>,
              AsyncValue<Agent?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Suspend/réactive un agent (dossier détail agent).

@ProviderFor(AgentStatusController)
final agentStatusControllerProvider = AgentStatusControllerProvider._();

/// Suspend/réactive un agent (dossier détail agent).
final class AgentStatusControllerProvider
    extends $AsyncNotifierProvider<AgentStatusController, void> {
  /// Suspend/réactive un agent (dossier détail agent).
  AgentStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentStatusControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentStatusControllerHash();

  @$internal
  @override
  AgentStatusController create() => AgentStatusController();
}

String _$agentStatusControllerHash() =>
    r'53228eef662a61dd49bc3adfe25ced0276921fc2';

/// Suspend/réactive un agent (dossier détail agent).

abstract class _$AgentStatusController extends $AsyncNotifier<void> {
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
