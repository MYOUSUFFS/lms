/// Spacing constants for consistent layout
class AppSpacing {
  // Base spacing unit (8px)
  static const double unit = 8.0;

  // Spacing scale
  final double xs; // Extra small: 4px
  final double sm; // Small: 8px
  final double md; // Medium: 16px
  final double lg; // Large: 24px
  final double xl; // Extra large: 32px
  final double xxl; // Extra extra large: 48px
  final double xxxl; // Triple extra large: 64px

  // Component-specific spacing
  final double paddingTiny; // 4px
  final double paddingSmall; // 8px
  final double paddingMedium; // 16px
  final double paddingLarge; // 24px
  final double paddingXLarge; // 32px

  final double marginTiny; // 4px
  final double marginSmall; // 8px
  final double marginMedium; // 16px
  final double marginLarge; // 24px
  final double marginXLarge; // 32px

  // Chat-specific spacing
  final double messageSpacing; // 12px
  final double bubblePadding; // 16px
  final double sidebarPadding; // 20px
  final double inputPadding; // 16px

  const AppSpacing({
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 16.0,
    this.lg = 24.0,
    this.xl = 32.0,
    this.xxl = 48.0,
    this.xxxl = 64.0,
    this.paddingTiny = 4.0,
    this.paddingSmall = 8.0,
    this.paddingMedium = 16.0,
    this.paddingLarge = 24.0,
    this.paddingXLarge = 32.0,
    this.marginTiny = 4.0,
    this.marginSmall = 8.0,
    this.marginMedium = 16.0,
    this.marginLarge = 24.0,
    this.marginXLarge = 32.0,
    this.messageSpacing = 12.0,
    this.bubblePadding = 16.0,
    this.sidebarPadding = 20.0,
    this.inputPadding = 16.0,
  });

  /// Default spacing system
  factory AppSpacing.defaultSpacing() {
    return const AppSpacing();
  }

  /// Notion-style spacing (slightly more generous)
  factory AppSpacing.notionSpacing() {
    return const AppSpacing(
      xs: 4.0,
      sm: 12.0, // Slightly larger than default
      md: 20.0, // More generous medium spacing
      lg: 28.0, // Larger spacing
      xl: 36.0, // More breathing room
      xxl: 52.0,
      xxxl: 68.0,
      paddingTiny: 6.0,
      paddingSmall: 12.0,
      paddingMedium: 20.0,
      paddingLarge: 28.0,
      paddingXLarge: 36.0,
      marginTiny: 6.0,
      marginSmall: 12.0,
      marginMedium: 20.0,
      marginLarge: 28.0,
      marginXLarge: 36.0,
      messageSpacing: 16.0, // More space between messages
      bubblePadding: 20.0, // More generous bubble padding
      sidebarPadding: 24.0, // More sidebar breathing room
      inputPadding: 20.0, // More input padding
    );
  }

  /// Compact spacing for dense layouts
  factory AppSpacing.compactSpacing() {
    return const AppSpacing(
      xs: 2.0,
      sm: 6.0,
      md: 12.0,
      lg: 18.0,
      xl: 24.0,
      xxl: 36.0,
      xxxl: 48.0,
      paddingTiny: 2.0,
      paddingSmall: 6.0,
      paddingMedium: 12.0,
      paddingLarge: 18.0,
      paddingXLarge: 24.0,
      marginTiny: 2.0,
      marginSmall: 6.0,
      marginMedium: 12.0,
      marginLarge: 18.0,
      marginXLarge: 24.0,
      messageSpacing: 8.0,
      bubblePadding: 12.0,
      sidebarPadding: 16.0,
      inputPadding: 12.0,
    );
  }
}
