import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import 'app_push_navigator.dart';
import 'customer_push_routes.dart';

/// Backwards-compatible facade for older customer call sites.
class CustomerPushNavigator {
  const CustomerPushNavigator._();

  static final AppPushNavigator _nav = CustomerPushRoutes.navigator;

  static String routeForType(String? type) =>
      CustomerPushRoutes.routeForType(type);

  static void openFromData(GoRouter router, Map<String, dynamic> data) {
    _nav.openFromData(router, data);
  }

  static void openFromRemoteMessage(GoRouter router, RemoteMessage message) {
    _nav.openFromRemoteMessage(router, message);
  }

  static void openFromPayload(GoRouter router, String? payload) {
    _nav.openFromPayload(router, payload);
  }

  static Map<String, dynamic> dataFromMessage(RemoteMessage message) {
    return AppPushNavigator.dataFromMessage(message);
  }

  static bool get supportsPush => AppPushNavigator.supportsPush;
}
