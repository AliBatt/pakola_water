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

  @override
  String get adminPanelSubtitle => 'Operations console';

  @override
  String get adminConsoleLabel => 'Admin console';

  @override
  String get adminRoleLabel => 'Administrator';

  @override
  String get myRequests => 'My requests';

  @override
  String get myRequestsSubtitle => 'Send requests to admin and track replies';

  @override
  String get newRequest => 'New request';

  @override
  String get newRequestSubtitle =>
      'Send a request to admin. You can attach one optional image.';

  @override
  String get requestTitle => 'Title';

  @override
  String get requestDescription => 'Description';

  @override
  String get addImageOptional => 'Add image (optional)';

  @override
  String get removeImage => 'Remove image';

  @override
  String get sendRequest => 'Send request';

  @override
  String get requestSentToAdmin => 'Request sent to admin';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get searchYourRequests => 'Search your requests…';

  @override
  String get searchRequestsAdmin => 'Search by name, title, role…';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get noRequests => 'No requests';

  @override
  String get noRequestsSubtitle => 'Create a request to ask admin for help.';

  @override
  String get noRequestsAdminSubtitle =>
      'Requests from customers, supervisors, and riders will appear here.';

  @override
  String get adminActions => 'Admin actions';

  @override
  String get markInProgress => 'Mark in progress';

  @override
  String get completeAction => 'Complete';

  @override
  String get rejectAction => 'Reject';

  @override
  String get conversation => 'Conversation';

  @override
  String get noRepliesYet => 'No replies yet. Start the conversation below.';

  @override
  String get writeAReply => 'Write a reply';

  @override
  String markedAsStatus(String status) {
    return 'Marked as $status';
  }

  @override
  String requestNoLongerAcceptsReplies(String status) {
    return 'This request is $status and no longer accepts replies.';
  }

  @override
  String get supportStatusOpen => 'Open';

  @override
  String get supportStatusInProgress => 'In progress';

  @override
  String get supportStatusCompleted => 'Completed';

  @override
  String get supportStatusRejected => 'Rejected';

  @override
  String get supportStatusClosed => 'Closed';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String pushEnabledWithToken(String token) {
    return 'Enabled · token $token';
  }

  @override
  String get pushDisabledHint => 'Disabled — tap to allow notifications';

  @override
  String get enable => 'Enable';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get couldNotEnableNotifications => 'Could not enable notifications';

  @override
  String get orderType => 'Order type';

  @override
  String get orderTypeInstant => 'Instant';

  @override
  String get orderTypeScheduled => 'Scheduled';

  @override
  String get instantOrderOngoingHint =>
      'You already have an ongoing instant order';

  @override
  String get instantOrderStartHint => 'Start delivery as soon as possible';

  @override
  String get scheduledOrderExistingHint => 'You already have a scheduled order';

  @override
  String get scheduledOrderChooseHint => 'Choose a later date and time';

  @override
  String get selectDateAndTime => 'Select date & time';

  @override
  String scheduledForLabel(String when) {
    return 'Scheduled for $when';
  }

  @override
  String get deliveryLocation => 'Delivery location';

  @override
  String get mySavedAddress => 'My saved address';

  @override
  String get noAddressOnProfile => 'No address on profile';

  @override
  String get noAddressOnYourProfile => 'No address on your profile';

  @override
  String get differentLocationForOrder => 'Different location for this order';

  @override
  String get searchAndPinCustom => 'Search and pin a custom delivery point';

  @override
  String get deliveringTo => 'Delivering to';

  @override
  String selectedCustomLocation(String address) {
    return 'Selected: $address (custom location)';
  }

  @override
  String get scheduledTimeMustBeFuture =>
      'Scheduled time must be in the future';

  @override
  String get deliveryAddressRequired => 'Delivery address is required';

  @override
  String get deliveryLocationRequired => 'Delivery location is required';

  @override
  String get selectABranch => 'Select a branch';

  @override
  String get selectScheduleDateTime => 'Select a schedule date and time';

  @override
  String get alreadyHaveInstantOrder =>
      'You already have an ongoing instant order';

  @override
  String get alreadyHaveScheduledOrder => 'You already have a scheduled order';

  @override
  String orderProductTitle(String name) {
    return 'Order $name';
  }

  @override
  String get upcomingScheduled => 'Upcoming scheduled';

  @override
  String get searchAddress => 'Search address';

  @override
  String get searchAddressHint => 'e.g. Gulshan-e-Iqbal, Karachi';

  @override
  String get searchAddressHelp =>
      'Search an address, then fine-tune the pin on the map';

  @override
  String get clear => 'Clear';

  @override
  String get branch => 'Branch';

  @override
  String get noActiveBranches => 'No active branches available';

  @override
  String get recommended => 'Recommended';

  @override
  String kmAway(String km) {
    return '$km km away';
  }

  @override
  String get tabRequested => 'Requested';

  @override
  String get tabScheduled => 'Scheduled';

  @override
  String tabOthersWithCount(int count) {
    return 'Others ($count)';
  }

  @override
  String get noRequestedOrders => 'No requested orders';

  @override
  String get noRequestedOrdersSubtitle =>
      'Instant and due scheduled orders appear here.';

  @override
  String get noScheduledOrders => 'No scheduled orders';

  @override
  String get noScheduledOrdersSubtitle =>
      'Orders scheduled for later appear here until their time arrives.';

  @override
  String get waiting => 'Waiting';

  @override
  String qtyWithValue(int quantity) {
    return 'Qty $quantity';
  }

  @override
  String get assignOrder => 'Assign order';

  @override
  String get scheduledOrderTitle => 'Scheduled order';

  @override
  String customerWithName(String name) {
    return 'Customer: $name';
  }

  @override
  String noteWithText(String note) {
    return 'Note: $note';
  }

  @override
  String get scheduledAssignLockedHint =>
      'This order is scheduled. You can review details now, but assignment unlocks when the scheduled time arrives.';

  @override
  String get selectRider => 'Select rider';

  @override
  String get myBranch => 'My branch';

  @override
  String get otherBranches => 'Other branches';

  @override
  String get noRidersInGroup => 'No riders in this group';

  @override
  String get estimatedArrival => 'Estimated arrival';

  @override
  String get assignAndNotifyRider => 'Assign & notify rider';

  @override
  String get newlyAssigned => 'Newly Assigned';

  @override
  String get noAssignedOrders => 'No assigned orders';

  @override
  String get noAssignedOrdersSubtitle =>
      'New deliveries from your supervisor will appear here.';

  @override
  String get startDelivery => 'Start delivery';

  @override
  String get markArrived => 'Mark arrived';

  @override
  String viewAllActive(int count) {
    return 'View all $count active';
  }

  @override
  String get noOrdersMatchFilters => 'No orders match filters';

  @override
  String get tryChangingSearchOrFilters => 'Try changing search or filters.';

  @override
  String get status => 'Status';

  @override
  String get customer => 'Customer';

  @override
  String get qtyTotal => 'Qty / Total';

  @override
  String get placed => 'Placed';

  @override
  String get supervisorEta => 'Supervisor ETA';

  @override
  String get supervisor => 'Supervisor';

  @override
  String get note => 'Note';

  @override
  String get back => 'Back';

  @override
  String get statToday => 'Today';

  @override
  String get statNewAssigned => 'New assigned';

  @override
  String get statNewRequests => 'New requests';

  @override
  String get statInProgress => 'In progress';

  @override
  String get statCompleted => 'Completed';

  @override
  String get statFailed => 'Failed';

  @override
  String get statPending => 'Pending';

  @override
  String get statTotalRange => 'Total (range)';

  @override
  String get statRevenue => 'Revenue';

  @override
  String vehicleWithPlate(String plate) {
    return 'Vehicle: $plate';
  }

  @override
  String branchWithId(String id) {
    return 'Branch: $id';
  }

  @override
  String get created => 'Created';

  @override
  String get timeSpent => 'Time spent';

  @override
  String get supervisorNotified => 'Supervisor notified';

  @override
  String get rider => 'Rider';

  @override
  String get eta => 'ETA';

  @override
  String get sendMessageToSupervisor => 'Send message to supervisor';

  @override
  String get searchCustomerOrPhone => 'Search customer or phone';

  @override
  String get searchCustomerOrRider => 'Search customer or rider';

  @override
  String get orderDetails => 'Order details';

  @override
  String get waitingCustomerConfirm =>
      'Waiting for customer to confirm delivery.';

  @override
  String get view => 'View';

  @override
  String newOrdersWaiting(int count) {
    return '$count new order(s) waiting';
  }

  @override
  String get openOrdersToAssignHint =>
      'Open Orders → Requested to assign a rider';
}
