// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

@ProviderFor(auditDataSource)
final auditDataSourceProvider = AuditDataSourceProvider._();

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.

final class AuditDataSourceProvider
    extends
        $FunctionalProvider<AuditDataSource, AuditDataSource, AuditDataSource>
    with $Provider<AuditDataSource> {
  /// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
  AuditDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuditDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuditDataSource create(Ref ref) {
    return auditDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditDataSource>(value),
    );
  }
}

String _$auditDataSourceHash() => r'248a679ff0969a373f496c32b56fd766efa056b1';

@ProviderFor(auditRepository)
final auditRepositoryProvider = AuditRepositoryProvider._();

final class AuditRepositoryProvider
    extends
        $FunctionalProvider<AuditRepository, AuditRepository, AuditRepository>
    with $Provider<AuditRepository> {
  AuditRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuditRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuditRepository create(Ref ref) {
    return auditRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditRepository>(value),
    );
  }
}

String _$auditRepositoryHash() => r'5ad1cb8252a3f6351f4132cc3e0b4190cd7a116d';

@ProviderFor(auditLogsList)
final auditLogsListProvider = AuditLogsListProvider._();

final class AuditLogsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuditLogEntry>>,
          List<AuditLogEntry>,
          FutureOr<List<AuditLogEntry>>
        >
    with
        $FutureModifier<List<AuditLogEntry>>,
        $FutureProvider<List<AuditLogEntry>> {
  AuditLogsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditLogsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditLogsListHash();

  @$internal
  @override
  $FutureProviderElement<List<AuditLogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AuditLogEntry>> create(Ref ref) {
    return auditLogsList(ref);
  }
}

String _$auditLogsListHash() => r'0d9f77192ba5f24a0d769b53197fd7ed71e3e274';
