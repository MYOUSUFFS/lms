import 'package:flutter/material.dart';
import '../base/app_theme_base.dart';
import '../base/app_color_scheme.dart';
import '../base/app_typography.dart';
import '../base/app_spacing.dart';
import '../base/app_border_radius.dart';
import '../base/app_shadows.dart';
import '../base/app_component_themes.dart';

/// Cyberpunk-style neon theme implementation
class CyberpunkNeonTheme extends AppThemeBase {
  @override
  String get id => 'cyberpunk_neon';

  @override
  String get name => 'Cyberpunk Neon';

  @override
  String get description =>
      'Futuristic neon-styled interface with glowing accents';

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
  AppTypography get typography =>
      AppTypography.defaultTypography(textColor: const Color(0xFFE0E0E0));

  @override
  AppSpacing get spacing => AppSpacing.defaultSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.sharpRadius();

  @override
  AppShadows get shadows =>
      AppShadows.dramaticShadows(shadowColor: const Color(0xFF00FFFF));

  @override
  AppComponentThemes get components => AppComponentThemes.defaultComponents(
    colorScheme: colorScheme.toColorScheme(brightness: Brightness.dark),
    textTheme: typography.toTextTheme(),
  );

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
      appBarTheme: components.appBar.copyWith(
        backgroundColor: const Color(0xFF0F0F0F),
        foregroundColor: const Color(0xFF00FFFF),
      ),
      cardTheme: components.card.copyWith(
        color: const Color(0xFF1A1A1A),
        shadowColor: const Color(0xFF00FFFF),
      ),
      inputDecorationTheme: components.inputDecoration.copyWith(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 2),
        ),
      ),
      dialogTheme: components.dialog,
      bottomSheetTheme: components.bottomSheet,
      tooltipTheme: components.tooltip,
      chipTheme: components.chip,
      floatingActionButtonTheme: components.fab,
      navigationBarTheme: components.navigationBar,
      listTileTheme: components.listTile,
      dividerTheme: components.divider,
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    );
  }

  @override
  ThemeData toDarkThemeData() {
    return toThemeData();
  }

  @override
  bool get supportsDarkMode => true;
}

/// Matrix-style green cyberpunk theme
class MatrixTheme extends AppThemeBase {
  @override
  String get id => 'matrix_green';

  @override
  String get name => 'Matrix Green';

  @override
  String get description =>
      'Digital rain aesthetic with green monochrome styling';

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
  AppTypography get typography =>
      AppTypography.defaultTypography(textColor: const Color(0xFF00FF41));

  @override
  AppSpacing get spacing => AppSpacing.defaultSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.sharpRadius();

  @override
  AppShadows get shadows =>
      AppShadows.dramaticShadows(shadowColor: const Color(0xFF00FF41));

  @override
  AppComponentThemes get components => AppComponentThemes.defaultComponents(
    colorScheme: colorScheme.toColorScheme(brightness: Brightness.dark),
    textTheme: typography.toTextTheme(),
  );

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
      appBarTheme: components.appBar.copyWith(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: const Color(0xFF00FF41),
      ),
      cardTheme: components.card.copyWith(
        color: const Color(0xFF0A1A0A),
        shadowColor: const Color(0xFF00FF41),
      ),
      inputDecorationTheme: components.inputDecoration.copyWith(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF00FF41), width: 2),
        ),
      ),
      dialogTheme: components.dialog,
      bottomSheetTheme: components.bottomSheet,
      tooltipTheme: components.tooltip,
      chipTheme: components.chip,
      floatingActionButtonTheme: components.fab,
      navigationBarTheme: components.navigationBar,
      listTileTheme: components.listTile,
      dividerTheme: components.divider,
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
    );
  }

  @override
  ThemeData toDarkThemeData() {
    return toThemeData();
  }

  @override
  bool get supportsDarkMode => true;
}
