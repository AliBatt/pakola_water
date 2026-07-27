import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Role-agnostic push deep-link helper.
class AppPushNavigator {
  const AppPushNavigator({
    required this.routeForType,
    required this.fallbackRoute,
  });

  final String Function(String? type) routeForType;
  final String fallbackRoute;

  void openFromData(GoRouter router, Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final explicitRoute = data['route']?.toString();
    final route = (explicitRoute != null && explicitRoute.isNotEmpty)
        ? explicitRoute
        : routeForType(type);
    router.go(route);
  }

  void openFromRemoteMessage(GoRouter router, RemoteMessage message) {
    openFromData(router, Map<String, dynamic>.from(message.data));
  }

  void openFromPayload(GoRouter router, String? payload) {
    if (payload == null || payload.isEmpty) {
      router.go(fallbackRoute);
      return;
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        openFromData(router, decoded);
        return;
      }
    } catch (_) {}
    router.go(fallbackRoute);
  }

  static Map<String, dynamic> dataFromMessage(RemoteMessage message) {
    return {
      ...message.data,
      if (message.notification?.title != null)
        'title': message.notification!.title,
      if (message.notification?.body != null)
        'body': message.notification!.body,
    };
  }

  static bool get supportsPush => !kIsWeb;
}
