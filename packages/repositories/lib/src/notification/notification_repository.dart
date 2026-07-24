import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchForUser(String userId);
  Future<Result<AppNotification>> createNotification(AppNotification notification);
  Future<Result<void>> markRead(String notificationId);
  Future<Result<void>> markAllRead(String userId);
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._notificationService);

  final NotificationService _notificationService;

  @override
  Stream<List<AppNotification>> watchForUser(String userId) {
    return _notificationService.watchForUser(userId);
  }

  @override
  Future<Result<AppNotification>> createNotification(
    AppNotification notification,
  ) {
    return _notificationService.createNotification(notification);
  }

  @override
  Future<Result<void>> markRead(String notificationId) {
    return _notificationService.markRead(notificationId);
  }

  @override
  Future<Result<void>> markAllRead(String userId) {
    return _notificationService.markAllRead(userId);
  }
}
