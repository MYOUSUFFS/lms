import 'package:flutter/material.dart';
import '../base/app_theme_base.dart';
import '../base/app_color_scheme.dart';
import '../base/app_typography.dart';
import '../base/app_spacing.dart';
import '../base/app_border_radius.dart';
import '../base/app_shadows.dart';
import '../base/app_component_themes.dart';

/// Neo-Brutalism theme with bold, geometric design
class NeoBrutalismTheme extends AppThemeBase {
  @override
  String get id => 'neo_brutalism';

  @override
  String get name => 'Neo-Brutalism';

  @override
  String get description =>
      'Bold, geometric design with strong contrasts and sharp edges';

  @override
  ThemeCategory get category => ThemeCategory.modern;

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFF000000), // Pure black
    primaryVariant: Color(0xFF1A1A1A),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFFF6B35), // Bold orange
    secondaryVariant: Color(0xFFE55A2B),
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFFFFFBEB), // Cream white
    surface: Color(0xFFFFFFFF), // Pure white
    onBackground: Color(0xFF000000),
    onSurface: Color(0xFF000000),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    success: Color(0xFF16A34A),
    warning: Color(0xFFCA8A04),
    info: Color(0xFF2563EB),
    surfaceVariant: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFF000000),
    outline: Color(0xFF000000),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF000000),
    onInverseSurface: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFFFFFFFF),
    userMessageBackground: Color(0xFF000000),
    assistantMessageBackground: Color(0xFFF3F4F6),
    inputBackground: Color(0xFFFFFFFF),
    sidebarBackground: Color(0xFFFFFFFF),
  );

  @override
  AppTypography get typography => _createNeoBrutalismTypography();

  AppTypography _createNeoBrutalismTypography() {
    return AppTypography(
      displayLarge: _neoBrutalismTextStyle(57, FontWeight.w900, -0.25),
      displayMedium: _neoBrutalismTextStyle(45, FontWeight.w900),
      displaySmall: _neoBrutalismTextStyle(36, FontWeight.w900),
      headlineLarge: _neoBrutalismTextStyle(32, FontWeight.w900),
      headlineMedium: _neoBrutalismTextStyle(28, FontWeight.w900),
      headlineSmall: _neoBrutalismTextStyle(24, FontWeight.w900),
      titleLarge: _neoBrutalismTextStyle(22, FontWeight.w800),
      titleMedium: _neoBrutalismTextStyle(16, FontWeight.w800, 0.15),
      titleSmall: _neoBrutalismTextStyle(14, FontWeight.w800, 0.1),
      labelLarge: _neoBrutalismTextStyle(14, FontWeight.w800, 0.1),
      labelMedium: _neoBrutalismTextStyle(12, FontWeight.w800, 0.5),
      labelSmall: _neoBrutalismTextStyle(11, FontWeight.w800, 0.5),
      bodyLarge: _neoBrutalismTextStyle(16, FontWeight.w700, 0.5),
      bodyMedium: _neoBrutalismTextStyle(14, FontWeight.w600, 0.25),
      bodySmall: _neoBrutalismTextStyle(12, FontWeight.w600, 0.4),
      chatMessage: _neoBrutalismTextStyle(14, FontWeight.w600, 0.25, 1.5),
      chatTimestamp: _neoBrutalismTextStyle(
        11,
        FontWeight.w600,
        0.4,
      ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
      chatUsername: _neoBrutalismTextStyle(12, FontWeight.w800, 0.25),
      codeBlock: _neoBrutalismCodeStyle(),
    );
  }

  TextStyle _neoBrutalismTextStyle(
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
      fontFamily: 'Inter', // Keep Inter but with bold weights
    );
  }

  TextStyle _neoBrutalismCodeStyle() {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
      color: colorScheme.onSurface,
      fontFamily: 'monospace',
    );
  }

  @override
  AppSpacing get spacing => AppSpacing.defaultSpacing();

  @override
  AppBorderRadius get borderRadius => AppBorderRadius.sharpRadius(); // Sharp edges

  @override
  AppShadows get shadows => _createNeoBrutalismShadows();

  AppShadows _createNeoBrutalismShadows() {
    return AppShadows(
      none: [],
      sm: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(4, 4),
          blurRadius: 0, // No blur for sharp shadows
          spreadRadius: 0,
        ),
      ],
      md: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(6, 6),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      lg: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(8, 8),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      xl: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(12, 12),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      xxl: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(16, 16),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      button: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      card: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(6, 6),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      dialog: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(8, 8),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      bottomSheet: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(6, 6),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      tooltip: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      floating: [
        BoxShadow(
          color: colorScheme.shadow,
          offset: const Offset(8, 8),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    );
  }

  @override
  AppComponentThemes get components => _createNeoBrutalismComponents();

  AppComponentThemes _createNeoBrutalismComponents() {
    final textTheme = typography.toTextTheme();

    return AppComponentThemes(
      button: const ButtonThemeData(),
      card: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // No border radius
          side: BorderSide(
            color: colorScheme.outline,
            width: 3, // Thick border
          ),
        ),
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow,
      ),
      appBar: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: colorScheme.outline, width: 3)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: colorScheme.onSurface,
        ),
      ),
      inputDecoration: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: colorScheme.outline, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: colorScheme.outline, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: colorScheme.primary, width: 4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: colorScheme.error, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
      dialog: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: colorScheme.outline, width: 3),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheet: BottomSheetThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: colorScheme.outline, width: 3),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      tooltip: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: colorScheme.outline, width: 2),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      chip: ChipThemeData(
        backgroundColor: colorScheme.surface,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: colorScheme.outline, width: 2),
        ),
        side: BorderSide(color: colorScheme.outline, width: 2),
      ),
      fab: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: colorScheme.outline, width: 3),
        ),
      ),
      navigationBar: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondary.withValues(alpha: 0.2),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      listTile: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      divider: DividerThemeData(
        color: colorScheme.outline,
        thickness: 3,
        space: 3,
      ),
    );
  }

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
      brightness: Brightness.light,
      scaffoldBackgroundColor: colorScheme.background,
      // Custom elevated button theme for brutalist style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              shadowColor: colorScheme.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: BorderSide(color: colorScheme.outline, width: 3),
              ),
              textStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ).copyWith(
              // Custom shadow for pressed state
              overlayColor: MaterialStateProperty.all(
                colorScheme.onPrimary.withValues(alpha: 0.1),
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline, width: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  ThemeData toDarkThemeData() {
    // For brutalism, we'll create a dark variant
    final darkColorScheme = colorScheme.copyWith(
      background: const Color(0xFF1A1A1A),
      surface: const Color(0xFF2D2D2D),
      onBackground: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFFFFFFFF),
      primary: const Color(0xFFFFFFFF),
      onPrimary: const Color(0xFF000000),
      surfaceVariant: const Color(0xFF404040),
      outline: const Color(0xFFFFFFFF),
      shadow: const Color(0xFFFFFFFF),
      inverseSurface: const Color(0xFFFFFFFF),
      onInverseSurface: const Color(0xFF000000),
    );

    final darkTheme = NeoBrutalismTheme();
    // Override the color scheme
    return darkTheme.toThemeData().copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkColorScheme.background,
      colorScheme: darkColorScheme.toColorScheme(brightness: Brightness.dark),
    );
  }

  @override
  bool get supportsDarkMode => true;
}

/// Dark variant of Neo-Brutalism theme
class NeoBrutalismDarkTheme extends NeoBrutalismTheme {
  @override
  String get id => 'neo_brutalism_dark';

  @override
  String get name => 'Neo-Brutalism Dark';

  @override
  String get description =>
      'Bold, geometric design with dark colors and strong contrasts';

  @override
  AppColorScheme get colorScheme => const AppColorScheme(
    primary: Color(0xFFFFFFFF), // Pure white on dark
    primaryVariant: Color(0xFFE5E5E5),
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFFFF6B35), // Same bold orange
    secondaryVariant: Color(0xFFE55A2B),
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFF1A1A1A), // Dark gray
    surface: Color(0xFF2D2D2D), // Lighter dark gray
    onBackground: Color(0xFFFFFFFF),
    onSurface: Color(0xFFFFFFFF),
    error: Color(0xFFFF4444),
    onError: Color(0xFF000000),
    success: Color(0xFF22C55E),
    warning: Color(0xFFFABF2A),
    info: Color(0xFF3B82F6),
    surfaceVariant: Color(0xFF404040),
    onSurfaceVariant: Color(0xFFFFFFFF),
    outline: Color(0xFFFFFFFF),
    shadow: Color(0xFFFFFFFF),
    inverseSurface: Color(0xFFFFFFFF),
    onInverseSurface: Color(0xFF000000),
    inversePrimary: Color(0xFF000000),
    userMessageBackground: Color(0xFFFFFFFF),
    assistantMessageBackground: Color(0xFF404040),
    inputBackground: Color(0xFF2D2D2D),
    sidebarBackground: Color(0xFF1A1A1A),
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
      scaffoldBackgroundColor: colorScheme.background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: colorScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide(color: colorScheme.outline, width: 3),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline, width: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  ThemeData toDarkThemeData() => toThemeData();
}
