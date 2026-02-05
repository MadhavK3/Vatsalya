import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maternal_infant_care/core/services/translation_service.dart';

/// Key for storing language preference
const String _languageKey = 'app_language';

/// Provider for the current app language
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

/// Notifier for managing language state
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _loadLanguage();
  }

  /// Load saved language preference
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null) {
        state = savedLanguage;
      }
    } catch (e) {
      // Use default language on error
    }
  }

  /// Change the app language
  Future<void> setLanguage(String languageCode) async {
    if (state == languageCode) return;
    
    state = languageCode;
    
    // Clear translation cache when language changes
    // Actually, we SHOULD NOT clear cache just because language changes.
    // We might want to switch back and forth. 
    // Hive cache handles keys by language "Text_TargetLang", so it's safe to keep.
    // await TranslationService().clearCache(); 
    
    // Save preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Continue even if saving fails
    }
  }

  /// Get current language info
  AppLanguage get currentLanguage => AppLanguage.getByCode(state);
}
