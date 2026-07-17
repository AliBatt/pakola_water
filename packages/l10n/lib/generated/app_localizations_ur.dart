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
}
