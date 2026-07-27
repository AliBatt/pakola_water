import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Thin FCM wrapper used by mobile apps (customer first).
class FirebaseMessagingService {
  FirebaseMessagingService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<NotificationSettings> getNotificationSettings() {
    return _messaging.getNotificationSettings();
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
  }

  Future<String?> getToken({int retries = 3}) async {
    if (kIsWeb) return null;

    for (var attempt = 1; attempt <= retries; attempt++) {
      try {
        if (Platform.isIOS) {
          // Wait briefly for APNs token on cold start.
          for (var i = 0; i < 5; i++) {
            final apns = await _messaging.getAPNSToken();
            if (apns != null) break;
            await Future<void>.delayed(const Duration(milliseconds: 400));
          }
        }

        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          debugPrint('[FCM] token acquired (attempt $attempt): '
              '${token.substring(0, 12)}…');
          return token;
        }
        debugPrint('[FCM] getToken returned empty (attempt $attempt)');
      } catch (error, stack) {
        debugPrint('[FCM] getToken failed (attempt $attempt): $error');
        debugPrint('$stack');
      }
      await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
    }
    return null;
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Future<void> setForegroundPresentationOptions() {
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler must be a top-level function.
  // Firebase is initialized by the platform before this runs on Android.
}
