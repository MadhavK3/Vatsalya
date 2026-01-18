import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

class AppTheme {
  // Modern Material 3 Palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Violet
  static const Color accentColor = Color(0xFFF43F5E); // Rose
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color darkBackgroundColor = Color(0xFF0F172A); // Slate 900

  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: isDark ? darkBackgroundColor : backgroundColor,
      surface: isDark ? const Color(0xFF1E293B) : Colors.white,
    );

    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = GoogleFonts.outfitTextTheme(baseTextTheme).apply(
      bodyColor: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
      displayColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? darkBackgroundColor : backgroundColor,
      textTheme: textTheme,
      
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      
      // cardTheme: CardTheme(
      //   elevation: 2,
      //   shadowColor: Colors.black.withOpacity(0.05),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //     side: BorderSide(
      //       color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
      //       width: 1,
      //     ),
      //   ),
      //   color: isDark ? const Color(0xFF1E293B) : Colors.white,
      // ),
      
      // dialogTheme: DialogTheme(
      //   backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      //   surfaceTintColor: primaryColor,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(24),
      //   ),
      //   titleTextStyle: textTheme.titleLarge?.copyWith(
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      ),
    );
  }
}
