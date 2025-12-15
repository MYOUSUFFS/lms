import 'package:flutter/material.dart';
import '../base/app_theme_base.dart';
import '../base/app_color_scheme.dart';
import '../base/app_typography.dart';
import '../base/app_spacing.dart';
import '../base/app_border_radius.dart';
import '../base/app_shadows.dart';
import '../base/app_component_themes.dart';

/// Notion-style light theme implementation
class NotionLightTheme extends AppThemeBase {
  @override
  String get id => 'notion_light';

  @override
  String get name => 'Notion Light';

  @override
  String get description => 'Clean, minimalist theme inspired by Notion';

  @override
  ThemeCategory get category => ThemeCategory.notion;

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFF2D2D2D), // Notion's dark gray
    primaryVariant: Color(0xFF1A1A1A),
    onPrimary: Colors.white,
    secondary: Color(0xFF787774), // Notion's medium gray
    secondaryVariant: Color(0xFF9B9A97),
    onSecondary: Colors.white,
    background: Colors.white, // Pure white background
    surface: Colors.white,
    onBackground: Color(0xFF37352F), // Notion's text color
    onSurface: Color(0xFF37352F),
    error: Color(0xFFEB5757),
    onError: Colors.white,
    success: Color(0xFF219653),
    warning: Color(0xFFF2C94C),
    info: Color(0xFF2F80ED),
    surfaceVariant: Color(0xFFF7F6F3), // Notion's light gray
    onSurfaceVariant: Color(0xFF787774),
    outline: Color(0xFFE9E9E7), // Notion's border color
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF37352F),
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFF787774),
    userMessageBackground: Color(0xFF2D2D2D),
    assistantMessageBackground: Color(0xFFF7F6F3),
    inputBackground: Colors.white,
    sidebarBackground: Color(0xFFFBFBFA), // Notion's sidebar color
  );

  @override
  AppTypography get typography =>
      AppTypography.notionTypography(textColor: const Color(0xFF37352F));

  @override
  AppSpacing get spacing => AppSpacing.notionSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.notionRadius();

  @override
  AppShadows get shadows =>
      AppShadows.notionShadows(shadowColor: const Color(0xFF000000));

  @override
  AppComponentThemes get components => AppComponentThemes.notionComponents(
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
      appBarTheme: components.appBar.copyWith(
        backgroundColor: const Color(0xFFFBFBFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
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
      scaffoldBackgroundColor: Colors.white,
    );
  }

  @override
  ThemeData toDarkThemeData() {
    // Return the companion dark theme
    return NotionDarkTheme().toThemeData();
  }

  @override
  bool get supportsDarkMode => true;
}

/// Notion-style dark theme implementation
class NotionDarkTheme extends AppThemeBase {
  @override
  String get id => 'notion_dark';

  @override
  String get name => 'Notion Dark';

  @override
  String get description => 'Dark minimalist theme inspired by Notion';

  @override
  ThemeCategory get category => ThemeCategory.notion;

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFFFFFFFF), // White text on dark
    primaryVariant: Color(0xFFE6E6E6),
    onPrimary: Color(0xFF191919),
    secondary: Color(0xFF9B9A97), // Notion's medium gray
    secondaryVariant: Color(0xFFAEADAA),
    onSecondary: Color(0xFF191919),
    background: Color(0xFF191919), // Notion's dark background
    surface: Color(0xFF2F2F2F), // Notion's dark surface
    onBackground: Color(0xFFE9E9E7), // Light text
    onSurface: Color(0xFFE9E9E7),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF191919),
    success: Color(0xFF51CF66),
    warning: Color(0xFFFFD43B),
    info: Color(0xFF74C0FC),
    surfaceVariant: Color(0xFF373737), // Darker surface variant
    onSurfaceVariant: Color(0xFFAEADAA),
    outline: Color(0xFF454545), // Notion's dark border
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFFE9E9E7),
    onInverseSurface: Color(0xFF191919),
    inversePrimary: Color(0xFF2D2D2D),
    userMessageBackground: Color(0xFFFFFFFF),
    assistantMessageBackground: Color(0xFF373737),
    inputBackground: Color(0xFF2F2F2F),
    sidebarBackground: Color(0xFF1F1F1F), // Darker sidebar
  );

  @override
  AppTypography get typography =>
      AppTypography.notionTypography(textColor: const Color(0xFFE9E9E7));

  @override
  AppSpacing get spacing => AppSpacing.notionSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.notionRadius();

  @override
  AppShadows get shadows =>
      AppShadows.notionShadows(shadowColor: const Color(0xFF000000));

  @override
  AppComponentThemes get components => AppComponentThemes.notionComponents(
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
        backgroundColor: const Color(0xFF1F1F1F),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      cardTheme: components.card.copyWith(color: const Color(0xFF2F2F2F)),
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
      scaffoldBackgroundColor: const Color(0xFF191919),
    );
  }

  @override
  ThemeData toDarkThemeData() {
    return toThemeData();
  }

  @override
  bool get supportsDarkMode => true;
}
