import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  AppUser? _user;
  List<AppNotification> _notifications = [];
  StreamSubscription<List<AppNotification>>? _sub;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount =>
      _notifications.where((notification) => !notification.read).length;

  void bindUser(AppUser? user) {
    if (user?.id == _user?.id) return;
    _user = user;
    _sub?.cancel();
    _notifications = [];

    if (user == null) {
      notifyListeners();
      return;
    }

    _sub = _notificationRepository.watchForUser(user.id).listen((items) {
      _notifications = items;
      notifyListeners();
    });
  }

  Future<Result<void>> markRead(String id) {
    return _notificationRepository.markRead(id);
  }

  Future<Result<void>> markAllRead() async {
    final userId = _user?.id;
    if (userId == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }
    return _notificationRepository.markAllRead(userId);
  }

  Future<Result<AppNotification>> send({
    required String userId,
    required String title,
    required String body,
    required AppUser sender,
    String type = 'general',
    String? orderId,
  }) {
    return _notificationRepository.createNotification(
      AppNotification(
        id: '',
        userId: userId,
        title: title.trim(),
        body: body.trim(),
        createdById: sender.id,
        createdByRole: sender.role.name,
        createdByName: sender.displayName,
        type: type,
        orderId: orderId,
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
