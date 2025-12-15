import 'package:flutter/material.dart';
import '../base/app_theme_base.dart';
import '../base/app_color_scheme.dart';
import '../base/app_typography.dart';
import '../base/app_spacing.dart';
import '../base/app_border_radius.dart';
import '../base/app_shadows.dart';
import '../base/app_component_themes.dart';

/// High contrast accessibility theme for better readability
class HighContrastTheme extends AppThemeBase {
  @override
  String get id => 'high_contrast';

  @override
  String get name => 'High Contrast';

  @override
  String get description => 'High contrast theme for enhanced accessibility';

  @override
  ThemeCategory get category => ThemeCategory.accessibility;

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFF000000), // Pure black
    primaryVariant: Color(0xFF2A2A2A),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF333333), // Dark gray
    secondaryVariant: Color(0xFF555555),
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF), // Pure white
    surface: Color(0xFFFFFFFF),
    onBackground: Color(0xFF000000),
    onSurface: Color(0xFF000000),
    error: Color(0xFFCC0000), // Dark red
    onError: Color(0xFFFFFFFF),
    success: Color(0xFF006600), // Dark green
    warning: Color(0xFF996600), // Dark orange
    info: Color(0xFF0066CC), // Dark blue
    surfaceVariant: Color(0xFFF0F0F0), // Very light gray
    onSurfaceVariant: Color(0xFF000000),
    outline: Color(0xFF000000),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF000000),
    onInverseSurface: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFFFFFFFF),
    userMessageBackground: Color(0xFF000000),
    assistantMessageBackground: Color(0xFFF0F0F0),
    inputBackground: Color(0xFFFFFFFF),
    sidebarBackground: Color(0xFFFAFAFA),
  );

  @override
  AppTypography get typography =>
      AppTypography.defaultTypography(textColor: const Color(0xFF000000));

  @override
  AppSpacing get spacing => AppSpacing.notionSpacing(); // More generous spacing

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.sharpRadius(); // Less rounding for clarity

  @override
  AppShadows get shadows => AppShadows.flatShadows(); // No shadows for simplicity

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
    final textTheme = typography.toTextTheme().apply(
      bodyColor: const Color(0xFF000000),
      displayColor: const Color(0xFF000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: flutterColorScheme,
      textTheme: textTheme,
      appBarTheme: components.appBar.copyWith(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
        elevation: 2, // Clear elevation
      ),
      cardTheme: components.card.copyWith(
        color: const Color(0xFFFFFFFF),
        elevation: 4, // Clear elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(
            color: Color(0xFF000000),
            width: 2, // Strong border
          ),
        ),
      ),
      inputDecorationTheme: components.inputDecoration.copyWith(
        fillColor: const Color(0xFFFFFFFF),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF000000), width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF000000), width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF000000), width: 3),
        ),
      ),
      dialogTheme: components.dialog.copyWith(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF000000), width: 2),
        ),
      ),
      bottomSheetTheme: components.bottomSheet,
      tooltipTheme: components.tooltip,
      chipTheme: components.chip.copyWith(
        backgroundColor: const Color(0xFFF0F0F0),
        side: const BorderSide(color: Color(0xFF000000)),
      ),
      floatingActionButtonTheme: components.fab.copyWith(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: const Color(0xFFFFFFFF),
      ),
      navigationBarTheme: components.navigationBar,
      listTileTheme: components.listTile,
      dividerTheme: components.divider.copyWith(
        color: const Color(0xFF000000),
        thickness: 2,
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    );
  }

  @override
  ThemeData toDarkThemeData() {
    // Create high contrast dark version
    return _createHighContrastDark();
  }

  ThemeData _createHighContrastDark() {
    final darkColorScheme = colorScheme.copyWith(
      primary: const Color(0xFFFFFFFF), // White on dark
      onPrimary: const Color(0xFF000000),
      secondary: const Color(0xFFCCCCCC),
      onSecondary: const Color(0xFF000000),
      background: const Color(0xFF000000), // Pure black
      surface: const Color(0xFF000000),
      onBackground: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFFFFFFFF),
      surfaceVariant: const Color(0xFF2A2A2A),
      onSurfaceVariant: const Color(0xFFFFFFFF),
      outline: const Color(0xFFFFFFFF),
      inverseSurface: const Color(0xFFFFFFFF),
      onInverseSurface: const Color(0xFF000000),
      inversePrimary: const Color(0xFF000000),
      userMessageBackground: const Color(0xFFFFFFFF),
      assistantMessageBackground: const Color(0xFF2A2A2A),
      inputBackground: const Color(0xFF000000),
      sidebarBackground: const Color(0xFF111111),
    );

    final darkTextTheme = typography.toTextTheme().apply(
      bodyColor: const Color(0xFFFFFFFF),
      displayColor: const Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme.toColorScheme(brightness: Brightness.dark),
      textTheme: darkTextTheme,
      appBarTheme: components.appBar.copyWith(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
      ),
      cardTheme: components.card.copyWith(
        color: const Color(0xFF000000),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFFFFFFF), width: 2),
        ),
      ),
      inputDecorationTheme: components.inputDecoration.copyWith(
        fillColor: const Color(0xFF000000),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 3),
        ),
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      fontFamily: 'Inter',
    );
  }

  @override
  bool get supportsDarkMode => true;
}
