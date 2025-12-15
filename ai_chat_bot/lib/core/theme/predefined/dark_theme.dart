import 'package:flutter/material.dart';
import '../base/app_theme_base.dart';
import '../base/app_color_scheme.dart';
import '../base/app_typography.dart';
import '../base/app_spacing.dart';
import '../base/app_border_radius.dart';
import '../base/app_shadows.dart';
import '../base/app_component_themes.dart';

/// Dark theme implementation
class DarkTheme extends AppThemeBase {
  @override
  String get id => 'dark';

  @override
  String get name => 'Dark';

  @override
  String get description => 'Elegant dark theme with deep colors';

  @override
  ThemeCategory get category => ThemeCategory.modern;

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFF818CF8), // Lighter indigo for dark mode
    primaryVariant: Color(0xFF6366F1),
    onPrimary: Color(0xFF1E1B4B),
    secondary: Color(0xFFA78BFA), // Lighter purple
    secondaryVariant: Color(0xFF8B5CF6),
    onSecondary: Color(0xFF2D1B69),
    background: Color(0xFF0F172A), // Very dark blue-gray
    surface: Color(0xFF1E293B), // Dark blue-gray
    onBackground: Color(0xFFE2E8F0), // Better contrast for text
    onSurface: Color(0xFFE2E8F0), // Better contrast for text
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    surfaceVariant: Color(0xFF334155),
    onSurfaceVariant: Color(0xFFCBD5E1),
    outline: Color(0xFF475569),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFFF1F5F9),
    onInverseSurface: Color(0xFF1E293B),
    inversePrimary: Color(0xFF4338CA),
    userMessageBackground: Color(0xFF6366F1),
    assistantMessageBackground: Color(0xFF334155),
    inputBackground: Color(0xFF1E293B),
    sidebarBackground: Color(0xFF0F172A),
  );

  @override
  AppTypography get typography =>
      AppTypography.defaultTypography(textColor: const Color(0xFFF8FAFC));

  @override
  AppSpacing get spacing => AppSpacing.defaultSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.defaultRadius();

  @override
  AppShadows get shadows =>
      AppShadows.defaultShadows(shadowColor: const Color(0xFF000000));

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
      fontFamily: 'Inter',
      brightness: Brightness.dark,
    );
  }

  @override
  ThemeData toDarkThemeData() {
    return toThemeData();
  }

  @override
  bool get supportsDarkMode => true;
}
