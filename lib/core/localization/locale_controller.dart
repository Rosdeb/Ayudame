import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_translations.dart';

class LocaleController extends GetxController {
  static const String _languageCodeKey = 'app_language_code';
  static const String _countryCodeKey = 'app_country_code';

  Locale _locale = AppTranslations.englishLocale;
  Locale get locale => _locale;

  Future<void> loadSavedLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageCodeKey);
    final String? countryCode = prefs.getString(_countryCodeKey);

    if (languageCode != null && languageCode.isNotEmpty) {
      _locale = Locale(
        languageCode,
        countryCode != null && countryCode.isNotEmpty ? countryCode : null,
      );
    } else {
      final Locale? deviceLocale = Get.deviceLocale;
      if (deviceLocale?.languageCode == AppTranslations.spanishLocale.languageCode) {
        _locale = AppTranslations.spanishLocale;
      } else {
        _locale = AppTranslations.englishLocale;
      }
    }

    Get.updateLocale(_locale);
    update();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    await prefs.setString(_countryCodeKey, locale.countryCode ?? '');

    await Get.updateLocale(locale);
    update();
  }
}
