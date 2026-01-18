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
  // Vedic / Ancient Indian Palette
  static const Color primaryColor = Color(0xFF800000); // Deep Maroon (Saffron-like depth)
  static const Color secondaryColor = Color(0xFFDAA520); // Goldenrod / Antique Gold
  static const Color accentColor = Color(0xFFCD853F); // Peru / Bronze
  
  // Parchment Backgrounds
  static const Color parchmentLight = Color(0xFFF5E6C9); // Warm Parchment
  static const Color parchmentDark = Color(0xFF3E2723); // Dark Wood / Ancient Scroll

  // Text Colors
  static const Color textDark = Color(0xFF2D1B0E); // Very dark brown (Ink)
  static const Color textLight = Color(0xFFF5E6C9); // Parchment color for dark mode text

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
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      tertiary: accentColor,
      background: isDark ? parchmentDark : parchmentLight,
      surface: isDark ? const Color(0xFF4E342E) : const Color(0xFFFFF8E1), // Slightly lighter/darker surface
      onSurface: isDark ? textLight : textDark,
      onBackground: isDark ? textLight : textDark,
    );

    // Typography - Ancient Style
    // Headings: Cinzel (Classic, Roman/Indian looking caps)
    // Body: Crimson Text (Old style serif, very readable)
    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    
    final textTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.cinzel(
        fontSize: 32, fontWeight: FontWeight.bold, 
        color: isDark ? textLight : textDark
      ),
      displayMedium: GoogleFonts.cinzel(
        fontSize: 28, fontWeight: FontWeight.bold,
        color: isDark ? textLight : textDark
      ),
      displaySmall: GoogleFonts.cinzel(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: isDark ? textLight : textDark
      ),
      headlineLarge: GoogleFonts.cinzel(
        fontSize: 22, fontWeight: FontWeight.bold,
        color: isDark ? textLight : textDark
      ),
      headlineMedium: GoogleFonts.cinzel(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: isDark ? textLight : textDark
      ),
      headlineSmall: GoogleFonts.cinzel(
        fontSize: 18, fontWeight: FontWeight.w500,
        color: isDark ? textLight : textDark
      ),
      titleLarge: GoogleFonts.cinzel(
        fontSize: 20, fontWeight: FontWeight.bold,
        color: isDark ? textLight : textDark
      ),
      titleMedium: GoogleFonts.crimsonText(
        fontSize: 18, fontWeight: FontWeight.bold,
        color: isDark ? textLight : textDark
      ),
      titleSmall: GoogleFonts.crimsonText(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: isDark ? textLight : textDark
      ),
      bodyLarge: GoogleFonts.crimsonText(
        fontSize: 18,
        color: isDark ? textLight : textDark
      ),
      bodyMedium: GoogleFonts.crimsonText(
        fontSize: 16,
        color: isDark ? textLight : textDark
      ),
      bodySmall: GoogleFonts.crimsonText(
        fontSize: 14,
        color: isDark ? textLight.withOpacity(0.8) : textDark.withOpacity(0.8)
      ),
      labelLarge: GoogleFonts.cinzel(
        fontSize: 14, fontWeight: FontWeight.bold,
        color: isDark ? textLight : textDark
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? parchmentDark : parchmentLight,
      textTheme: textTheme,
      
      // Ancient/Ornate AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent, // Let background show through
        foregroundColor: isDark ? textLight : primaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? secondaryColor : primaryColor),
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? textLight : primaryColor,
          letterSpacing: 1.2,
        ),
      ),
      
      // Ornate Cards
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: secondaryColor.withOpacity(0.5), 
            width: 1
          ),
        ),
        color: isDark ? const Color(0xFF4E342E) : const Color(0xFFFFF8E1),
        surfaceTintColor: secondaryColor, // Golden tint on elevation
      ),
      
      // Golden Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: secondaryColor, // Gold text on Maroon button
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.cinzel(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          side: const BorderSide(color: secondaryColor, width: 1),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.cinzel(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Scroll-like Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.4),
        border: UnderlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        labelStyle: TextStyle(
          color: isDark ? textLight.withOpacity(0.7) : textDark.withOpacity(0.7),
          fontFamily: GoogleFonts.crimsonText().fontFamily,
          fontSize: 18,
        ),
        prefixIconColor: primaryColor,
      ),
      
      iconTheme: IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      
      // Golden Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF2D1B0E) : const Color(0xFFF5E6C9),
        indicatorColor: secondaryColor.withOpacity(0.4),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.cinzel(
            fontSize: 12, 
            fontWeight: FontWeight.w600,
            color: isDark ? textLight : textDark,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return IconThemeData(color: isDark ? textLight.withOpacity(0.7) : textDark.withOpacity(0.7));
        }),
      ),
    );
  }
}
