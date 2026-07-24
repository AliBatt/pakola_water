import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes the app locale (English / Urdu).
class LocaleController extends ChangeNotifier {
  LocaleController();

  static const _prefsKey = 'app_locale';

  Locale _locale = const Locale('en');
  bool _ready = false;

  Locale get locale => _locale;
  bool get isReady => _ready;
  bool get isUrdu => _locale.languageCode == 'ur';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == 'ur' || code == 'en') {
      _locale = Locale(code!);
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'ur') return;
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }

  Future<void> setEnglish() => setLocale(const Locale('en'));

  Future<void> setUrdu() => setLocale(const Locale('ur'));
}
