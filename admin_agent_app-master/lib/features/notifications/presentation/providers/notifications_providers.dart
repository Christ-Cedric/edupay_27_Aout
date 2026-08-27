import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/fake_notifications_data_source.dart';
import '../../data/notifications_data_source.dart';
import '../../data/notifications_repository.dart';
import '../../data/notifications_repository_impl.dart';
import '../../data/rest_notifications_data_source.dart';
import '../../domain/models/notification_entry.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
/// Providers manuels (pas de codegen `@riverpod`) pour rester cohérent avec
/// [usesMockDataProvider]/[apiClientProvider] sans étape de build
/// supplémentaire — Riverpod autorise librement le mélange des deux styles.
final notificationsDataSourceProvider = Provider<NotificationsDataSource>((ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeNotificationsDataSource();
  }
  return RestNotificationsDataSource(ref.watch(apiClientProvider));
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(ref.watch(notificationsDataSourceProvider));
});

final notificationsListProvider =
    FutureProvider.autoDispose<List<NotificationEntry>>((ref) {
  return ref.watch(notificationsRepositoryProvider).getRecent();
});
