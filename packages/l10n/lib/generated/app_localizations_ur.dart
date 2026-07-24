// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'پاکولا واٹرز';

  @override
  String get customerAppTitle => 'پاکولا واٹرز — گاہک';

  @override
  String get driverAppTitle => 'پاکولا واٹرز — ڈرائیور';

  @override
  String get supervisorAppTitle => 'پاکولا واٹرز — سپروائزر';

  @override
  String get adminAppTitle => 'پاکولا واٹرز — ایڈمن';

  @override
  String get loading => 'لوڈ ہو رہا ہے...';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get cancel => 'منسوخ';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get confirm => 'تصدیق';

  @override
  String get close => 'بند کریں';

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String get errorGeneric => 'کچھ غلط ہو گیا۔ دوبارہ کوشش کریں۔';

  @override
  String get successGeneric => 'کامیابی سے مکمل ہو گیا۔';

  @override
  String get networkError => 'انٹرنیٹ کنکشن نہیں ہے۔';

  @override
  String get login => 'سائن ان';

  @override
  String get logout => 'سائن آؤٹ';

  @override
  String get email => 'ای میل';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get comingSoon => 'جلد آرہا ہے';

  @override
  String get emailRequired => 'ای میل ضروری ہے';

  @override
  String get emailInvalid => 'درست ای میل درج کریں';

  @override
  String get passwordRequired => 'پاس ورڈ ضروری ہے';

  @override
  String get passwordTooShort => 'پاس ورڈ کم از کم 6 حروف کا ہونا چاہیے';

  @override
  String welcomeUser(String name) {
    return 'خوش آمدید، $name';
  }

  @override
  String roleLabel(String role) {
    return 'کردار: $role';
  }

  @override
  String statusLabel(String status) {
    return 'حیثیت: $status';
  }

  @override
  String get customerHomeTitle => 'گاہک ڈیش بورڈ';

  @override
  String get customerHomeSubtitle =>
      'اپنے پانی کی ڈیلیوری آرڈرز دیں اور ٹریک کریں۔';

  @override
  String get driverHomeTitle => 'ڈرائیور ڈیش بورڈ';

  @override
  String get driverHomeSubtitle => 'تفویض شدہ ڈیلیوریز دیکھیں اور مکمل کریں۔';

  @override
  String get supervisorHomeTitle => 'سپروائزر ڈیش بورڈ';

  @override
  String get supervisorHomeSubtitle =>
      'برانچ آرڈرز، ڈرائیورز اور انوینٹری کا انتظام کریں۔';

  @override
  String get adminHomeTitle => 'ایڈمن ڈیش بورڈ';

  @override
  String get adminHomeSubtitle =>
      'برانچز، صارفین، مصنوعات اور رپورٹس کا انتظام کریں۔';

  @override
  String get navHome => 'ہوم';

  @override
  String get navBranches => 'برانچز';

  @override
  String get navSupervisors => 'سپروائزرز';

  @override
  String get navRiders => 'رائڈرز';

  @override
  String get navCustomers => 'گاہک';

  @override
  String get navPayments => 'ادائیگیاں';

  @override
  String get navReports => 'رپورٹس';

  @override
  String get navInventory => 'انوینٹری';

  @override
  String get navProducts => 'مصنوعات';

  @override
  String get navNotifications => 'اطلاعات';

  @override
  String get navRequests => 'درخواستیں';

  @override
  String get navOrders => 'آرڈرز';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get navQuickAccess => 'فوری رسائی';

  @override
  String get emptyStateDefault => 'ابھی یہاں کچھ نہیں ہے۔';

  @override
  String get languageEnglish => 'انگریزی';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get themeSystem => 'سسٹم';

  @override
  String get themeLight => 'لائٹ';

  @override
  String get themeDark => 'ڈارک';

  @override
  String get language => 'زبان';

  @override
  String get languageSubtitle => 'ایپ کی زبان منتخب کریں';

  @override
  String get resetPassword => 'پاس ورڈ ری سیٹ';

  @override
  String get resetPasswordSubtitle => 'اپنے ای میل پر ری سیٹ لنک بھیجیں';

  @override
  String get deleteAccount => 'اکاؤنٹ حذف کریں';

  @override
  String get deleteAccountSubtitle =>
      'اپنا اکاؤنٹ اور پروفائل مستقل طور پر ہٹا دیں';

  @override
  String get deleteAccountConfirmTitle => 'اکاؤنٹ حذف کریں؟';

  @override
  String get deleteAccountConfirmBody =>
      'یہ واپس نہیں ہو سکتا۔ آپ کا پروفائل حذف ہو جائے گا اور آپ سائن آؤٹ ہو جائیں گے۔';

  @override
  String get deleteAccountSuccess => 'اکاؤنٹ حذف ہو گیا';

  @override
  String get deleteAccountReauthRequired =>
      'براہ کرم دوبارہ سائن ان کریں، پھر اکاؤنٹ حذف کریں۔';

  @override
  String get noOngoingOrder => 'کوئی جاری آرڈر نہیں';

  @override
  String get noOngoingOrderSubtitle =>
      'مصنوعات دیکھیں اور پانی کی ضرورت پر آرڈر دیں۔';

  @override
  String get browseProducts => 'مصنوعات دیکھیں';

  @override
  String get ongoingOrder => 'جاری آرڈر';

  @override
  String get confirmDelivery => 'ڈیلیوری کی تصدیق';

  @override
  String get confirmDeliveryTitle => 'ڈیلیوری کی تصدیق؟';

  @override
  String get confirmDeliveryBody =>
      'تصدیق کریں کہ آپ کو آرڈر مل گیا اور یہ مکمل ہے۔';

  @override
  String get orderCompleted => 'آرڈر مکمل۔ شکریہ!';

  @override
  String get search => 'تلاش';

  @override
  String get order => 'آرڈر';

  @override
  String get newOrder => 'نیا آرڈر';

  @override
  String get noProducts => 'کوئی مصنوعات نہیں';

  @override
  String get noProductsSubtitle => 'جلد دستیاب مصنوعات چیک کریں۔';

  @override
  String get noOrdersYet => 'ابھی کوئی آرڈر نہیں';

  @override
  String get noOrdersSubtitle => 'آپ کی آرڈر ہسٹری یہاں دکھائی دے گی۔';

  @override
  String get activeOrderBlock => 'نیا آرڈر دینے سے پہلے موجودہ آرڈر مکمل کریں';

  @override
  String get placeOrder => 'آرڈر دیں';

  @override
  String get quantity => 'مقدار';

  @override
  String get extraNote => 'اضافی نوٹ (اختیاری)';

  @override
  String get payment => 'ادائیگی';

  @override
  String get orderPlaced => 'آرڈر دے دیا گیا';

  @override
  String get notificationsEmpty => 'کوئی اطلاع نہیں';

  @override
  String get notificationsEmptySubtitle =>
      'پاکولا واٹرز کی اپڈیٹس یہاں دکھائی دیں گی۔';

  @override
  String get markAllRead => 'سب پڑھے ہوئے نشان زد کریں';

  @override
  String get notificationSent => 'اطلاع بھیج دی گئی';

  @override
  String get sendNotification => 'اطلاع بھیجیں';

  @override
  String get notificationTitle => 'عنوان';

  @override
  String get notificationBody => 'پیغام';

  @override
  String get selectCustomer => 'گاہک منتخب کریں';

  @override
  String fromLabel(String name) {
    return 'از $name';
  }

  @override
  String get unread => 'نئی';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';
}
