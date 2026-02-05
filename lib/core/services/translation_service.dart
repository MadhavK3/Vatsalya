import 'package:translator_plus/translator_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Supported languages for the app
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', name: 'English', nativeName: 'English'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    AppLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
  ];

  static AppLanguage getByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}

/// Translation service using Google Translate with Hive caching
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();
  Box? _box;
  static const String _boxName = 'translations_cache';

  /// Initialize the translation service (open Hive box)
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  /// Translate text from English to target language
  Future<String> translate(String text, String targetLanguage) async {
    // If target is English or text is empty, return as-is
    if (targetLanguage == 'en' || text.trim().isEmpty) {
      return text;
    }

    // Ensure box is initialized
    if (_box == null || !_box!.isOpen) {
      await init();
    }

    // Check cache first
    // Key format: "text_targetLanguage"
    final cacheKey = '${text}_$targetLanguage';
    if (_box!.containsKey(cacheKey)) {
      final cached = _box!.get(cacheKey);
      if (cached != null && cached.toString().isNotEmpty) {
        return cached.toString();
      }
    }

    try {
      final translation = await _translator.translate(
        text,
        from: 'en',
        to: targetLanguage,
      );
      
      // Cache the result
      await _box!.put(cacheKey, translation.text);
      
      return translation.text;
    } catch (e) {
      debugPrint('Translation error for "$text" to $targetLanguage: $e');
      // On error, check if we have any old cache, otherwise return original
      if (_box!.containsKey(cacheKey)) {
        return _box!.get(cacheKey).toString();
      }
      return text; 
    }
  }

  /// Clear translation cache
  Future<void> clearCache() async {
    if (_box != null && _box!.isOpen) {
      await _box!.clear();
    }
  }
}
