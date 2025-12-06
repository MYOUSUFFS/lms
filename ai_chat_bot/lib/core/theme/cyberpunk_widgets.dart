import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Cyberpunk styled container with neon border glow
class CyberpunkContainer extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double glowIntensity;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final bool showScanLines;

  const CyberpunkContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowIntensity = 0.5,
    this.padding,
    this.margin,
    this.borderRadius = 8,
    this.showScanLines = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? AppTheme.primaryColor;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveGlowColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveGlowColor.withValues(alpha: 0.2 * glowIntensity),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: effectiveGlowColor.withValues(alpha: 0.1 * glowIntensity),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (showScanLines) const _ScanLines(),
            Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ],
        ),
      ),
    );
  }
}

/// Neon glowing text widget
class NeonText extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;
  final bool useOrbitron;
  final double glowIntensity;
  final TextAlign? textAlign;

  const NeonText({
    super.key,
    required this.text,
    this.color,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.useOrbitron = true,
    this.glowIntensity = 1.0,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    return Text(
      text,
      textAlign: textAlign,
      style: (useOrbitron ? GoogleFonts.orbitron() : GoogleFonts.rajdhani())
          .copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: effectiveColor,
            letterSpacing: useOrbitron ? 2 : 1,
            shadows: [
              Shadow(
                color: effectiveColor.withValues(alpha: 0.8 * glowIntensity),
                blurRadius: 8,
              ),
              Shadow(
                color: effectiveColor.withValues(alpha: 0.5 * glowIntensity),
                blurRadius: 16,
              ),
              Shadow(
                color: effectiveColor.withValues(alpha: 0.3 * glowIntensity),
                blurRadius: 24,
              ),
            ],
          ),
    );
  }
}

/// Cyberpunk styled button with neon glow
class CyberpunkButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;
  final bool isLoading;
  final bool filled;

  const CyberpunkButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.icon,
    this.isLoading = false,
    this.filled = false,
  });

  @override
  State<CyberpunkButton> createState() => _CyberpunkButtonState();
}

class _CyberpunkButtonState extends State<CyberpunkButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppTheme.primaryColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.filled
              ? effectiveColor.withValues(alpha: _isHovered ? 0.3 : 0.1)
              : Colors.transparent,
          border: Border.all(color: effectiveColor, width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: _isHovered || widget.filled
              ? AppTheme.neonGlow(
                  effectiveColor,
                  intensity: _isHovered ? 1.2 : 0.8,
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(4),
            splashColor: effectiveColor.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: effectiveColor,
                      ),
                    )
                  else if (widget.icon != null) ...[
                    Icon(widget.icon, color: effectiveColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  if (!widget.isLoading)
                    Text(
                      widget.text.toUpperCase(),
                      style: GoogleFonts.rajdhani(
                        color: effectiveColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated scanning line effect (like in old CRT monitors)
class _ScanLines extends StatelessWidget {
  const _ScanLines();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(child: CustomPaint(painter: _ScanLinesPainter())),
    );
  }
}

class _ScanLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Glowing icon widget
class GlowingIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final double glowIntensity;

  const GlowingIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
    this.glowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.5 * glowIntensity),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: effectiveColor, size: size),
    );
  }
}

/// Cyberpunk styled divider with gradient
class CyberpunkDivider extends StatelessWidget {
  final Color? color;
  final double height;

  const CyberpunkDivider({super.key, this.color, this.height = 1});

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? AppTheme.primaryColor;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            dividerColor.withValues(alpha: 0.3),
            dividerColor.withValues(alpha: 0.8),
            dividerColor.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: dividerColor.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

/// Animated glitch text effect
class GlitchText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color? color;

  const GlitchText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.color,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _startGlitch();
  }

  void _startGlitch() async {
    while (mounted) {
      await Future.delayed(
        Duration(milliseconds: 2000 + (500 * (DateTime.now().millisecond % 5))),
      );
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) _controller.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Red offset
            if (_controller.value > 0)
              Transform.translate(
                offset: Offset(-2 * _controller.value, 0),
                child: Text(
                  widget.text,
                  style: GoogleFonts.orbitron(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonRed.withValues(alpha: 0.7),
                    letterSpacing: 2,
                  ),
                ),
              ),
            // Cyan offset
            if (_controller.value > 0)
              Transform.translate(
                offset: Offset(2 * _controller.value, 0),
                child: Text(
                  widget.text,
                  style: GoogleFonts.orbitron(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    letterSpacing: 2,
                  ),
                ),
              ),
            // Main text
            NeonText(
              text: widget.text,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
          ],
        );
      },
    );
  }
}

/// Corner brackets decoration (common in cyberpunk UI)
class CornerBrackets extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double size;
  final double strokeWidth;
  final EdgeInsets padding;

  const CornerBrackets({
    super.key,
    required this.child,
    this.color,
    this.size = 12,
    this.strokeWidth = 2,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    return CustomPaint(
      painter: _CornerBracketsPainter(
        color: effectiveColor,
        size: size,
        strokeWidth: strokeWidth,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  final Color color;
  final double size;
  final double strokeWidth;

  _CornerBracketsPainter({
    required this.color,
    required this.size,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, size)
        ..lineTo(0, 0)
        ..lineTo(size, 0),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(canvasSize.width - size, 0)
        ..lineTo(canvasSize.width, 0)
        ..lineTo(canvasSize.width, size),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, canvasSize.height - size)
        ..lineTo(0, canvasSize.height)
        ..lineTo(size, canvasSize.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(canvasSize.width - size, canvasSize.height)
        ..lineTo(canvasSize.width, canvasSize.height)
        ..lineTo(canvasSize.width, canvasSize.height - size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Status indicator with pulsing glow
class CyberpunkStatusIndicator extends StatefulWidget {
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  const CyberpunkStatusIndicator({
    super.key,
    required this.isActive,
    this.activeColor = AppTheme.successColor,
    this.inactiveColor = AppTheme.errorColor,
    this.size = 8,
  });

  @override
  State<CyberpunkStatusIndicator> createState() =>
      _CyberpunkStatusIndicatorState();
}

class _CyberpunkStatusIndicatorState extends State<CyberpunkStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? widget.activeColor : widget.inactiveColor;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6 * _animation.value),
                      blurRadius: 8 * _animation.value,
                      spreadRadius: 2 * _animation.value,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
