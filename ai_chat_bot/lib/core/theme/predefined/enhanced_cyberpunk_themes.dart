import 'package:flutter/material.dart';
import '../base/app_theme_base.dart';
import '../base/app_color_scheme.dart';
import '../base/app_typography.dart';
import '../base/app_spacing.dart';
import '../base/app_border_radius.dart';
import '../base/app_shadows.dart';
import '../base/app_component_themes.dart';
import '../widgets/enhanced_cyberpunk_widgets_fixed.dart';

/// Enhanced cyberpunk-style neon theme with special effects
class EnhancedCyberpunkNeonTheme extends AppThemeBase {
  @override
  String get id => 'cyberpunk_neon_enhanced';

  @override
  String get name => 'Cyberpunk Neon Enhanced';

  @override
  String get description =>
      'Ultimate futuristic neon interface with glowing effects';

  @override
  ThemeCategory get category => ThemeCategory.cyberpunk;

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFF00FFFF), // Cyan neon
    primaryVariant: Color(0xFF00C4C4),
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFFFF00FF), // Magenta neon
    secondaryVariant: Color(0xFFB800B8),
    onSecondary: Color(0xFF000000),
    background: Color(0xFF0A0A0A), // Very dark background
    surface: Color(0xFF1A1A1A), // Dark surface
    onBackground: Color(0xFF00FFFF),
    onSurface: Color(0xFFE0E0E0),
    error: Color(0xFFFF0040),
    onError: Color(0xFF000000),
    success: Color(0xFF00FF41),
    warning: Color(0xFFFF9500),
    info: Color(0xFF0080FF),
    surfaceVariant: Color(0xFF2A2A2A),
    onSurfaceVariant: Color(0xFFB0B0B0),
    outline: Color(0xFF00FFFF),
    shadow: Color(0xFF00FFFF),
    inverseSurface: Color(0xFF00FFFF),
    onInverseSurface: Color(0xFF000000),
    inversePrimary: Color(0xFF0A0A0A),
    userMessageBackground: Color(0xFF00FFFF),
    assistantMessageBackground: Color(0xFF2A2A2A),
    inputBackground: Color(0xFF1A1A1A),
    sidebarBackground: Color(0xFF0F0F0F),
  );

  @override
  AppTypography get typography => _createCyberpunkTypography();

  AppTypography _createCyberpunkTypography() {
    return AppTypography(
      displayLarge: _cyberpunkTextStyle(57, FontWeight.w400, -0.25),
      displayMedium: _cyberpunkTextStyle(45, FontWeight.w400),
      displaySmall: _cyberpunkTextStyle(36, FontWeight.w400),
      headlineLarge: _cyberpunkTextStyle(32, FontWeight.w600),
      headlineMedium: _cyberpunkTextStyle(28, FontWeight.w600),
      headlineSmall: _cyberpunkTextStyle(24, FontWeight.w600),
      titleLarge: _cyberpunkTextStyle(22, FontWeight.w500),
      titleMedium: _cyberpunkTextStyle(16, FontWeight.w500, 0.15),
      titleSmall: _cyberpunkTextStyle(14, FontWeight.w500, 0.1),
      labelLarge: _cyberpunkTextStyle(14, FontWeight.w500, 0.1),
      labelMedium: _cyberpunkTextStyle(12, FontWeight.w500, 0.5),
      labelSmall: _cyberpunkTextStyle(11, FontWeight.w500, 0.5),
      bodyLarge: _cyberpunkTextStyle(16, FontWeight.w400, 0.5),
      bodyMedium: _cyberpunkTextStyle(14, FontWeight.w400, 0.25),
      bodySmall: _cyberpunkTextStyle(12, FontWeight.w400, 0.4),
      chatMessage: _cyberpunkTextStyle(14, FontWeight.w400, 0.25, 1.5),
      chatTimestamp: _cyberpunkTextStyle(
        11,
        FontWeight.w400,
        0.4,
      ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
      chatUsername: _cyberpunkTextStyle(12, FontWeight.w600, 0.25),
      codeBlock: _cyberpunkCodeStyle(),
    );
  }

  TextStyle _cyberpunkTextStyle(
    double fontSize,
    FontWeight fontWeight, [
    double letterSpacing = 0.0,
    double height = 1.0,
  ]) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height == 1.0 ? null : height,
      color: colorScheme.onSurface,
      fontFamily: 'monospace', // Changed to monospace for cyberpunk feel
      shadows: [
        Shadow(
          blurRadius: 2.0,
          color: colorScheme.primary.withValues(alpha: 0.3),
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  TextStyle _cyberpunkCodeStyle() {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      color: colorScheme.primary,
      fontFamily: 'monospace',
      shadows: [
        Shadow(
          blurRadius: 4.0,
          color: colorScheme.primary.withValues(alpha: 0.5),
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  @override
  AppSpacing get spacing => AppSpacing.defaultSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.sharpRadius();

  @override
  AppShadows get shadows =>
      AppShadows.dramaticShadows(shadowColor: colorScheme.primary);

  @override
  AppComponentThemes get components => _createCyberpunkComponents();

  AppComponentThemes _createCyberpunkComponents() {
    final textTheme = typography.toTextTheme();

    return AppComponentThemes(
      button: const ButtonThemeData(),
      card: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: colorScheme.primary, width: 1),
        ),
        color: colorScheme.surface,
        shadowColor: colorScheme.primary,
      ),
      appBar: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
          shadows: [
            Shadow(
              blurRadius: 4.0,
              color: colorScheme.primary.withValues(alpha: 0.5),
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
      inputDecoration: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      dialog: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: colorScheme.primary, width: 2),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheet: BottomSheetThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          side: BorderSide(color: colorScheme.primary),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      tooltip: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colorScheme.primary),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
      ),
      chip: ChipThemeData(
        backgroundColor: colorScheme.surface,
        labelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: colorScheme.primary),
        ),
        side: BorderSide(color: colorScheme.primary),
      ),
      fab: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      navigationBar: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      listTile: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      divider: DividerThemeData(
        color: colorScheme.primary.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),
    );
  }

  @override
  ThemeData toThemeData() {
    final flutterColorScheme = colorScheme.toColorScheme(
      brightness: Brightness.dark,
    );
    final textTheme = typography.toTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: flutterColorScheme,
      textTheme: textTheme,
      appBarTheme: components.appBar,
      cardTheme: components.card,
      inputDecorationTheme: components.inputDecoration,
      dialogTheme: components.dialog,
      bottomSheetTheme: components.bottomSheet,
      tooltipTheme: components.tooltip,
      chipTheme: components.chip,
      floatingActionButtonTheme: components.fab,
      navigationBarTheme: components.navigationBar,
      listTileTheme: components.listTile,
      dividerTheme: components.divider,
      fontFamily: 'monospace',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorScheme.background,
      // Enhanced cyberpunk visual effects
      extensions: [
        CyberpunkThemeExtension(
          glowColor: colorScheme.primary,
          scanlineOpacity: 0.1,
          enableGlow: true,
          enableScanlines: true,
        ),
      ],
    );
  }

  @override
  ThemeData toDarkThemeData() => toThemeData();

  @override
  bool get supportsDarkMode => true;
}

/// Enhanced Matrix-style green cyberpunk theme
class EnhancedMatrixTheme extends AppThemeBase {
  @override
  String get id => 'matrix_green_enhanced';

  @override
  String get name => 'Matrix Enhanced';

  @override
  String get description =>
      'Ultimate digital rain aesthetic with enhanced effects';

  @override
  ThemeCategory get category => ThemeCategory.cyberpunk;

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFF00FF41), // Matrix green
    primaryVariant: Color(0xFF00C432),
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFF7DFF9D), // Lighter green
    secondaryVariant: Color(0xFF4AFF6B),
    onSecondary: Color(0xFF000000),
    background: Color(0xFF000000), // Pure black
    surface: Color(0xFF0A1A0A), // Very dark green
    onBackground: Color(0xFF00FF41),
    onSurface: Color(0xFF90FF90),
    error: Color(0xFFFF0000),
    onError: Color(0xFF000000),
    success: Color(0xFF00FF41),
    warning: Color(0xFFFFFF00),
    info: Color(0xFF00FFFF),
    surfaceVariant: Color(0xFF1A2A1A),
    onSurfaceVariant: Color(0xFF70FF70),
    outline: Color(0xFF00FF41),
    shadow: Color(0xFF00FF41),
    inverseSurface: Color(0xFF00FF41),
    onInverseSurface: Color(0xFF000000),
    inversePrimary: Color(0xFF000000),
    userMessageBackground: Color(0xFF00FF41),
    assistantMessageBackground: Color(0xFF1A2A1A),
    inputBackground: Color(0xFF0A1A0A),
    sidebarBackground: Color(0xFF000000),
  );

  @override
  AppTypography get typography => _createMatrixTypography();

  AppTypography _createMatrixTypography() {
    return AppTypography(
      displayLarge: _matrixTextStyle(57, FontWeight.w400, -0.25),
      displayMedium: _matrixTextStyle(45, FontWeight.w400),
      displaySmall: _matrixTextStyle(36, FontWeight.w400),
      headlineLarge: _matrixTextStyle(32, FontWeight.w600),
      headlineMedium: _matrixTextStyle(28, FontWeight.w600),
      headlineSmall: _matrixTextStyle(24, FontWeight.w600),
      titleLarge: _matrixTextStyle(22, FontWeight.w500),
      titleMedium: _matrixTextStyle(16, FontWeight.w500, 0.15),
      titleSmall: _matrixTextStyle(14, FontWeight.w500, 0.1),
      labelLarge: _matrixTextStyle(14, FontWeight.w500, 0.1),
      labelMedium: _matrixTextStyle(12, FontWeight.w500, 0.5),
      labelSmall: _matrixTextStyle(11, FontWeight.w500, 0.5),
      bodyLarge: _matrixTextStyle(16, FontWeight.w400, 0.5),
      bodyMedium: _matrixTextStyle(14, FontWeight.w400, 0.25),
      bodySmall: _matrixTextStyle(12, FontWeight.w400, 0.4),
      chatMessage: _matrixTextStyle(14, FontWeight.w400, 0.25, 1.5),
      chatTimestamp: _matrixTextStyle(
        11,
        FontWeight.w400,
        0.4,
      ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
      chatUsername: _matrixTextStyle(12, FontWeight.w600, 0.25),
      codeBlock: _matrixCodeStyle(),
    );
  }

  TextStyle _matrixTextStyle(
    double fontSize,
    FontWeight fontWeight, [
    double letterSpacing = 0.0,
    double height = 1.0,
  ]) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height == 1.0 ? null : height,
      color: colorScheme.primary,
      fontFamily: 'monospace',
      shadows: [
        Shadow(
          blurRadius: 3.0,
          color: colorScheme.primary.withValues(alpha: 0.4),
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  TextStyle _matrixCodeStyle() {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      color: colorScheme.primary,
      fontFamily: 'monospace',
      shadows: [
        Shadow(
          blurRadius: 5.0,
          color: colorScheme.primary.withValues(alpha: 0.6),
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  @override
  AppSpacing get spacing => AppSpacing.defaultSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.sharpRadius();

  @override
  AppShadows get shadows =>
      AppShadows.dramaticShadows(shadowColor: colorScheme.primary);

  @override
  AppComponentThemes get components => _createMatrixComponents();

  AppComponentThemes _createMatrixComponents() {
    final textTheme = typography.toTextTheme();

    return AppComponentThemes(
      button: const ButtonThemeData(),
      card: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(color: colorScheme.primary, width: 1),
        ),
        color: colorScheme.surface,
      ),
      appBar: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
          fontFamily: 'monospace',
        ),
      ),
      inputDecoration: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      dialog: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(color: colorScheme.primary, width: 1),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheet: BottomSheetThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
          side: BorderSide(color: colorScheme.primary),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      tooltip: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: colorScheme.primary),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
      ),
      chip: ChipThemeData(
        backgroundColor: colorScheme.surface,
        labelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
      fab: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      navigationBar: NavigationBarThemeData(
        backgroundColor: colorScheme.background,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
      ),
      listTile: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        titleTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.primary,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.primary.withValues(alpha: 0.7),
        ),
      ),
      divider: DividerThemeData(
        color: colorScheme.primary.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),
    );
  }

  @override
  ThemeData toThemeData() {
    final flutterColorScheme = colorScheme.toColorScheme(
      brightness: Brightness.dark,
    );
    final textTheme = typography.toTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: flutterColorScheme,
      textTheme: textTheme,
      appBarTheme: components.appBar,
      cardTheme: components.card,
      inputDecorationTheme: components.inputDecoration,
      dialogTheme: components.dialog,
      bottomSheetTheme: components.bottomSheet,
      tooltipTheme: components.tooltip,
      chipTheme: components.chip,
      floatingActionButtonTheme: components.fab,
      navigationBarTheme: components.navigationBar,
      listTileTheme: components.listTile,
      dividerTheme: components.divider,
      fontFamily: 'monospace',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorScheme.background,
      extensions: [
        CyberpunkThemeExtension(
          glowColor: colorScheme.primary,
          scanlineOpacity: 0.15,
          enableGlow: true,
          enableScanlines: true,
        ),
      ],
    );
  }

  @override
  ThemeData toDarkThemeData() => toThemeData();

  @override
  bool get supportsDarkMode => true;
}
