import 'package:flutter/material.dart';
import '../base/app_theme_base.dart';
import '../base/app_color_scheme.dart';
import '../base/app_typography.dart';
import '../base/app_spacing.dart';
import '../base/app_border_radius.dart';
import '../base/app_shadows.dart';
import '../base/app_component_themes.dart';

/// Light theme implementation
class LightTheme extends AppThemeBase {
  @override
  String get id => 'light';

  @override
  String get name => 'Light';

  @override
  String get description => 'Clean and bright theme with light colors';

  @override
  ThemeCategory get category => ThemeCategory.modern;

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFF6366F1), // Indigo
    primaryVariant: Color(0xFF4F46E5),
    onPrimary: Colors.white,
    secondary: Color(0xFF8B5CF6), // Purple
    secondaryVariant: Color(0xFF7C3AED),
    onSecondary: Colors.white,
    background: Color(0xFFFAFAFA),
    surface: Colors.white,
    onBackground: Color(0xFF111827), // Darker text for better contrast
    onSurface: Color(0xFF111827), // Darker text for better contrast
    error: Color(0xFFEF4444),
    onError: Colors.white,
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    surfaceVariant: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFF4B5563), // Darker for better readability
    outline: Color(0xFFD1D5DB),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF374151),
    onInverseSurface: Color(0xFFF9FAFB),
    inversePrimary: Color(0xFF818CF8),
    userMessageBackground: Color(0xFF6366F1),
    assistantMessageBackground: Color(0xFFF3F4F6),
    inputBackground: Colors.white,
    sidebarBackground: Color(0xFFFAFAFA),
  );

  @override
  AppTypography get typography =>
      AppTypography.defaultTypography(textColor: const Color(0xFF1F2937));

  @override
  AppSpacing get spacing => AppSpacing.defaultSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.defaultRadius();

  @override
  AppShadows get shadows =>
      AppShadows.defaultShadows(shadowColor: const Color(0xFF000000));

  @override
  AppComponentThemes get components => AppComponentThemes.defaultComponents(
    colorScheme: colorScheme.toColorScheme(brightness: Brightness.light),
    textTheme: typography.toTextTheme(),
  );

  @override
  ThemeData toThemeData() {
    final flutterColorScheme = colorScheme.toColorScheme(
      brightness: Brightness.light,
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
    );
  }

  @override
  ThemeData toDarkThemeData() {
    // For light theme, return the same theme data
    // Dark variant would be handled by DarkTheme class
    return toThemeData();
  }

  @override
  bool get supportsDarkMode => false;
}
