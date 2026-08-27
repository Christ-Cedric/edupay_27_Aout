import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_providers.dart';
import 'fcm_service.dart';

/// Provider manuel (pas de codegen `@riverpod`) pour rester cohérent avec
/// [apiClientProvider] sans étape de build supplémentaire.
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref.watch(apiClientProvider));
});
