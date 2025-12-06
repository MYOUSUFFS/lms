import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/message.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/theme/app_theme.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.currentMessages;
    final streamingContent = chatProvider.streamingContent;

    // Auto scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatProvider.isLoading || streamingContent.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: messages.length + (streamingContent.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // Show streaming message
        if (index == messages.length && streamingContent.isNotEmpty) {
          return _MessageBubble(
            message: Message(
              content: streamingContent,
              role: MessageRole.assistant,
              status: MessageStatus.sending,
            ),
            isStreaming: true,
          );
        }

        return _MessageBubble(message: messages[index]);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isStreaming;

  const _MessageBubble({required this.message, this.isStreaming = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isCyberpunk = AppTheme.isCyberpunk;
    final theme = Theme.of(context);
    final userColor = AppTheme.accentColor;
    final accentColor = AppTheme.accentColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assistant avatar
          if (!isUser) ...[
            _CyberpunkAvatar(isUser: false),
            const SizedBox(width: 12),
          ],

          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? userColor.withValues(alpha: isCyberpunk ? 0.15 : 0.1)
                    : (isCyberpunk ? AppTheme.cardDark : theme.cardColor),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isCyberpunk ? 4 : 16),
                  topRight: Radius.circular(isCyberpunk ? 4 : 16),
                  bottomLeft: Radius.circular(
                    isUser ? (isCyberpunk ? 4 : 16) : 0,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? 0 : (isCyberpunk ? 4 : 16),
                  ),
                ),
                border: isCyberpunk
                    ? Border.all(
                        color: isUser
                            ? userColor.withValues(alpha: 0.6)
                            : accentColor.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
                boxShadow: isCyberpunk
                    ? [
                        BoxShadow(
                          color: isUser
                              ? userColor.withValues(alpha: 0.15)
                              : accentColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  if (isUser)
                    SelectableText(
                      message.content,
                      style: isCyberpunk
                          ? GoogleFonts.rajdhani(
                              color: AppTheme.textPrimaryDark,
                              fontSize: 15,
                            )
                          : TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 15,
                            ),
                    )
                  else
                    MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: isCyberpunk
                            ? GoogleFonts.rajdhani(
                                color: AppTheme.textPrimaryDark,
                                fontSize: 15,
                              )
                            : TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 15,
                              ),
                        h1: isCyberpunk
                            ? GoogleFonts.orbitron(
                                color: accentColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )
                            : TextStyle(
                                color: accentColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                        h2: isCyberpunk
                            ? GoogleFonts.orbitron(
                                color: accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )
                            : TextStyle(
                                color: accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                        h3: isCyberpunk
                            ? GoogleFonts.orbitron(
                                color: accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )
                            : TextStyle(
                                color: accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        code: GoogleFonts.firaCode(
                          backgroundColor: isCyberpunk
                              ? AppTheme.backgroundDark
                              : Colors.grey[100],
                          color: isCyberpunk
                              ? AppTheme.neonGreen
                              : Colors.green[700],
                          fontSize: 13,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isCyberpunk
                              ? AppTheme.backgroundDark
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(
                            isCyberpunk ? 4 : 8,
                          ),
                          border: isCyberpunk
                              ? Border.all(
                                  color: AppTheme.neonGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                )
                              : null,
                        ),
                        blockquote: isCyberpunk
                            ? GoogleFonts.rajdhani(
                                color: AppTheme.textSecondaryDark,
                                fontStyle: FontStyle.italic,
                              )
                            : TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: isCyberpunk
                                  ? AppTheme.neonPurple
                                  : accentColor,
                              width: 3,
                            ),
                          ),
                        ),
                        listBullet: isCyberpunk
                            ? GoogleFonts.rajdhani(color: accentColor)
                            : TextStyle(color: accentColor),
                        a: isCyberpunk
                            ? GoogleFonts.rajdhani(
                                color: accentColor,
                                decoration: TextDecoration.underline,
                              )
                            : TextStyle(
                                color: accentColor,
                                decoration: TextDecoration.underline,
                              ),
                      ),
                    ),

                  // Streaming indicator
                  if (isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PulsingDot(),
                          const SizedBox(width: 8),
                          Text(
                            isCyberpunk ? 'PROCESSING...' : 'Thinking...',
                            style: isCyberpunk
                                ? GoogleFonts.rajdhani(
                                    fontSize: 11,
                                    color: accentColor,
                                    letterSpacing: 2,
                                  )
                                : TextStyle(fontSize: 11, color: accentColor),
                          ),
                        ],
                      ),
                    ),

                  // Error message
                  if (message.hasError && message.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            isCyberpunk ? 4 : 8,
                          ),
                          border: Border.all(
                            color: AppTheme.errorColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isCyberpunk
                                  ? 'ERROR: ${message.errorMessage}'
                                  : 'Error: ${message.errorMessage}',
                              style: isCyberpunk
                                  ? GoogleFonts.rajdhani(
                                      fontSize: 11,
                                      color: AppTheme.errorColor,
                                      letterSpacing: 1,
                                    )
                                  : const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.errorColor,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Sources
                  if (message.sources != null && message.sources!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCyberpunk ? 'DATA SOURCES:' : 'Sources:',
                            style: isCyberpunk
                                ? GoogleFonts.rajdhani(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.neonPurple,
                                    letterSpacing: 2,
                                  )
                                : TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: message.sources!.map((source) {
                              final sourceColor = isCyberpunk
                                  ? AppTheme.neonPurple
                                  : accentColor;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: sourceColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    isCyberpunk ? 4 : 12,
                                  ),
                                  border: Border.all(
                                    color: sourceColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  source,
                                  style: isCyberpunk
                                      ? GoogleFonts.rajdhani(
                                          fontSize: 10,
                                          color: sourceColor,
                                        )
                                      : TextStyle(
                                          fontSize: 10,
                                          color: sourceColor,
                                        ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // User avatar with cyberpunk glow
          if (isUser) ...[
            const SizedBox(width: 12),
            _CyberpunkAvatar(isUser: true),
          ],

          // Action buttons for assistant messages
          if (!isUser && !isStreaming) ...[
            const SizedBox(width: 8),
            Column(
              children: [
                _CyberpunkActionButton(
                  icon: Icons.copy_outlined,
                  tooltip: isCyberpunk ? 'COPY' : 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isCyberpunk
                              ? 'DATA COPIED TO BUFFER'
                              : 'Copied to clipboard',
                          style: isCyberpunk
                              ? GoogleFonts.rajdhani(
                                  color: accentColor,
                                  letterSpacing: 1,
                                )
                              : TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        backgroundColor: isCyberpunk
                            ? AppTheme.cardDark
                            : theme.snackBarTheme.backgroundColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                if (message.hasError)
                  _CyberpunkActionButton(
                    icon: Icons.refresh,
                    tooltip: isCyberpunk ? 'RETRY' : 'Retry',
                    color: AppTheme.neonOrange,
                    onPressed: () {
                      context.read<ChatProvider>().retryLastMessage();
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CyberpunkAvatar extends StatelessWidget {
  final bool isUser;

  const _CyberpunkAvatar({required this.isUser});

  @override
  Widget build(BuildContext context) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final userColor = AppTheme.accentColor;
    final assistantColor = AppTheme.accentColor;
    final color = isUser ? userColor : assistantColor;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUser
              ? [
                  userColor,
                  isCyberpunk ? AppTheme.neonPurple : const Color(0xFF8B5CF6),
                ]
              : [
                  assistantColor,
                  isCyberpunk ? AppTheme.neonPurple : const Color(0xFF8B5CF6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isCyberpunk ? 6 : 18),
        border: isCyberpunk
            ? Border.all(color: color.withValues(alpha: 0.5), width: 1)
            : null,
        boxShadow: isCyberpunk
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology_outlined,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}

class _CyberpunkActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _CyberpunkActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final defaultColor = isCyberpunk
        ? AppTheme.primaryColor
        : const Color(0xFF6366F1);
    final effectiveColor = color ?? defaultColor;
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 8),
          border: isCyberpunk
              ? Border.all(color: effectiveColor.withValues(alpha: 0.3))
              : null,
        ),
        child: IconButton(
          icon: Icon(icon, color: effectiveColor, size: 16),
          onPressed: onPressed,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          splashRadius: 14,
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
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
    final isCyberpunk = AppTheme.isCyberpunk;
    final color = isCyberpunk ? AppTheme.primaryColor : const Color(0xFF6366F1);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isCyberpunk
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
