import '../../app/customer_app/routing/customer_routes.dart';
import 'app_push_navigator.dart';

/// Customer deep-link routes for push / in-app notification taps.
class CustomerPushRoutes {
  const CustomerPushRoutes._();

  static String routeForType(String? type) {
    switch (type) {
      case 'order_assigned':
      case 'order_out_for_delivery':
      case 'order_rider_arrived':
      case 'order_message':
      case 'staff_message':
      case 'payment_reminder':
      case 'order_failed':
        return CustomerRoutes.home;
      case 'order_review':
      case 'order_delivered':
        return CustomerRoutes.orders;
      case 'support_request_reply':
      case 'support_request_status':
        return CustomerRoutes.requests;
      case 'admin_message':
      default:
        return CustomerRoutes.notifications;
    }
  }

  static AppPushNavigator get navigator => AppPushNavigator(
        routeForType: routeForType,
        fallbackRoute: CustomerRoutes.notifications,
      );
}
