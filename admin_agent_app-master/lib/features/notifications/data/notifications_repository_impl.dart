import '../domain/models/notification_entry.dart';
import 'notifications_data_source.dart';
import 'notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dataSource);

  final NotificationsDataSource _dataSource;

  @override
  Future<List<NotificationEntry>> getRecent() => _dataSource.fetchRecent();

  @override
  Future<void> markRead(String id) => _dataSource.markRead(id);
}
