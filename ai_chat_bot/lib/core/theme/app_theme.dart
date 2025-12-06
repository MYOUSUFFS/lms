import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/color_theme.dart';
import '../models/theme_style.dart';

class AppTheme {
  // Current color theme - can be changed at runtime
  static ColorThemeOption _currentTheme = ColorThemes.defaultTheme;
  // Current theme style - can be changed at runtime
  static ThemeStyle _currentStyle = ThemeStyle.classic;
  // Current brightness - set by the app based on theme mode
  static Brightness _currentBrightness = Brightness.light;

  /// Get the current color theme
  static ColorThemeOption get currentTheme => _currentTheme;

  /// Get the current theme style
  static ThemeStyle get currentStyle => _currentStyle;

  /// Get the current brightness
  static Brightness get currentBrightness => _currentBrightness;

  /// Set the current color theme
  static void setColorTheme(ColorThemeOption theme) {
    _currentTheme = theme;
  }

  /// Set the current theme style
  static void setThemeStyle(ThemeStyle style) {
    _currentStyle = style;
  }

  /// Set the current brightness
  static void setBrightness(Brightness brightness) {
    _currentBrightness = brightness;
  }

  /// Set the current color theme by ID
  static void setColorThemeById(String themeId) {
    _currentTheme = ColorThemes.getById(themeId);
  }

  /// Check if current style is cyberpunk
  static bool get isCyberpunk => _currentStyle == ThemeStyle.cyberpunk;

  /// Check if current theme is dark
  static bool get isDark => _currentBrightness == Brightness.dark;

  // Dynamic primary colors based on current theme
  static Color get primaryColor => _currentTheme.primaryColor;
  static Color get primaryDark => _currentTheme.primaryDark;
  static Color get primaryLight => _currentTheme.primaryLight;

  // Accent neon colors (for cyberpunk theme)
  static const Color neonPink = Color(0xFFFF00FF);
  static const Color neonPurple = Color(0xFFBF00FF);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonOrange = Color(0xFFFF6600);
  static const Color neonRed = Color(0xFFFF0044);

  // Classic theme colors
  static const Color _classicSurfaceLight = Color(0xFFFAFAFA);
  static const Color _classicBackgroundLight = Color(0xFFFAFAFA);
  static const Color _classicCardLight = Color(0xFFFFFFFF);
  static const Color _classicTextPrimaryLight = Color(0xFF1A1A1A);
  static const Color _classicTextSecondaryLight = Color(0xFF6B7280);

  static const Color _classicSurfaceDark = Color(0xFF1E293B);
  static const Color _classicBackgroundDark = Color(0xFF0F172A);
  static const Color _classicCardDark = Color(0xFF1E293B);
  static const Color _classicTextPrimaryDark = Color(0xFFF1F5F9);
  static const Color _classicTextSecondaryDark = Color(0xFF94A3B8);

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

  // ============ THEME-AWARE COLOR GETTERS ============
  // These return different colors based on the current theme style

  /// Get accent color (dynamic primaryColor for cyberpunk, or dynamic primaryColor for classic)
  static Color get accentColor => isCyberpunk ? primaryColor : primaryColor;

  /// Get secondary accent color (neonPink for cyberpunk, primaryLight for classic)
  static Color get secondaryAccent => isCyberpunk ? neonPink : primaryLight;

  /// Get surface color based on theme style and brightness
  static Color get themeSurface {
    if (isCyberpunk) {
      return surfaceDark;
    }
    return isDark ? _classicSurfaceDark : _classicSurfaceLight;
  }

  /// Get background color based on theme style and brightness
  static Color get themeBackground {
    if (isCyberpunk) {
      return backgroundDark;
    }
    return isDark ? _classicBackgroundDark : _classicBackgroundLight;
  }

  /// Get card color based on theme style and brightness
  static Color get themeCard {
    if (isCyberpunk) {
      return cardDark;
    }
    return isDark ? _classicCardDark : _classicCardLight;
  }

  /// Get primary text color based on theme style and brightness
  static Color get themeTextPrimary {
    if (isCyberpunk) {
      return textPrimaryDark;
    }
    return isDark ? _classicTextPrimaryDark : _classicTextPrimaryLight;
  }

  /// Get secondary text color based on theme style and brightness
  static Color get themeTextSecondary {
    if (isCyberpunk) {
      return textSecondaryDark;
    }
    return isDark ? _classicTextSecondaryDark : _classicTextSecondaryLight;
  }

  /// Get success color based on theme style
  static Color get themeSuccess =>
      isCyberpunk ? neonGreen : const Color(0xFF22C55E);

  /// Get error color based on theme style
  static Color get themeError =>
      isCyberpunk ? neonRed : const Color(0xFFEF4444);

  /// Get warning color based on theme style
  static Color get themeWarning =>
      isCyberpunk ? neonYellow : const Color(0xFFF59E0B);

  /// Get border radius based on theme style
  static double get themeBorderRadius => isCyberpunk ? 4.0 : 12.0;

  /// Get text style for headers based on theme
  static TextStyle getHeaderTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    final effectiveColor = color ?? accentColor;
    if (isCyberpunk) {
      return GoogleFonts.orbitron(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: effectiveColor,
        letterSpacing: 2,
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
    );
  }

  /// Get text style for body text based on theme
  static TextStyle getBodyTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    final effectiveColor = color ?? themeTextPrimary;
    if (isCyberpunk) {
      return GoogleFonts.rajdhani(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: effectiveColor,
        letterSpacing: 1,
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
    );
  }

  /// Get box decoration for containers based on theme
  static BoxDecoration getContainerDecoration({
    Color? color,
    Color? borderColor,
    double? borderRadius,
    bool withGlow = false,
  }) {
    final effectiveColor = color ?? themeCard;
    final effectiveBorderColor = borderColor ?? accentColor;
    final effectiveBorderRadius = borderRadius ?? themeBorderRadius;

    if (isCyberpunk) {
      return BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(color: effectiveBorderColor.withValues(alpha: 0.3)),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: effectiveBorderColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ]
            : null,
      );
    }
    return BoxDecoration(
      color: effectiveColor,
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      border: Border.all(color: effectiveBorderColor.withValues(alpha: 0.2)),
    );
  }

  // User message bubble color - Neon pink/purple gradient
  static const Color userBubbleLight = Color(0xFFBF00FF);
  static const Color userBubbleDark = Color(0xFF9900CC);

  // Assistant message bubble color - Dark with cyan accent
  static const Color assistantBubbleLight = Color(0xFF1A1A2E);
  static const Color assistantBubbleDark = Color(0xFF12121F);

  // Cyberpunk gradients - now dynamic based on primaryColor
  static LinearGradient get neonGradient => LinearGradient(
    colors: [secondaryAccent, primaryColor],
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
    if (isCyberpunk) {
      // Cyberpunk is always dark - redirect to dark theme
      return darkTheme;
    }
    // Classic light theme
    return _buildClassicLightTheme();
  }

  static ThemeData get darkTheme {
    if (isCyberpunk) {
      return _buildCyberpunkTheme();
    }
    // Classic dark theme
    return _buildClassicDarkTheme();
  }

  // CLASSIC THEME BUILDERS
  static ThemeData _buildClassicLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        surface: const Color(0xFFFAFAFA),
        surfaceContainer: const Color(0xFFF5F5F5),
        surfaceContainerLow: const Color(0xFFFAFAFA),
        surfaceContainerHigh: const Color(0xFFEFEFEF),
        onSurface: const Color(0xFF1A1A1A),
        onSurfaceVariant: const Color(0xFF424242),
        outline: const Color(0xFFE0E0E0),
        outlineVariant: const Color(0xFFF0F0F0),
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
        inverseSurface: const Color(0xFF121212),
        onInverseSurface: const Color(0xFFE0E0E0),
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE8E8E8),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: const Color(0xFF1A1A1A),
        displayColor: const Color(0xFF1A1A1A),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Color(0x1A000000),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Color(0x0F000000),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8E8E8),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData _buildClassicDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryLight,
        surface: const Color(0xFF1E293B),
        error: const Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardColor: const Color(0xFF1E293B),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: const Color(0xFFF1F5F9),
        displayColor: const Color(0xFFF1F5F9),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF1F5F9),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade800, thickness: 1),
    );
  }

  // CYBERPUNK THEME BUILDER
  static ThemeData _buildCyberpunkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryAccent,
        tertiary: primaryLight,
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
          foregroundColor: secondaryAccent,
          side: BorderSide(color: secondaryAccent, width: 2),
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
        foregroundColor: secondaryAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: secondaryAccent, width: 2),
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
