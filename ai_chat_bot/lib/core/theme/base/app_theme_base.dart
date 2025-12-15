import 'package:flutter/material.dart';
import 'app_color_scheme.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_border_radius.dart';
import 'app_shadows.dart';
import 'app_component_themes.dart';

/// Base abstract class for all app themes
abstract class AppThemeBase {
  /// Theme metadata
  String get id;
  String get name;
  String get description;

  /// Color scheme for this theme
  AppColorScheme get colorScheme;

  /// Typography settings
  AppTypography get typography;

  /// Spacing constants
  AppSpacing get spacing;

  /// Border radius values
  AppBorderRadius get borderRadius;

  /// Shadow definitions
  AppShadows get shadows;

  /// Component-specific styling
  AppComponentThemes get components;

  /// Convert to Flutter ThemeData for light mode
  ThemeData toThemeData();

  /// Convert to Flutter ThemeData for dark mode
  ThemeData toDarkThemeData();

  /// Whether this theme supports dark mode
  bool get supportsDarkMode => true;

  /// Theme category for organization
  ThemeCategory get category;
}

/// Categories for organizing themes
enum ThemeCategory { modern, classic, cyberpunk, notion, custom, accessibility }

extension ThemeCategoryExtension on ThemeCategory {
  String get displayName {
    switch (this) {
      case ThemeCategory.modern:
        return 'Modern';
      case ThemeCategory.classic:
        return 'Classic';
      case ThemeCategory.cyberpunk:
        return 'Cyberpunk';
      case ThemeCategory.notion:
        return 'Notion-style';
      case ThemeCategory.custom:
        return 'Custom';
      case ThemeCategory.accessibility:
        return 'Accessibility';
    }
  }

  String get description {
    switch (this) {
      case ThemeCategory.modern:
        return 'Clean, contemporary designs';
      case ThemeCategory.classic:
        return 'Timeless Material Design';
      case ThemeCategory.cyberpunk:
        return 'Futuristic neon aesthetics';
      case ThemeCategory.notion:
        return 'Minimalist productivity-focused';
      case ThemeCategory.custom:
        return 'User-defined themes';
      case ThemeCategory.accessibility:
        return 'High contrast and accessible';
    }
  }
}
