import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/color_theme.dart';

class AppTheme {
  // Current color theme - can be changed at runtime
  static ColorThemeOption _currentTheme = ColorThemes.defaultTheme;

  /// Get the current color theme
  static ColorThemeOption get currentTheme => _currentTheme;

  /// Set the current color theme
  static void setColorTheme(ColorThemeOption theme) {
    _currentTheme = theme;
  }

  /// Set the current color theme by ID
  static void setColorThemeById(String themeId) {
    _currentTheme = ColorThemes.getById(themeId);
  }

  // Dynamic primary colors based on current theme
  static Color get primaryColor => _currentTheme.primaryColor;
  static Color get primaryDark => _currentTheme.primaryDark;
  static Color get primaryLight => _currentTheme.primaryLight;

  // Accent neon colors
  static const Color neonPink = Color(0xFFFF00FF);
  static const Color neonPurple = Color(0xFFBF00FF);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonOrange = Color(0xFFFF6600);
  static const Color neonRed = Color(0xFFFF0044);

  // Dark cyberpunk backgrounds
  static const Color surfaceLight = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF0D0D1A);

  static const Color backgroundLight = Color(0xFF16213E);
  static const Color backgroundDark = Color(0xFF0A0A14);

  static const Color cardLight = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF12121F);

  // Text colors with neon glow effect
  static const Color textPrimaryLight = Color(0xFFE0E0FF);
  static const Color textPrimaryDark = Color(0xFFE8E8FF);

  static const Color textSecondaryLight = Color(0xFF8888AA);
  static const Color textSecondaryDark = Color(0xFF7777AA);

  static const Color successColor = Color(0xFF39FF14); // Neon green
  static const Color errorColor = Color(0xFFFF0044); // Neon red
  static const Color warningColor = Color(0xFFFFFF00); // Neon yellow

  // User message bubble color - Neon pink/purple gradient
  static const Color userBubbleLight = Color(0xFFBF00FF);
  static const Color userBubbleDark = Color(0xFF9900CC);

  // Assistant message bubble color - Dark with cyan accent
  static const Color assistantBubbleLight = Color(0xFF1A1A2E);
  static const Color assistantBubbleDark = Color(0xFF12121F);

  // Cyberpunk gradients - now dynamic based on primaryColor
  static LinearGradient get neonGradient => LinearGradient(
    colors: [neonPink, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A14), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glow effect helpers
  static List<BoxShadow> neonGlow(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.6 * intensity),
        blurRadius: 8,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.3 * intensity),
        blurRadius: 16,
        spreadRadius: 2,
      ),
    ];
  }

  static ThemeData get lightTheme {
    // Cyberpunk is always dark - redirect to dark theme
    return darkTheme;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: neonPink,
        tertiary: neonPurple,
        surface: surfaceDark,
        error: errorColor,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurface: textPrimaryDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      textTheme: GoogleFonts.orbitronTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textPrimaryDark, displayColor: primaryColor),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryColor,
          letterSpacing: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: TextStyle(
          color: textSecondaryDark,
          fontFamily: GoogleFonts.rajdhani().fontFamily,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: primaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonPink,
          side: const BorderSide(color: neonPink, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: primaryColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        labelStyle: TextStyle(
          color: primaryColor,
          fontFamily: GoogleFonts.rajdhani().fontFamily,
        ),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dividerTheme: DividerThemeData(
        color: primaryColor.withValues(alpha: 0.2),
        thickness: 1,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: backgroundDark,
        surfaceTintColor: primaryColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: TextStyle(
          color: primaryColor,
          fontFamily: GoogleFonts.rajdhani().fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: primaryColor),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceDark,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: neonPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: neonPink, width: 2),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryColor,
        textColor: textPrimaryDark,
        selectedColor: primaryColor,
        selectedTileColor: primaryColor.withValues(alpha: 0.1),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return textSecondaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.3);
          }
          return surfaceDark;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return textSecondaryDark;
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
