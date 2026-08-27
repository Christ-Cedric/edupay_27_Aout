import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/audit_data_source.dart';
import '../../data/audit_repository.dart';
import '../../data/audit_repository_impl.dart';
import '../../data/fake_audit_data_source.dart';
import '../../data/rest_audit_data_source.dart';
import '../../domain/models/audit_log_entry.dart';

part 'audit_providers.g.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@Riverpod(keepAlive: true)
AuditDataSource auditDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeAuditDataSource();
  }
  return RestAuditDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
AuditRepository auditRepository(Ref ref) {
  return AuditRepositoryImpl(ref.watch(auditDataSourceProvider));
}

@riverpod
Future<List<AuditLogEntry>> auditLogsList(Ref ref) {
  return ref.watch(auditRepositoryProvider).getRecent();
}
