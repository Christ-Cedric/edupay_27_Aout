import '../domain/models/audit_log_entry.dart';
import 'audit_data_source.dart';
import 'audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._dataSource);

  final AuditDataSource _dataSource;

  @override
  Future<List<AuditLogEntry>> getRecent() => _dataSource.fetchRecent();
}
