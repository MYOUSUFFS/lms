import 'package:flutter/material.dart';
import '../widgets/enhanced_cyberpunk_widgets_fixed.dart';

/// Wrapper that applies cyberpunk effects when a cyberpunk theme is active
class CyberpunkApp extends StatelessWidget {
  final Widget child;

  const CyberpunkApp({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cyberpunkExtension = Theme.of(
      context,
    ).extension<CyberpunkThemeExtension>();

    if (cyberpunkExtension?.enableScanlines == true ||
        cyberpunkExtension?.enableGlow == true) {
      return CyberpunkEffectsWrapper(
        scanlineOpacity: cyberpunkExtension?.scanlineOpacity ?? 0.1,
        child: child,
      );
    }

    return child;
  }
}

/// Wrapper that applies cyberpunk visual effects
class CyberpunkEffectsWrapper extends StatefulWidget {
  final Widget child;
  final double scanlineOpacity;

  const CyberpunkEffectsWrapper({
    Key? key,
    required this.child,
    this.scanlineOpacity = 0.1,
  }) : super(key: key);

  @override
  State<CyberpunkEffectsWrapper> createState() =>
      _CyberpunkEffectsWrapperState();
}

class _CyberpunkEffectsWrapperState extends State<CyberpunkEffectsWrapper>
    with TickerProviderStateMixin {
  late AnimationController _scanlineController;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Scanline effect overlay
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _scanlineController,
            builder: (context, _) {
              return CustomPaint(
                painter: ScanlinePainter(
                  progress: _scanlineController.value,
                  opacity: widget.scanlineOpacity,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Custom painter for scanline effects
class ScanlinePainter extends CustomPainter {
  final double progress;
  final double opacity;

  ScanlinePainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 1.0;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 4) {
      final alpha = (progress * 2 + y / size.height) % 1.0;
      paint.color = Colors.white.withValues(alpha: opacity * alpha);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}

/// Enhanced cyberpunk container that responds to theme
class CyberpunkContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const CyberpunkContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cyberpunkExtension = Theme.of(
      context,
    ).extension<CyberpunkThemeExtension>();
    final theme = Theme.of(context);

    // Use enhanced container if cyberpunk theme is active
    if (cyberpunkExtension != null && cyberpunkExtension.enableGlow) {
      return SizedBox(
        width: width,
        height: height,
        child: EnhancedCyberpunkContainer(
          padding: padding,
          margin: margin,
          child: child,
        ),
      );
    }

    // Regular container for non-cyberpunk themes
    return Container(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }
}

/// Enhanced cyberpunk text that responds to theme
class CyberpunkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const CyberpunkText(
    this.text, {
    Key? key,
    this.style,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cyberpunkExtension = Theme.of(
      context,
    ).extension<CyberpunkThemeExtension>();

    // Use enhanced text if cyberpunk theme is active
    if (cyberpunkExtension != null && cyberpunkExtension.enableGlow) {
      return EnhancedCyberpunkText(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // Regular text for non-cyberpunk themes
    return Text(text, style: style, maxLines: maxLines, overflow: overflow);
  }
}

/// Enhanced cyberpunk card that responds to theme
class CyberpunkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const CyberpunkCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cyberpunkExtension = Theme.of(
      context,
    ).extension<CyberpunkThemeExtension>();

    // Use enhanced card if cyberpunk theme is active
    if (cyberpunkExtension != null && cyberpunkExtension.enableGlow) {
      return Container(
        margin: margin,
        child: EnhancedCyberpunkContainer(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      );
    }

    // Regular card for non-cyberpunk themes
    return Card(
      margin: margin,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
