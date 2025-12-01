import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assistant avatar
          if (!isUser) ...[_Avatar(isUser: false), const SizedBox(width: 12)],

          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? (isDark
                          ? AppTheme.userBubbleDark
                          : AppTheme.userBubbleLight)
                    : (isDark
                          ? AppTheme.assistantBubbleDark
                          : AppTheme.assistantBubbleLight),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  if (isUser)
                    SelectableText(
                      message.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: theme.textTheme.bodyMedium,
                        code: TextStyle(
                          fontFamily: 'monospace',
                          backgroundColor: isDark
                              ? Colors.black26
                              : Colors.grey.shade200,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                  // Streaming indicator
                  if (isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Thinking...', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),

                  // Error message
                  if (message.hasError && message.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 14,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Error: ${message.errorMessage}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Sources (for RAG responses)
                  if (message.sources != null && message.sources!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sources:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: message.sources!.map((source) {
                              return Chip(
                                label: Text(
                                  source,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                visualDensity: VisualDensity.compact,
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

          // User avatar
          if (isUser) ...[const SizedBox(width: 12), _Avatar(isUser: true)],

          // Action buttons (for assistant messages)
          if (!isUser && !isStreaming) ...[
            const SizedBox(width: 8),
            Column(
              children: [
                _ActionButton(
                  icon: Icons.copy_outlined,
                  tooltip: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                if (message.hasError)
                  _ActionButton(
                    icon: Icons.refresh,
                    tooltip: 'Retry',
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

class _Avatar extends StatelessWidget {
  final bool isUser;

  const _Avatar({required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser
            ? null
            : LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              ),
        color: isUser ? AppTheme.primaryColor : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy_outlined,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        splashRadius: 14,
      ),
    );
  }
}
