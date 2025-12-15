import 'package:flutter/material.dart';

/// Border radius values for consistent rounded corners
class AppBorderRadius {
  final double none; // 0
  final double xs; // 4
  final double sm; // 8
  final double md; // 12
  final double lg; // 16
  final double xl; // 20
  final double xxl; // 24
  final double full; // 999 (fully rounded)

  // Component-specific radius
  final double button;
  final double card;
  final double dialog;
  final double textField;
  final double chip;
  final double messageBubble;
  final double bottomSheet;
  final double tooltip;

  const AppBorderRadius({
    this.none = 0.0,
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 12.0,
    this.lg = 16.0,
    this.xl = 20.0,
    this.xxl = 24.0,
    this.full = 999.0,
    this.button = 8.0,
    this.card = 12.0,
    this.dialog = 16.0,
    this.textField = 8.0,
    this.chip = 16.0,
    this.messageBubble = 16.0,
    this.bottomSheet = 20.0,
    this.tooltip = 6.0,
  });

  /// Default border radius system
  factory AppBorderRadius.defaultRadius() {
    return const AppBorderRadius();
  }

  /// Notion-style border radius (more subtle/minimal)
  factory AppBorderRadius.notionRadius() {
    return const AppBorderRadius(
      none: 0.0,
      xs: 3.0,
      sm: 6.0,
      md: 8.0, // Less rounded than default
      lg: 12.0, // More subtle
      xl: 16.0,
      xxl: 20.0,
      full: 999.0,
      button: 6.0, // Subtle button rounding
      card: 8.0, // Minimal card rounding
      dialog: 12.0, // Subtle dialog rounding
      textField: 6.0, // Minimal input rounding
      chip: 12.0, // Less rounded chips
      messageBubble: 12.0, // Subtle message bubbles
      bottomSheet: 16.0,
      tooltip: 4.0,
    );
  }

  /// Sharp/angular design (minimal rounding)
  factory AppBorderRadius.sharpRadius() {
    return const AppBorderRadius(
      none: 0.0,
      xs: 2.0,
      sm: 4.0,
      md: 6.0,
      lg: 8.0,
      xl: 12.0,
      xxl: 16.0,
      full: 999.0,
      button: 4.0,
      card: 6.0,
      dialog: 8.0,
      textField: 4.0,
      chip: 8.0,
      messageBubble: 8.0,
      bottomSheet: 12.0,
      tooltip: 2.0,
    );
  }

  /// Rounded/friendly design (more rounding)
  factory AppBorderRadius.roundedRadius() {
    return const AppBorderRadius(
      none: 0.0,
      xs: 6.0,
      sm: 12.0,
      md: 16.0,
      lg: 20.0,
      xl: 24.0,
      xxl: 32.0,
      full: 999.0,
      button: 12.0,
      card: 16.0,
      dialog: 20.0,
      textField: 12.0,
      chip: 20.0,
      messageBubble: 20.0,
      bottomSheet: 24.0,
      tooltip: 8.0,
    );
  }

  /// Helper methods to create BorderRadius objects
  BorderRadius get noneBorderRadius => BorderRadius.circular(none);
  BorderRadius get xsBorderRadius => BorderRadius.circular(xs);
  BorderRadius get smBorderRadius => BorderRadius.circular(sm);
  BorderRadius get mdBorderRadius => BorderRadius.circular(md);
  BorderRadius get lgBorderRadius => BorderRadius.circular(lg);
  BorderRadius get xlBorderRadius => BorderRadius.circular(xl);
  BorderRadius get xxlBorderRadius => BorderRadius.circular(xxl);
  BorderRadius get fullBorderRadius => BorderRadius.circular(full);

  BorderRadius get buttonBorderRadius => BorderRadius.circular(button);
  BorderRadius get cardBorderRadius => BorderRadius.circular(card);
  BorderRadius get dialogBorderRadius => BorderRadius.circular(dialog);
  BorderRadius get textFieldBorderRadius => BorderRadius.circular(textField);
  BorderRadius get chipBorderRadius => BorderRadius.circular(chip);
  BorderRadius get messageBubbleBorderRadius =>
      BorderRadius.circular(messageBubble);
  BorderRadius get bottomSheetBorderRadius => BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );
  BorderRadius get tooltipBorderRadius => BorderRadius.circular(tooltip);
}
