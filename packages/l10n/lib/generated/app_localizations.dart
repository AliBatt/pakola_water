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
