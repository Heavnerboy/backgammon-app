import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _locale; // null = Systemstandard
  Locale? get locale => _locale;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString('localeCode');
    if (code != null) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final sp = await SharedPreferences.getInstance();
    if (locale == null) {
      await sp.remove('localeCode'); // zurück auf System
    } else {
      await sp.setString('localeCode', locale.languageCode);
    }
    notifyListeners();
  }
}