/// Enum for different theme styles
enum ThemeStyle {
  classic,
  cyberpunk,
}

/// Extension to get display names for theme styles
extension ThemeStyleExtension on ThemeStyle {
  String get displayName {
    switch (this) {
      case ThemeStyle.classic:
        return 'Classic';
      case ThemeStyle.cyberpunk:
        return 'Cyberpunk';
    }
  }

  String get description {
    switch (this) {
      case ThemeStyle.classic:
        return 'Clean and modern Material Design';
      case ThemeStyle.cyberpunk:
        return 'Futuristic neon-styled interface';
    }
  }
}
