import '../../app/supervisor_app/routing/supervisor_routes.dart';
import 'app_push_navigator.dart';

class SupervisorPushRoutes {
  const SupervisorPushRoutes._();

  static String routeForType(String? type) {
    switch (type) {
      case 'order_created':
      case 'order_assigned':
      case 'order_delivered':
      case 'order_failed':
      case 'order_cancelled':
      case 'order_message':
      case 'order_review':
      case 'order_scheduled':
      case 'order_scheduled_due':
        return SupervisorRoutes.orders;
      case 'support_request_reply':
      case 'support_request_status':
        return SupervisorRoutes.requests;
      case 'admin_message':
      default:
        return SupervisorRoutes.notifications;
    }
  }

  static AppPushNavigator get navigator => AppPushNavigator(
        routeForType: routeForType,
        fallbackRoute: SupervisorRoutes.notifications,
      );
}
