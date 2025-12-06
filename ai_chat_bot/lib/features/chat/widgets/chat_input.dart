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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input with cyberpunk styling
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
                          color: AppTheme.backgroundDark,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? AppTheme.primaryColor
                                : AppTheme.primaryColor.withValues(alpha: 0.3),
                            width: _focusNode.hasFocus ? 2 : 1,
                          ),
                          boxShadow: _focusNode.hasFocus
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
                          style: GoogleFonts.rajdhani(
                            color: AppTheme.textPrimaryDark,
                            fontSize: 15,
                          ),
                          cursorColor: AppTheme.primaryColor,
                          decoration: InputDecoration(
                            hintText: 'ENTER QUERY...',
                            hintStyle: GoogleFonts.rajdhani(
                              color: AppTheme.textSecondaryDark.withValues(
                                alpha: 0.5,
                              ),
                              letterSpacing: 1,
                            ),
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

            // Cyberpunk send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _hasText && !widget.isLoading
                    ? AppTheme.neonPink.withValues(alpha: 0.2)
                    : AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _hasText && !widget.isLoading
                      ? AppTheme.neonPink
                      : AppTheme.textSecondaryDark.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: _hasText && !widget.isLoading
                    ? [
                        BoxShadow(
                          color: AppTheme.neonPink.withValues(alpha: 0.4),
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
                  borderRadius: BorderRadius.circular(4),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.neonPink,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: _hasText
                                ? AppTheme.neonPink
                                : AppTheme.textSecondaryDark.withValues(
                                    alpha: 0.5,
                                  ),
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
