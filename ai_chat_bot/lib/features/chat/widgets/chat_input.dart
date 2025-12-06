import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInput({super.key, required this.onSend, required this.isLoading});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

// Theme-aware accent color for chat input
Color _getAccentColor() {
  return AppTheme.accentColor;
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    // Remove trailing newlines/spaces that might have been added by Enter key
    String text = _controller.text.trimRight();
    // Also remove any leading/trailing whitespace
    text = text.trim();

    if (text.isEmpty || widget.isLoading) return;

    widget.onSend(text);
    _focusNode.requestFocus();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = _getAccentColor();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCyberpunk ? AppTheme.cardDark : theme.cardColor,
        border: Border(
          top: BorderSide(
            color: isCyberpunk
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : theme.dividerColor,
            width: 1,
          ),
        ),
        boxShadow: isCyberpunk
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Focus(
                      onKeyEvent: (node, event) {
                        // Handle Enter key to send message (without Shift)
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter &&
                            !HardwareKeyboard.instance.isShiftPressed) {
                          _handleSend();
                          // Return handled to prevent newline from being added
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCyberpunk
                              ? AppTheme.backgroundDark
                              : theme.inputDecorationTheme.fillColor ??
                                    Colors.grey[100],
                          borderRadius: BorderRadius.circular(
                            isCyberpunk ? 4 : 12,
                          ),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? (isCyberpunk
                                      ? AppTheme.primaryColor
                                      : accentColor)
                                : (isCyberpunk
                                      ? AppTheme.primaryColor.withValues(
                                          alpha: 0.3,
                                        )
                                      : Colors.grey[300]!),
                            width: _focusNode.hasFocus ? 2 : 1,
                          ),
                          boxShadow: _focusNode.hasFocus && isCyberpunk
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: 5,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          style: isCyberpunk
                              ? GoogleFonts.rajdhani(
                                  color: AppTheme.textPrimaryDark,
                                  fontSize: 15,
                                )
                              : TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontSize: 15,
                                ),
                          cursorColor: isCyberpunk
                              ? AppTheme.primaryColor
                              : accentColor,
                          decoration: InputDecoration(
                            hintText: isCyberpunk
                                ? 'ENTER QUERY...'
                                : 'Type your message...',
                            hintStyle: isCyberpunk
                                ? GoogleFonts.rajdhani(
                                    color: AppTheme.textSecondaryDark
                                        .withValues(alpha: 0.5),
                                    letterSpacing: 1,
                                  )
                                : TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _hasText && !widget.isLoading
                    ? accentColor.withValues(alpha: isCyberpunk ? 0.2 : 1.0)
                    : (isCyberpunk ? AppTheme.surfaceDark : Colors.grey[200]),
                borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 24),
                border: isCyberpunk
                    ? Border.all(
                        color: _hasText && !widget.isLoading
                            ? accentColor
                            : AppTheme.textSecondaryDark.withValues(alpha: 0.3),
                        width: 2,
                      )
                    : null,
                boxShadow: _hasText && !widget.isLoading && isCyberpunk
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _hasText && !widget.isLoading ? _handleSend : null,
                  borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 24),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isCyberpunk ? accentColor : Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: _hasText
                                ? (isCyberpunk ? accentColor : Colors.white)
                                : (isCyberpunk
                                      ? AppTheme.textSecondaryDark.withValues(
                                          alpha: 0.5,
                                        )
                                      : Colors.grey[500]),
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
