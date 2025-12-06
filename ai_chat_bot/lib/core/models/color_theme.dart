import 'package:flutter/material.dart';

/// Represents a color theme option for the app
class ColorThemeOption {
  final String id;
  final String name;
  final Color primaryColor;
  final Color primaryDark;
  final Color primaryLight;

  const ColorThemeOption({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.primaryDark,
    required this.primaryLight,
  });
}

/// All available color themes
class ColorThemes {
  static const List<ColorThemeOption> all = [
    // Default - Cyan Neon
    ColorThemeOption(
      id: 'cyan',
      name: 'Cyan Neon',
      primaryColor: Color(0xFF00FFFF),
      primaryDark: Color(0xFF00C4C4),
      primaryLight: Color(0xFF7DFFFF),
    ),
    // Alternative 1: Purple/Magenta Neon
    ColorThemeOption(
      id: 'magenta',
      name: 'Magenta Neon',
      primaryColor: Color(0xFFFF00FF),
      primaryDark: Color(0xFFB800B8),
      primaryLight: Color(0xFFFF7DFF),
    ),
    // Alternative 2: Green Matrix
    ColorThemeOption(
      id: 'matrix_green',
      name: 'Matrix Green',
      primaryColor: Color(0xFF00FF41),
      primaryDark: Color(0xFF00C432),
      primaryLight: Color(0xFF7DFF9D),
    ),
    // Alternative 3: Hot Pink/Electric
    ColorThemeOption(
      id: 'hot_pink',
      name: 'Hot Pink',
      primaryColor: Color(0xFFFF0080),
      primaryDark: Color(0xFFC4005E),
      primaryLight: Color(0xFFFF7DB8),
    ),
    // Alternative 4: Orange/Amber Glow
    ColorThemeOption(
      id: 'neon_orange',
      name: 'Neon Orange',
      primaryColor: Color(0xFFFF9500),
      primaryDark: Color(0xFFC47300),
      primaryLight: Color(0xFFFFBD5D),
    ),
    // Alternative 5: Electric Blue
    ColorThemeOption(
      id: 'electric_blue',
      name: 'Electric Blue',
      primaryColor: Color(0xFF0080FF),
      primaryDark: Color(0xFF0060C4),
      primaryLight: Color(0xFF7DB8FF),
    ),
    // Alternative 6: Acid Yellow
    ColorThemeOption(
      id: 'acid_yellow',
      name: 'Acid Yellow',
      primaryColor: Color(0xFFCCFF00),
      primaryDark: Color(0xFF9DC400),
      primaryLight: Color(0xFFE0FF5D),
    ),
    // Alternative 7: Red/Crimson Neon
    ColorThemeOption(
      id: 'neon_red',
      name: 'Neon Red',
      primaryColor: Color(0xFFFF0040),
      primaryDark: Color(0xFFC40030),
      primaryLight: Color(0xFFFF7D9D),
    ),
    // Alternative 8: Teal/Turquoise
    ColorThemeOption(
      id: 'neon_teal',
      name: 'Neon Teal',
      primaryColor: Color(0xFF00FFB8),
      primaryDark: Color(0xFF00C48E),
      primaryLight: Color(0xFF7DFFD8),
    ),
    // Alternative 9: Violet/Purple Deep
    ColorThemeOption(
      id: 'deep_violet',
      name: 'Deep Violet',
      primaryColor: Color(0xFF8000FF),
      primaryDark: Color(0xFF6000C4),
      primaryLight: Color(0xFFB87DFF),
    ),
    // Alternative 10: Lime/Chartreuse
    ColorThemeOption(
      id: 'lime_neon',
      name: 'Lime Neon',
      primaryColor: Color(0xFF80FF00),
      primaryDark: Color(0xFF60C400),
      primaryLight: Color(0xFFB8FF7D),
    ),
  ];

  /// Get a color theme by ID, defaults to electric_blue if not found
  static ColorThemeOption getById(String id) {
    return all.firstWhere(
      (theme) => theme.id == id,
      orElse: () => all[5], // Default to Electric Blue
    );
  }

  /// Default color theme
  static ColorThemeOption get defaultTheme => all[5]; // Electric Blue
}
