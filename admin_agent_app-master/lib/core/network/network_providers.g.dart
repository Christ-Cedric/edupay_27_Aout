// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Environnement courant — exposé en provider pour que chaque repository
/// puisse décider mock vs REST (composition root distribué).

@ProviderFor(appEnvironment)
final appEnvironmentProvider = AppEnvironmentProvider._();

/// Environnement courant — exposé en provider pour que chaque repository
/// puisse décider mock vs REST (composition root distribué).

final class AppEnvironmentProvider
    extends $FunctionalProvider<AppEnvironment, AppEnvironment, AppEnvironment>
    with $Provider<AppEnvironment> {
  /// Environnement courant — exposé en provider pour que chaque repository
  /// puisse décider mock vs REST (composition root distribué).
  AppEnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appEnvironmentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appEnvironmentHash();

  @$internal
  @override
  $ProviderElement<AppEnvironment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppEnvironment create(Ref ref) {
    return appEnvironment(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppEnvironment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppEnvironment>(value),
    );
  }
}

String _$appEnvironmentHash() => r'd6a7469841eac894638eafda333509c52e413d14';

/// `true` tant qu'on tourne sur les données [FakeDataSource].

@ProviderFor(usesMockData)
final usesMockDataProvider = UsesMockDataProvider._();

/// `true` tant qu'on tourne sur les données [FakeDataSource].

final class UsesMockDataProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// `true` tant qu'on tourne sur les données [FakeDataSource].
  UsesMockDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usesMockDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usesMockDataHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return usesMockData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$usesMockDataHash() => r'1f66140346bc33fa7281692a3b6aed15f0adcae7';

@ProviderFor(tokenStore)
final tokenStoreProvider = TokenStoreProvider._();

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'46d54dc5f84f334b8d16ea6415faf7bcda4a02d2';

/// Transport HTTP partagé. En mode mock il n'est jamais construit (aucun
/// `RestDataSource` ne le lit), donc l'app démarre sans backend.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// Transport HTTP partagé. En mode mock il n'est jamais construit (aucun
/// `RestDataSource` ne le lit), donc l'app démarre sans backend.

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  /// Transport HTTP partagé. En mode mock il n'est jamais construit (aucun
  /// `RestDataSource` ne le lit), donc l'app démarre sans backend.
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'ed179aa5d19e3773c153c959a6a8e70f3359a692';
