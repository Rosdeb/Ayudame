import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale spanishLocale = Locale('es', 'ES');

  static Map<String, Map<String, String>> _translations = {
    'en_US': <String, String>{},
    'es_ES': <String, String>{},
  };
  static Map<String, Map<String, String>> _normalizedTranslations = {
    'en_US': <String, String>{},
    'es_ES': <String, String>{},
  };

  static Future<void> init() async {
    final Map<String, String> en = await _loadAndFlatten('en.json');
    final Map<String, String> es = await _loadAndFlatten('es.json');

    _translations = {
      'en_US': Map<String, String>.from(en),
      'es_ES': Map<String, String>.from(es),
    };

    _addValueAliases(en, es);
    _buildNormalizedTranslations();
  }

  static Future<Map<String, String>> _loadAndFlatten(String assetPath) async {
    final String rawJson = await rootBundle.loadString(assetPath);
    final dynamic decodedJson = jsonDecode(rawJson);

    if (decodedJson is! Map<String, dynamic>) {
      return <String, String>{};
    }

    final Map<String, String> flattened = <String, String>{};
    _flattenJson(decodedJson, flattened);
    return flattened;
  }

  static void _flattenJson(
    Map<String, dynamic> source,
    Map<String, String> target, [
    String prefix = '',
  ]) {
    source.forEach((String key, dynamic value) {
      final String currentKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map) {
        _flattenJson(Map<String, dynamic>.from(value), target, currentKey);
      } else if (value != null) {
        target[currentKey] = value.toString();
      } else {
        target[currentKey] = '';
      }
    });
  }

  static void _addValueAliases(
    Map<String, String> en,
    Map<String, String> es,
  ) {
    for (final String key in en.keys) {
      final String englishValue = en[key] ?? '';
      final String spanishValue = es[key] ?? englishValue;

      _setAlias(englishValue, englishValue, spanishValue);
      _setAlias(spanishValue, englishValue, spanishValue);
    }
  }

  static void _setAlias(
    String alias,
    String englishValue,
    String spanishValue,
  ) {
    final String normalizedAlias = alias.trim();
    if (normalizedAlias.isEmpty) return;

    _translations['en_US']!.putIfAbsent(normalizedAlias, () => englishValue);
    _translations['es_ES']!.putIfAbsent(normalizedAlias, () => spanishValue);
  }

  static void _buildNormalizedTranslations() {
    _normalizedTranslations = <String, Map<String, String>>{};

    _translations.forEach((String localeKey, Map<String, String> localeMap) {
      final Map<String, String> normalizedMap = <String, String>{};

      localeMap.forEach((String source, String translated) {
        final String normalizedSource = _normalizeText(source);
        if (normalizedSource.isNotEmpty && translated.isNotEmpty) {
          normalizedMap.putIfAbsent(normalizedSource, () => translated);
        }
      });

      _normalizedTranslations[localeKey] = normalizedMap;
    });
  }

  static String _normalizeText(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\s\-_]+'), '')
        .replaceAll(RegExp(r'''[.,!?;:"'`]+'''), '')
        .replaceAll('&', 'and');
  }

  static String _localeKeyFrom(Locale? locale) {
    if (locale?.languageCode == spanishLocale.languageCode) {
      return 'es_ES';
    }
    return 'en_US';
  }

  static String translateValue(String text) {
    if (text.isEmpty) return text;

    final String localeKey = _localeKeyFrom(Get.locale ?? Get.deviceLocale);
    final Map<String, String> localeMap =
        _translations[localeKey] ?? _translations['en_US']!;

    final String? direct = localeMap[text];
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final String normalized = _normalizeText(text);
    if (normalized.isNotEmpty) {
      final String? normalizedValue = _normalizedTranslations[localeKey]?[normalized];
      if (normalizedValue != null && normalizedValue.isNotEmpty) {
        return normalizedValue;
      }

      final String? englishFallback = _normalizedTranslations['en_US']?[normalized];
      if (englishFallback != null && englishFallback.isNotEmpty) {
        return englishFallback;
      }
    }

    return text;
  }

  @override
  Map<String, Map<String, String>> get keys => _translations;
}
