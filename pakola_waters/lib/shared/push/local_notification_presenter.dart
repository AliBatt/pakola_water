import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef LocalNotificationTapCallback = void Function(String? payload);

/// Foreground local notification presenter for FCM messages.
class LocalNotificationPresenter {
  LocalNotificationPresenter();

  static const _channelId = 'pakola_waters_default';
  static const _channelName = 'Pakola Waters';
  static const _channelDescription = 'Order and admin notifications';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  LocalNotificationTapCallback? onTap;
  bool _initialized = false;

  Future<void> initialize({LocalNotificationTapCallback? onTap}) async {
    if (_initialized) {
      this.onTap = onTap ?? this.onTap;
      return;
    }
    this.onTap = onTap;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        this.onTap?.call(response.payload);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('[Push] local-notifications Android permission: $granted');
      return granted ?? false;
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[Push] local-notifications iOS permission: $granted');
      return granted ?? false;
    }

    return true;
  }

  Future<void> show({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: data == null ? null : jsonEncode(data),
    );
  }
}
