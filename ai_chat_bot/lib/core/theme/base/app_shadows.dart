import 'package:flutter/material.dart';

/// Shadow definitions for consistent elevation and depth
class AppShadows {
  final List<BoxShadow> none;
  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;
  final List<BoxShadow> xl;
  final List<BoxShadow> xxl;

  // Component-specific shadows
  final List<BoxShadow> button;
  final List<BoxShadow> card;
  final List<BoxShadow> dialog;
  final List<BoxShadow> bottomSheet;
  final List<BoxShadow> tooltip;
  final List<BoxShadow> floating;

  const AppShadows({
    required this.none,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.button,
    required this.card,
    required this.dialog,
    required this.bottomSheet,
    required this.tooltip,
    required this.floating,
  });

  /// Default shadow system (Material Design inspired)
  factory AppShadows.defaultShadows({Color shadowColor = Colors.black}) {
    return AppShadows(
      none: [],
      sm: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 2.0,
          offset: const Offset(0, 1),
        ),
      ],
      md: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      lg: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          blurRadius: 16.0,
          offset: const Offset(0, 8),
        ),
      ],
      xl: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 16.0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          blurRadius: 24.0,
          offset: const Offset(0, 12),
        ),
      ],
      xxl: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.15),
          blurRadius: 24.0,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 48.0,
          offset: const Offset(0, 24),
        ),
      ],
      button: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 2.0,
          offset: const Offset(0, 1),
        ),
      ],
      card: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.08),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.04),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      dialog: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.15),
          blurRadius: 16.0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 24.0,
          offset: const Offset(0, 12),
        ),
      ],
      bottomSheet: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 8.0,
          offset: const Offset(0, -2),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          blurRadius: 16.0,
          offset: const Offset(0, -4),
        ),
      ],
      tooltip: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.15),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
      ],
      floating: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.15),
          blurRadius: 12.0,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 24.0,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  /// Notion-style shadows (very subtle)
  factory AppShadows.notionShadows({Color shadowColor = Colors.black}) {
    return AppShadows(
      none: [],
      sm: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.04),
          blurRadius: 1.0,
          offset: const Offset(0, 1),
        ),
      ],
      md: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          blurRadius: 2.0,
          offset: const Offset(0, 1),
        ),
      ],
      lg: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.08),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
      ],
      xl: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      xxl: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.12),
          blurRadius: 16.0,
          offset: const Offset(0, 8),
        ),
      ],
      button: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.04),
          blurRadius: 1.0,
          offset: const Offset(0, 1),
        ),
      ],
      card: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          blurRadius: 2.0,
          offset: const Offset(0, 1),
        ),
      ],
      dialog: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      bottomSheet: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.08),
          blurRadius: 4.0,
          offset: const Offset(0, -2),
        ),
      ],
      tooltip: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 2.0,
          offset: const Offset(0, 1),
        ),
      ],
      floating: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// No shadows (flat design)
  factory AppShadows.flatShadows() {
    return const AppShadows(
      none: [],
      sm: [],
      md: [],
      lg: [],
      xl: [],
      xxl: [],
      button: [],
      card: [],
      dialog: [],
      bottomSheet: [],
      tooltip: [],
      floating: [],
    );
  }

  /// Dramatic shadows (high contrast)
  factory AppShadows.dramaticShadows({Color shadowColor = Colors.black}) {
    return AppShadows(
      none: [],
      sm: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.2),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
      ],
      md: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.2),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 16.0,
          offset: const Offset(0, 8),
        ),
      ],
      lg: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.25),
          blurRadius: 16.0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.15),
          blurRadius: 32.0,
          offset: const Offset(0, 16),
        ),
      ],
      xl: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.3),
          blurRadius: 24.0,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.2),
          blurRadius: 48.0,
          offset: const Offset(0, 24),
        ),
      ],
      xxl: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.35),
          blurRadius: 32.0,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.25),
          blurRadius: 64.0,
          offset: const Offset(0, 32),
        ),
      ],
      button: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.2),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
      ],
      card: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.2),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 16.0,
          offset: const Offset(0, 8),
        ),
      ],
      dialog: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.3),
          blurRadius: 24.0,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.2),
          blurRadius: 48.0,
          offset: const Offset(0, 24),
        ),
      ],
      bottomSheet: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.2),
          blurRadius: 16.0,
          offset: const Offset(0, -4),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          blurRadius: 32.0,
          offset: const Offset(0, -8),
        ),
      ],
      tooltip: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.25),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      floating: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.25),
          blurRadius: 16.0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.15),
          blurRadius: 32.0,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }
}
