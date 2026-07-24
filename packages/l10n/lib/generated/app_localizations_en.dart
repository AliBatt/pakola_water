// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pakola Waters';

  @override
  String get customerAppTitle => 'Pakola Waters — Customer';

  @override
  String get driverAppTitle => 'Pakola Waters — Driver';

  @override
  String get supervisorAppTitle => 'Pakola Waters — Supervisor';

  @override
  String get adminAppTitle => 'Pakola Waters — Admin';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get successGeneric => 'Done successfully.';

  @override
  String get networkError => 'No internet connection.';

  @override
  String get login => 'Sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String roleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get customerHomeTitle => 'Customer Dashboard';

  @override
  String get customerHomeSubtitle =>
      'Place and track your water delivery orders.';

  @override
  String get driverHomeTitle => 'Driver Dashboard';

  @override
  String get driverHomeSubtitle => 'View and complete assigned deliveries.';

  @override
  String get supervisorHomeTitle => 'Supervisor Dashboard';

  @override
  String get supervisorHomeSubtitle =>
      'Manage branch orders, drivers, and inventory.';

  @override
  String get adminHomeTitle => 'Admin Dashboard';

  @override
  String get adminHomeSubtitle =>
      'Manage branches, users, products, and reports.';

  @override
  String get navHome => 'Home';

  @override
  String get navBranches => 'Branches';

  @override
  String get navSupervisors => 'Supervisors';

  @override
  String get navRiders => 'Riders';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navPayments => 'Payments';

  @override
  String get navReports => 'Reports';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navProducts => 'Products';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navRequests => 'Requests';

  @override
  String get navOrders => 'Orders';

  @override
  String get navSettings => 'Settings';

  @override
  String get navQuickAccess => 'Quick access';

  @override
  String get emptyStateDefault => 'Nothing here yet.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'Urdu';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose app display language';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordSubtitle => 'Send a reset link to your email';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently remove your account and profile';

  @override
  String get deleteAccountConfirmTitle => 'Delete account?';

  @override
  String get deleteAccountConfirmBody =>
      'This cannot be undone. Your profile will be removed and you will be signed out.';

  @override
  String get deleteAccountSuccess => 'Account deleted';

  @override
  String get deleteAccountReauthRequired =>
      'Please sign in again, then delete your account.';

  @override
  String get noOngoingOrder => 'No ongoing order';

  @override
  String get noOngoingOrderSubtitle =>
      'Browse products and place an order when you need water.';

  @override
  String get browseProducts => 'Browse products';

  @override
  String get ongoingOrder => 'Ongoing order';

  @override
  String get confirmDelivery => 'Confirm delivery';

  @override
  String get confirmDeliveryTitle => 'Confirm delivery?';

  @override
  String get confirmDeliveryBody =>
      'Confirm that you received this order and it is complete.';

  @override
  String get orderCompleted => 'Order completed. Thank you!';

  @override
  String get search => 'Search';

  @override
  String get order => 'Order';

  @override
  String get newOrder => 'New order';

  @override
  String get noProducts => 'No products';

  @override
  String get noProductsSubtitle => 'Check back soon for available products.';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get noOrdersSubtitle => 'Your order history will appear here.';

  @override
  String get activeOrderBlock =>
      'Finish your current order before placing a new one';

  @override
  String get placeOrder => 'Place order';

  @override
  String get quantity => 'Quantity';

  @override
  String get extraNote => 'Extra note (optional)';

  @override
  String get payment => 'Payment';

  @override
  String get orderPlaced => 'Order placed';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get notificationsEmptySubtitle =>
      'Updates from Pakola Waters will appear here.';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get notificationSent => 'Notification sent';

  @override
  String get sendNotification => 'Send notification';

  @override
  String get notificationTitle => 'Title';

  @override
  String get notificationBody => 'Message';

  @override
  String get selectCustomer => 'Select customer';

  @override
  String fromLabel(String name) {
    return 'From $name';
  }

  @override
  String get unread => 'Unread';

  @override
  String get createAccount => 'Create an account';
}
