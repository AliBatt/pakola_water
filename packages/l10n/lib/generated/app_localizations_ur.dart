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

  @override
  String get adminPanelSubtitle => 'آپریشنز کنسول';

  @override
  String get adminConsoleLabel => 'ایڈمن کنسول';

  @override
  String get adminRoleLabel => 'ایڈمنسٹریٹر';

  @override
  String get myRequests => 'میری درخواستیں';

  @override
  String get myRequestsSubtitle => 'ایڈمن کو درخواست بھیجیں اور جوابات دیکھیں';

  @override
  String get newRequest => 'نئی درخواست';

  @override
  String get newRequestSubtitle =>
      'ایڈمن کو درخواست بھیجیں۔ ایک اختیاری تصویر منسلک کر سکتے ہیں۔';

  @override
  String get requestTitle => 'عنوان';

  @override
  String get requestDescription => 'تفصیل';

  @override
  String get addImageOptional => 'تصویر شامل کریں (اختیاری)';

  @override
  String get removeImage => 'تصویر ہٹائیں';

  @override
  String get sendRequest => 'درخواست بھیجیں';

  @override
  String get requestSentToAdmin => 'درخواست ایڈمن کو بھیج دی گئی';

  @override
  String get titleRequired => 'عنوان ضروری ہے';

  @override
  String get descriptionRequired => 'تفصیل ضروری ہے';

  @override
  String get searchYourRequests => 'اپنی درخواستیں تلاش کریں…';

  @override
  String get searchRequestsAdmin => 'نام، عنوان، کردار سے تلاش کریں…';

  @override
  String get allStatuses => 'تمام حالتیں';

  @override
  String get noRequests => 'کوئی درخواست نہیں';

  @override
  String get noRequestsSubtitle => 'ایڈمن سے مدد کے لیے درخواست بنائیں۔';

  @override
  String get noRequestsAdminSubtitle =>
      'گاہک، سپروائزر اور رائڈر کی درخواستیں یہاں دکھائی دیں گی۔';

  @override
  String get adminActions => 'ایڈمن کارروائیاں';

  @override
  String get markInProgress => 'جاری میں نشان زد کریں';

  @override
  String get completeAction => 'مکمل';

  @override
  String get rejectAction => 'مسترد';

  @override
  String get conversation => 'گفتگو';

  @override
  String get noRepliesYet => 'ابھی کوئی جواب نہیں۔ نیچے گفتگو شروع کریں۔';

  @override
  String get writeAReply => 'جواب لکھیں';

  @override
  String markedAsStatus(String status) {
    return '$status کے طور پر نشان زد';
  }

  @override
  String requestNoLongerAcceptsReplies(String status) {
    return 'یہ درخواست $status ہے اور اب جواب قبول نہیں کرتی۔';
  }

  @override
  String get supportStatusOpen => 'کھلی';

  @override
  String get supportStatusInProgress => 'جاری';

  @override
  String get supportStatusCompleted => 'مکمل';

  @override
  String get supportStatusRejected => 'مسترد';

  @override
  String get supportStatusClosed => 'بند';

  @override
  String get pushNotifications => 'پش اطلاعات';

  @override
  String pushEnabledWithToken(String token) {
    return 'فعال · ٹوکن $token';
  }

  @override
  String get pushDisabledHint =>
      'غیر فعال — اطلاعات کی اجازت کے لیے تھپتھپائیں';

  @override
  String get enable => 'فعال کریں';

  @override
  String get notificationsEnabled => 'اطلاعات فعال ہو گئیں';

  @override
  String get couldNotEnableNotifications => 'اطلاعات فعال نہیں ہو سکیں';

  @override
  String get orderType => 'آرڈر کی قسم';

  @override
  String get orderTypeInstant => 'فوری';

  @override
  String get orderTypeScheduled => 'شیڈولڈ';

  @override
  String get instantOrderOngoingHint => 'آپ کے پاس پہلے سے جاری فوری آرڈر ہے';

  @override
  String get instantOrderStartHint => 'جتنی جلدی ممکن ہو ڈیلیوری شروع کریں';

  @override
  String get scheduledOrderExistingHint => 'آپ کے پاس پہلے سے شیڈولڈ آرڈر ہے';

  @override
  String get scheduledOrderChooseHint => 'بعد کی تاریخ اور وقت منتخب کریں';

  @override
  String get selectDateAndTime => 'تاریخ اور وقت منتخب کریں';

  @override
  String scheduledForLabel(String when) {
    return 'شیڈول: $when';
  }

  @override
  String get deliveryLocation => 'ڈیلیوری مقام';

  @override
  String get mySavedAddress => 'میرا محفوظ پتہ';

  @override
  String get noAddressOnProfile => 'پروفائل پر کوئی پتہ نہیں';

  @override
  String get noAddressOnYourProfile => 'آپ کے پروفائل پر کوئی پتہ نہیں';

  @override
  String get differentLocationForOrder => 'اس آرڈر کے لیے مختلف مقام';

  @override
  String get searchAndPinCustom => 'تلاش کریں اور حسبِ ضرورت مقام پن کریں';

  @override
  String get deliveringTo => 'ڈیلیوری یہاں';

  @override
  String selectedCustomLocation(String address) {
    return 'منتخب: $address (حسبِ ضرورت مقام)';
  }

  @override
  String get scheduledTimeMustBeFuture => 'شیڈول وقت مستقبل میں ہونا چاہیے';

  @override
  String get deliveryAddressRequired => 'ڈیلیوری پتہ ضروری ہے';

  @override
  String get deliveryLocationRequired => 'ڈیلیوری مقام ضروری ہے';

  @override
  String get selectABranch => 'برانچ منتخب کریں';

  @override
  String get selectScheduleDateTime => 'شیڈول کی تاریخ اور وقت منتخب کریں';

  @override
  String get alreadyHaveInstantOrder => 'آپ کے پاس پہلے سے جاری فوری آرڈر ہے';

  @override
  String get alreadyHaveScheduledOrder => 'آپ کے پاس پہلے سے شیڈولڈ آرڈر ہے';

  @override
  String orderProductTitle(String name) {
    return 'آرڈر $name';
  }

  @override
  String get upcomingScheduled => 'آنے والا شیڈولڈ';

  @override
  String get searchAddress => 'پتہ تلاش کریں';

  @override
  String get searchAddressHint => 'مثلاً گلشنِ اقبال، کراچی';

  @override
  String get searchAddressHelp => 'پتہ تلاش کریں، پھر نقشے پر پن ٹھیک کریں';

  @override
  String get clear => 'صاف';

  @override
  String get branch => 'برانچ';

  @override
  String get noActiveBranches => 'کوئی فعال برانچ دستیاب نہیں';

  @override
  String get recommended => 'تجویز کردہ';

  @override
  String kmAway(String km) {
    return '$km کلومیٹر دور';
  }

  @override
  String get tabRequested => 'درخواست شدہ';

  @override
  String get tabScheduled => 'شیڈولڈ';

  @override
  String tabOthersWithCount(int count) {
    return 'دیگر ($count)';
  }

  @override
  String get noRequestedOrders => 'کوئی درخواست شدہ آرڈر نہیں';

  @override
  String get noRequestedOrdersSubtitle =>
      'فوری اور واجب شیڈولڈ آرڈرز یہاں دکھائی دیتے ہیں۔';

  @override
  String get noScheduledOrders => 'کوئی شیڈولڈ آرڈر نہیں';

  @override
  String get noScheduledOrdersSubtitle =>
      'بعد کے لیے شیڈولڈ آرڈرز وقت آنے تک یہاں رہتے ہیں۔';

  @override
  String get waiting => 'انتظار';

  @override
  String qtyWithValue(int quantity) {
    return 'مقدار $quantity';
  }

  @override
  String get assignOrder => 'آرڈر تفویض کریں';

  @override
  String get scheduledOrderTitle => 'شیڈولڈ آرڈر';

  @override
  String customerWithName(String name) {
    return 'گاہک: $name';
  }

  @override
  String noteWithText(String note) {
    return 'نوٹ: $note';
  }

  @override
  String get scheduledAssignLockedHint =>
      'یہ آرڈر شیڈولڈ ہے۔ آپ تفصیلات دیکھ سکتے ہیں، لیکن تفویض شیڈول وقت پر کھلے گی۔';

  @override
  String get selectRider => 'رائڈر منتخب کریں';

  @override
  String get myBranch => 'میری برانچ';

  @override
  String get otherBranches => 'دیگر برانچز';

  @override
  String get noRidersInGroup => 'اس گروپ میں کوئی رائڈر نہیں';

  @override
  String get estimatedArrival => 'متوقع آمد';

  @override
  String get assignAndNotifyRider => 'تفویض کریں اور رائڈر کو مطلع کریں';

  @override
  String get newlyAssigned => 'نئے تفویض شدہ';

  @override
  String get noAssignedOrders => 'کوئی تفویض شدہ آرڈر نہیں';

  @override
  String get noAssignedOrdersSubtitle =>
      'سپروائزر کی نئی ڈیلیوریز یہاں دکھائی دیں گی۔';

  @override
  String get startDelivery => 'ڈیلیوری شروع کریں';

  @override
  String get markArrived => 'پہنچ گیا نشان زد کریں';

  @override
  String viewAllActive(int count) {
    return 'تمام $count فعال دیکھیں';
  }

  @override
  String get noOrdersMatchFilters => 'فلٹرز سے کوئی آرڈر نہیں ملا';

  @override
  String get tryChangingSearchOrFilters => 'تلاش یا فلٹرز تبدیل کر کے دیکھیں۔';

  @override
  String get status => 'حالت';

  @override
  String get customer => 'گاہک';

  @override
  String get qtyTotal => 'مقدار / کل';

  @override
  String get placed => 'دیا گیا';

  @override
  String get supervisorEta => 'سپروائزر ETA';

  @override
  String get supervisor => 'سپروائزر';

  @override
  String get note => 'نوٹ';

  @override
  String get back => 'واپس';

  @override
  String get statToday => 'آج';

  @override
  String get statNewAssigned => 'نئے تفویض';

  @override
  String get statNewRequests => 'نئی درخواستیں';

  @override
  String get statInProgress => 'جاری';

  @override
  String get statCompleted => 'مکمل';

  @override
  String get statFailed => 'ناکام';

  @override
  String get statPending => 'زیرِ التوا';

  @override
  String get statTotalRange => 'کل (رینج)';

  @override
  String get statRevenue => 'آمدنی';

  @override
  String vehicleWithPlate(String plate) {
    return 'گاڑی: $plate';
  }

  @override
  String branchWithId(String id) {
    return 'برانچ: $id';
  }

  @override
  String get created => 'بنایا گیا';

  @override
  String get timeSpent => 'وقت صرف';

  @override
  String get supervisorNotified => 'سپروائزر مطلع';

  @override
  String get rider => 'رائڈر';

  @override
  String get eta => 'ETA';

  @override
  String get sendMessageToSupervisor => 'سپروائزر کو پیغام بھیجیں';

  @override
  String get searchCustomerOrPhone => 'گاہک یا فون تلاش کریں';

  @override
  String get searchCustomerOrRider => 'گاہک یا رائڈر تلاش کریں';

  @override
  String get orderDetails => 'آرڈر کی تفصیلات';

  @override
  String get waitingCustomerConfirm => 'گاہک کی ڈیلیوری تصدیق کا انتظار۔';

  @override
  String get view => 'دیکھیں';

  @override
  String newOrdersWaiting(int count) {
    return '$count نئے آرڈر منتظر';
  }

  @override
  String get openOrdersToAssignHint =>
      'آرڈرز کھولیں → رائڈر تفویض کے لیے درخواست شدہ';
}
