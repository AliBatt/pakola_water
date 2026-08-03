import '../../app/driver_app/routing/driver_routes.dart';
import 'app_push_navigator.dart';

class DriverPushRoutes {
  const DriverPushRoutes._();

  static String routeForType(String? type) {
    switch (type) {
      case 'order_assigned':
      case 'order_delivered':
      case 'order_failed':
      case 'order_cancelled':
      case 'order_message':
      case 'order_review':
      case 'admin_message':
        return DriverRoutes.notifications;
      case 'support_request_reply':
      case 'support_request_status':
        return DriverRoutes.requests;
      default:
        return DriverRoutes.home;
    }
  }

  static AppPushNavigator get navigator => AppPushNavigator(
        routeForType: routeForType,
        fallbackRoute: DriverRoutes.notifications,
      );
}
