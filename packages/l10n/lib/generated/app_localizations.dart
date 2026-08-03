import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// Root product name
  ///
  /// In en, this message translates to:
  /// **'Pakola Waters'**
  String get appTitle;

  /// No description provided for @customerAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Pakola Waters — Customer'**
  String get customerAppTitle;

  /// No description provided for @driverAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Pakola Waters — Driver'**
  String get driverAppTitle;

  /// No description provided for @supervisorAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Pakola Waters — Supervisor'**
  String get supervisorAppTitle;

  /// No description provided for @adminAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Pakola Waters — Admin'**
  String get adminAppTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @successGeneric.
  ///
  /// In en, this message translates to:
  /// **'Done successfully.'**
  String get successGeneric;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get networkError;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Greeting with display name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(String name);

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleLabel(String role);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @customerHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Dashboard'**
  String get customerHomeTitle;

  /// No description provided for @customerHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place and track your water delivery orders.'**
  String get customerHomeSubtitle;

  /// No description provided for @driverHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Dashboard'**
  String get driverHomeTitle;

  /// No description provided for @driverHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and complete assigned deliveries.'**
  String get driverHomeSubtitle;

  /// No description provided for @supervisorHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Supervisor Dashboard'**
  String get supervisorHomeTitle;

  /// No description provided for @supervisorHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage branch orders, drivers, and inventory.'**
  String get supervisorHomeSubtitle;

  /// No description provided for @adminHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminHomeTitle;

  /// No description provided for @adminHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage branches, users, products, and reports.'**
  String get adminHomeSubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get navBranches;

  /// No description provided for @navSupervisors.
  ///
  /// In en, this message translates to:
  /// **'Supervisors'**
  String get navSupervisors;

  /// No description provided for @navRiders.
  ///
  /// In en, this message translates to:
  /// **'Riders'**
  String get navRiders;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventory;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get navQuickAccess;

  /// No description provided for @emptyStateDefault.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get emptyStateDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app display language'**
  String get languageSubtitle;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a reset link to your email'**
  String get resetPasswordSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and profile'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Your profile will be removed and you will be signed out.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountReauthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again, then delete your account.'**
  String get deleteAccountReauthRequired;

  /// No description provided for @noOngoingOrder.
  ///
  /// In en, this message translates to:
  /// **'No ongoing order'**
  String get noOngoingOrder;

  /// No description provided for @noOngoingOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse products and place an order when you need water.'**
  String get noOngoingOrderSubtitle;

  /// No description provided for @browseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get browseProducts;

  /// No description provided for @ongoingOrder.
  ///
  /// In en, this message translates to:
  /// **'Ongoing order'**
  String get ongoingOrder;

  /// No description provided for @confirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery'**
  String get confirmDelivery;

  /// No description provided for @confirmDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery?'**
  String get confirmDeliveryTitle;

  /// No description provided for @confirmDeliveryBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you received this order and it is complete.'**
  String get confirmDeliveryBody;

  /// No description provided for @orderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order completed. Thank you!'**
  String get orderCompleted;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get newOrder;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @noProductsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for available products.'**
  String get noProductsSubtitle;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @noOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order history will appear here.'**
  String get noOrdersSubtitle;

  /// No description provided for @activeOrderBlock.
  ///
  /// In en, this message translates to:
  /// **'Finish your current order before placing a new one'**
  String get activeOrderBlock;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @extraNote.
  ///
  /// In en, this message translates to:
  /// **'Extra note (optional)'**
  String get extraNote;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderPlaced;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates from Pakola Waters will appear here.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @notificationSent.
  ///
  /// In en, this message translates to:
  /// **'Notification sent'**
  String get notificationSent;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send notification'**
  String get sendNotification;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get notificationBody;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select customer'**
  String get selectCustomer;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String fromLabel(String name);

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @adminPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Operations console'**
  String get adminPanelSubtitle;

  /// No description provided for @adminConsoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin console'**
  String get adminConsoleLabel;

  /// No description provided for @adminRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminRoleLabel;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequests;

  /// No description provided for @myRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send requests to admin and track replies'**
  String get myRequestsSubtitle;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get newRequest;

  /// No description provided for @newRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a request to admin. You can attach one optional image.'**
  String get newRequestSubtitle;

  /// No description provided for @requestTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get requestTitle;

  /// No description provided for @requestDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get requestDescription;

  /// No description provided for @addImageOptional.
  ///
  /// In en, this message translates to:
  /// **'Add image (optional)'**
  String get addImageOptional;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @requestSentToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Request sent to admin'**
  String get requestSentToAdmin;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @searchYourRequests.
  ///
  /// In en, this message translates to:
  /// **'Search your requests…'**
  String get searchYourRequests;

  /// No description provided for @searchRequestsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Search by name, title, role…'**
  String get searchRequestsAdmin;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests'**
  String get noRequests;

  /// No description provided for @noRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a request to ask admin for help.'**
  String get noRequestsSubtitle;

  /// No description provided for @noRequestsAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requests from customers, supervisors, and riders will appear here.'**
  String get noRequestsAdminSubtitle;

  /// No description provided for @adminActions.
  ///
  /// In en, this message translates to:
  /// **'Admin actions'**
  String get adminActions;

  /// No description provided for @markInProgress.
  ///
  /// In en, this message translates to:
  /// **'Mark in progress'**
  String get markInProgress;

  /// No description provided for @completeAction.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeAction;

  /// No description provided for @rejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAction;

  /// No description provided for @conversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get conversation;

  /// No description provided for @noRepliesYet.
  ///
  /// In en, this message translates to:
  /// **'No replies yet. Start the conversation below.'**
  String get noRepliesYet;

  /// No description provided for @writeAReply.
  ///
  /// In en, this message translates to:
  /// **'Write a reply'**
  String get writeAReply;

  /// No description provided for @markedAsStatus.
  ///
  /// In en, this message translates to:
  /// **'Marked as {status}'**
  String markedAsStatus(String status);

  /// No description provided for @requestNoLongerAcceptsReplies.
  ///
  /// In en, this message translates to:
  /// **'This request is {status} and no longer accepts replies.'**
  String requestNoLongerAcceptsReplies(String status);

  /// No description provided for @supportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get supportStatusInProgress;

  /// No description provided for @supportStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get supportStatusCompleted;

  /// No description provided for @supportStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get supportStatusRejected;

  /// No description provided for @supportStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supportStatusClosed;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @pushEnabledWithToken.
  ///
  /// In en, this message translates to:
  /// **'Enabled · token {token}'**
  String pushEnabledWithToken(String token);

  /// No description provided for @pushDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Disabled — tap to allow notifications'**
  String get pushDisabledHint;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @couldNotEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not enable notifications'**
  String get couldNotEnableNotifications;

  /// No description provided for @orderType.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get orderType;

  /// No description provided for @orderTypeInstant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get orderTypeInstant;

  /// No description provided for @orderTypeScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get orderTypeScheduled;

  /// No description provided for @instantOrderOngoingHint.
  ///
  /// In en, this message translates to:
  /// **'You already have an ongoing instant order'**
  String get instantOrderOngoingHint;

  /// No description provided for @instantOrderStartHint.
  ///
  /// In en, this message translates to:
  /// **'Start delivery as soon as possible'**
  String get instantOrderStartHint;

  /// No description provided for @scheduledOrderExistingHint.
  ///
  /// In en, this message translates to:
  /// **'You already have a scheduled order'**
  String get scheduledOrderExistingHint;

  /// No description provided for @scheduledOrderChooseHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a later date and time'**
  String get scheduledOrderChooseHint;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Select date & time'**
  String get selectDateAndTime;

  /// No description provided for @scheduledForLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {when}'**
  String scheduledForLabel(String when);

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery location'**
  String get deliveryLocation;

  /// No description provided for @mySavedAddress.
  ///
  /// In en, this message translates to:
  /// **'My saved address'**
  String get mySavedAddress;

  /// No description provided for @noAddressOnProfile.
  ///
  /// In en, this message translates to:
  /// **'No address on profile'**
  String get noAddressOnProfile;

  /// No description provided for @noAddressOnYourProfile.
  ///
  /// In en, this message translates to:
  /// **'No address on your profile'**
  String get noAddressOnYourProfile;

  /// No description provided for @differentLocationForOrder.
  ///
  /// In en, this message translates to:
  /// **'Different location for this order'**
  String get differentLocationForOrder;

  /// No description provided for @searchAndPinCustom.
  ///
  /// In en, this message translates to:
  /// **'Search and pin a custom delivery point'**
  String get searchAndPinCustom;

  /// No description provided for @deliveringTo.
  ///
  /// In en, this message translates to:
  /// **'Delivering to'**
  String get deliveringTo;

  /// No description provided for @selectedCustomLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected: {address} (custom location)'**
  String selectedCustomLocation(String address);

  /// No description provided for @scheduledTimeMustBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Scheduled time must be in the future'**
  String get scheduledTimeMustBeFuture;

  /// No description provided for @deliveryAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery address is required'**
  String get deliveryAddressRequired;

  /// No description provided for @deliveryLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery location is required'**
  String get deliveryLocationRequired;

  /// No description provided for @selectABranch.
  ///
  /// In en, this message translates to:
  /// **'Select a branch'**
  String get selectABranch;

  /// No description provided for @selectScheduleDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select a schedule date and time'**
  String get selectScheduleDateTime;

  /// No description provided for @alreadyHaveInstantOrder.
  ///
  /// In en, this message translates to:
  /// **'You already have an ongoing instant order'**
  String get alreadyHaveInstantOrder;

  /// No description provided for @alreadyHaveScheduledOrder.
  ///
  /// In en, this message translates to:
  /// **'You already have a scheduled order'**
  String get alreadyHaveScheduledOrder;

  /// No description provided for @orderProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Order {name}'**
  String orderProductTitle(String name);

  /// No description provided for @upcomingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Upcoming scheduled'**
  String get upcomingScheduled;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get searchAddress;

  /// No description provided for @searchAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gulshan-e-Iqbal, Karachi'**
  String get searchAddressHint;

  /// No description provided for @searchAddressHelp.
  ///
  /// In en, this message translates to:
  /// **'Search an address, then fine-tune the pin on the map'**
  String get searchAddressHelp;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @noActiveBranches.
  ///
  /// In en, this message translates to:
  /// **'No active branches available'**
  String get noActiveBranches;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String kmAway(String km);

  /// No description provided for @tabRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get tabRequested;

  /// No description provided for @tabScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get tabScheduled;

  /// No description provided for @tabOthersWithCount.
  ///
  /// In en, this message translates to:
  /// **'Others ({count})'**
  String tabOthersWithCount(int count);

  /// No description provided for @noRequestedOrders.
  ///
  /// In en, this message translates to:
  /// **'No requested orders'**
  String get noRequestedOrders;

  /// No description provided for @noRequestedOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instant and due scheduled orders appear here.'**
  String get noRequestedOrdersSubtitle;

  /// No description provided for @noScheduledOrders.
  ///
  /// In en, this message translates to:
  /// **'No scheduled orders'**
  String get noScheduledOrders;

  /// No description provided for @noScheduledOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Orders scheduled for later appear here until their time arrives.'**
  String get noScheduledOrdersSubtitle;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @qtyWithValue.
  ///
  /// In en, this message translates to:
  /// **'Qty {quantity}'**
  String qtyWithValue(int quantity);

  /// No description provided for @assignOrder.
  ///
  /// In en, this message translates to:
  /// **'Assign order'**
  String get assignOrder;

  /// No description provided for @scheduledOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled order'**
  String get scheduledOrderTitle;

  /// No description provided for @customerWithName.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}'**
  String customerWithName(String name);

  /// No description provided for @noteWithText.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String noteWithText(String note);

  /// No description provided for @scheduledAssignLockedHint.
  ///
  /// In en, this message translates to:
  /// **'This order is scheduled. You can review details now, but assignment unlocks when the scheduled time arrives.'**
  String get scheduledAssignLockedHint;

  /// No description provided for @selectRider.
  ///
  /// In en, this message translates to:
  /// **'Select rider'**
  String get selectRider;

  /// No description provided for @myBranch.
  ///
  /// In en, this message translates to:
  /// **'My branch'**
  String get myBranch;

  /// No description provided for @otherBranches.
  ///
  /// In en, this message translates to:
  /// **'Other branches'**
  String get otherBranches;

  /// No description provided for @noRidersInGroup.
  ///
  /// In en, this message translates to:
  /// **'No riders in this group'**
  String get noRidersInGroup;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get estimatedArrival;

  /// No description provided for @assignAndNotifyRider.
  ///
  /// In en, this message translates to:
  /// **'Assign & notify rider'**
  String get assignAndNotifyRider;

  /// No description provided for @newlyAssigned.
  ///
  /// In en, this message translates to:
  /// **'Newly Assigned'**
  String get newlyAssigned;

  /// No description provided for @noAssignedOrders.
  ///
  /// In en, this message translates to:
  /// **'No assigned orders'**
  String get noAssignedOrders;

  /// No description provided for @noAssignedOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New deliveries from your supervisor will appear here.'**
  String get noAssignedOrdersSubtitle;

  /// No description provided for @startDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start delivery'**
  String get startDelivery;

  /// No description provided for @markArrived.
  ///
  /// In en, this message translates to:
  /// **'Mark arrived'**
  String get markArrived;

  /// No description provided for @viewAllActive.
  ///
  /// In en, this message translates to:
  /// **'View all {count} active'**
  String viewAllActive(int count);

  /// No description provided for @noOrdersMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No orders match filters'**
  String get noOrdersMatchFilters;

  /// No description provided for @tryChangingSearchOrFilters.
  ///
  /// In en, this message translates to:
  /// **'Try changing search or filters.'**
  String get tryChangingSearchOrFilters;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @qtyTotal.
  ///
  /// In en, this message translates to:
  /// **'Qty / Total'**
  String get qtyTotal;

  /// No description provided for @placed.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get placed;

  /// No description provided for @supervisorEta.
  ///
  /// In en, this message translates to:
  /// **'Supervisor ETA'**
  String get supervisorEta;

  /// No description provided for @supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @statToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statToday;

  /// No description provided for @statNewAssigned.
  ///
  /// In en, this message translates to:
  /// **'New assigned'**
  String get statNewAssigned;

  /// No description provided for @statNewRequests.
  ///
  /// In en, this message translates to:
  /// **'New requests'**
  String get statNewRequests;

  /// No description provided for @statInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statInProgress;

  /// No description provided for @statCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statCompleted;

  /// No description provided for @statFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statFailed;

  /// No description provided for @statPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statPending;

  /// No description provided for @statTotalRange.
  ///
  /// In en, this message translates to:
  /// **'Total (range)'**
  String get statTotalRange;

  /// No description provided for @statRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get statRevenue;

  /// No description provided for @vehicleWithPlate.
  ///
  /// In en, this message translates to:
  /// **'Vehicle: {plate}'**
  String vehicleWithPlate(String plate);

  /// No description provided for @branchWithId.
  ///
  /// In en, this message translates to:
  /// **'Branch: {id}'**
  String branchWithId(String id);

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @timeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get timeSpent;

  /// No description provided for @supervisorNotified.
  ///
  /// In en, this message translates to:
  /// **'Supervisor notified'**
  String get supervisorNotified;

  /// No description provided for @rider.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get rider;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @sendMessageToSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Send message to supervisor'**
  String get sendMessageToSupervisor;

  /// No description provided for @searchCustomerOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Search customer or phone'**
  String get searchCustomerOrPhone;

  /// No description provided for @searchCustomerOrRider.
  ///
  /// In en, this message translates to:
  /// **'Search customer or rider'**
  String get searchCustomerOrRider;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetails;

  /// No description provided for @waitingCustomerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for customer to confirm delivery.'**
  String get waitingCustomerConfirm;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @newOrdersWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} new order(s) waiting'**
  String newOrdersWaiting(int count);

  /// No description provided for @openOrdersToAssignHint.
  ///
  /// In en, this message translates to:
  /// **'Open Orders → Requested to assign a rider'**
  String get openOrdersToAssignHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
