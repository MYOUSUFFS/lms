import 'package:flutter/material.dart';

/// Extension to get cyberpunk theme properties from any theme
extension CyberpunkThemeData on ThemeData {
  /// Check if current theme is cyberpunk-style
  bool get isCyberpunk {
    final extension = extensions[CyberpunkThemeExtension];
    return extension != null;
  }

  /// Get cyberpunk extension or return default
  CyberpunkThemeExtension get cyberpunk {
    final extension = extensions[CyberpunkThemeExtension];
    if (extension is CyberpunkThemeExtension) {
      return extension;
    }
    // Return default cyberpunk extension
    return const CyberpunkThemeExtension(
      glowColor: Colors.cyan,
      scanlineOpacity: 0.0,
      enableGlow: false,
      enableScanlines: false,
    );
  }
}

/// Theme extension for cyberpunk-specific properties
class CyberpunkThemeExtension extends ThemeExtension<CyberpunkThemeExtension> {
  final Color glowColor;
  final double scanlineOpacity;
  final bool enableGlow;
  final bool enableScanlines;

  const CyberpunkThemeExtension({
    required this.glowColor,
    required this.scanlineOpacity,
    required this.enableGlow,
    required this.enableScanlines,
  });

  @override
  CyberpunkThemeExtension copyWith({
    Color? glowColor,
    double? scanlineOpacity,
    bool? enableGlow,
    bool? enableScanlines,
  }) {
    return CyberpunkThemeExtension(
      glowColor: glowColor ?? this.glowColor,
      scanlineOpacity: scanlineOpacity ?? this.scanlineOpacity,
      enableGlow: enableGlow ?? this.enableGlow,
      enableScanlines: enableScanlines ?? this.enableScanlines,
    );
  }

  @override
  CyberpunkThemeExtension lerp(
    ThemeExtension<CyberpunkThemeExtension>? other,
    double t,
  ) {
    if (other is! CyberpunkThemeExtension) {
      return this;
    }
    return CyberpunkThemeExtension(
      glowColor: Color.lerp(glowColor, other.glowColor, t) ?? glowColor,
      scanlineOpacity:
          (scanlineOpacity + (other.scanlineOpacity - scanlineOpacity) * t),
      enableGlow: t < 0.5 ? enableGlow : other.enableGlow,
      enableScanlines: t < 0.5 ? enableScanlines : other.enableScanlines,
    );
  }
}

/// Enhanced cyberpunk container that adapts based on current theme
class EnhancedCyberpunkContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? glowColor;
  final bool? showScanLines;
  final double? glowIntensity;

  const EnhancedCyberpunkContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.glowColor,
    this.showScanLines,
    this.glowIntensity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cyberpunkExt = theme.cyberpunk;

    // Use theme colors instead of static values
    final effectiveGlowColor = glowColor ?? theme.colorScheme.primary;

    final effectiveBorderRadius =
        borderRadius ?? (theme.isCyberpunk ? 4.0 : 12.0);

    final shouldShowGlow = cyberpunkExt.enableGlow;
    final shouldShowScanlines = showScanLines ?? cyberpunkExt.enableScanlines;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(
          color: theme.isCyberpunk
              ? effectiveGlowColor
              : theme.colorScheme.outline,
          width: theme.isCyberpunk ? 1 : 0.5,
        ),
        boxShadow: shouldShowGlow
            ? [
                BoxShadow(
                  color: effectiveGlowColor.withValues(
                    alpha: 0.3 * (glowIntensity ?? 0.5),
                  ),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: effectiveGlowColor.withValues(
                    alpha: 0.1 * (glowIntensity ?? 0.5),
                  ),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ]
            : theme.cardTheme.shadowColor != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
          if (shouldShowScanlines)
            _buildScanlines(cyberpunkExt, effectiveBorderRadius),
        ],
      ),
    );
  }

  Widget _buildScanlines(
    CyberpunkThemeExtension cyberpunkExt,
    double borderRadius,
  ) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: List.generate(20, (index) {
                final isEven = index.isEven;
                return isEven
                    ? Colors.transparent
                    : cyberpunkExt.glowColor.withValues(
                        alpha: cyberpunkExt.scanlineOpacity,
                      );
              }),
              stops: List.generate(20, (index) => index / 19),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced cyberpunk text that adapts to theme
class EnhancedCyberpunkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool? enableGlow;
  final Color? glowColor;
  final double? glowBlurRadius;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const EnhancedCyberpunkText(
    this.text, {
    super.key,
    this.style,
    this.enableGlow,
    this.glowColor,
    this.glowBlurRadius = 3.0,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cyberpunkExt = theme.cyberpunk;

    final shouldGlow = enableGlow ?? cyberpunkExt.enableGlow;
    final effectiveGlowColor = glowColor ?? theme.colorScheme.primary;

    final baseStyle = style ?? theme.textTheme.bodyMedium!;

    final enhancedStyle = shouldGlow
        ? baseStyle.copyWith(
            shadows: [
              Shadow(
                blurRadius: glowBlurRadius!,
                color: effectiveGlowColor.withValues(alpha: 0.4),
                offset: const Offset(0, 0),
              ),
            ],
          )
        : baseStyle;

    return Text(
      text,
      style: enhancedStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
