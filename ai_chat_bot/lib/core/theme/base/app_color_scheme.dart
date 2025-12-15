import 'package:flutter/material.dart';

/// Comprehensive color scheme for the app
class AppColorScheme {
  // Primary colors
  final Color primary;
  final Color primaryVariant;
  final Color onPrimary;

  // Secondary colors
  final Color secondary;
  final Color secondaryVariant;
  final Color onSecondary;

  // Background colors
  final Color background;
  final Color surface;
  final Color onBackground;
  final Color onSurface;

  // Error colors
  final Color error;
  final Color onError;

  // Additional semantic colors
  final Color success;
  final Color warning;
  final Color info;

  // Surface variations
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color shadow;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  // Chat-specific colors
  final Color userMessageBackground;
  final Color assistantMessageBackground;
  final Color inputBackground;
  final Color sidebarBackground;

  const AppColorScheme({
    required this.primary,
    required this.primaryVariant,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryVariant,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.onBackground,
    required this.onSurface,
    required this.error,
    required this.onError,
    required this.success,
    required this.warning,
    required this.info,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.shadow,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.userMessageBackground,
    required this.assistantMessageBackground,
    required this.inputBackground,
    required this.sidebarBackground,
  });

  /// Convert to Flutter ColorScheme
  ColorScheme toColorScheme({required Brightness brightness}) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      background: background,
      onBackground: onBackground,
      error: error,
      onError: onError,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      shadow: shadow,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
    );
  }

  /// Create a copy with different values
  AppColorScheme copyWith({
    Color? primary,
    Color? primaryVariant,
    Color? onPrimary,
    Color? secondary,
    Color? secondaryVariant,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? onBackground,
    Color? onSurface,
    Color? error,
    Color? onError,
    Color? success,
    Color? warning,
    Color? info,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? outline,
    Color? shadow,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
    Color? userMessageBackground,
    Color? assistantMessageBackground,
    Color? inputBackground,
    Color? sidebarBackground,
  }) {
    return AppColorScheme(
      primary: primary ?? this.primary,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      secondaryVariant: secondaryVariant ?? this.secondaryVariant,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      shadow: shadow ?? this.shadow,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      userMessageBackground:
          userMessageBackground ?? this.userMessageBackground,
      assistantMessageBackground:
          assistantMessageBackground ?? this.assistantMessageBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
    );
  }
}
