import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/cyberpunk_widgets.dart';

class ChatSidebar extends StatelessWidget {
  final VoidCallback onNewChat;
  final VoidCallback onOpenSettings;

  const ChatSidebar({
    super.key,
    required this.onNewChat,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;
    final secondaryAccent = AppTheme.secondaryAccent;

    return Container(
      decoration: BoxDecoration(
        color: isCyberpunk
            ? AppTheme.backgroundDark
            : Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with new chat button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Logo and title
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [secondaryAccent, accentColor],
                        ),
                        borderRadius: BorderRadius.circular(
                          isCyberpunk ? 8 : 12,
                        ),
                        boxShadow: isCyberpunk
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeonText(
                            text: isCyberpunk ? 'LMS CHAT' : 'LMS Chat',
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            glowIntensity: 0.8,
                          ),
                          Text(
                            isCyberpunk ? 'v2.0 NEURAL' : 'AI Assistant',
                            style: AppTheme.getBodyTextStyle(
                              fontSize: 10,
                              color: AppTheme.themeTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: secondaryAccent.withValues(alpha: 0.1),
                        border: Border.all(
                          color: secondaryAccent.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(
                          isCyberpunk ? 4 : 12,
                        ),
                      ),
                      child: IconButton(
                        onPressed: onOpenSettings,
                        icon: Icon(
                          Icons.tune,
                          color: secondaryAccent,
                          size: 20,
                        ),
                        tooltip: isCyberpunk ? 'SETTINGS' : 'Settings',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // New chat button
                SizedBox(
                  width: double.infinity,
                  child: CyberpunkButton(
                    text: isCyberpunk ? 'NEW SESSION' : 'New Chat',
                    icon: Icons.add,
                    color: accentColor,
                    filled: true,
                    onPressed: onNewChat,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          CyberpunkDivider(color: accentColor),

          // Conversations list
          Expanded(
            child: chatProvider.filteredConversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: chatProvider.filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = chatProvider.filteredConversations[index];
                      final isSelected =
                          chatProvider.currentConversation?.id ==
                          conversation.id;

                      return _ConversationTile(
                        title: conversation.title,
                        preview: conversation.preview,
                        time: _formatTime(conversation.updatedAt),
                        isSelected: isSelected,
                        useRag: conversation.useRag,
                        onTap: () {
                          chatProvider.selectConversation(conversation.id);
                          // Close drawer on mobile
                          if (Scaffold.of(context).hasDrawer) {
                            Navigator.of(context).pop();
                          }
                        },
                        onDelete: () => _showDeleteDialog(
                          context,
                          chatProvider,
                          conversation.id,
                        ),
                      );
                    },
                  ),
          ),

          // Footer
          CyberpunkDivider(color: AppTheme.themeTextSecondary),
          Builder(
            builder: (context) {
              final isCyberpunk = AppTheme.isCyberpunk;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.storage_outlined,
                      size: 14,
                      color: AppTheme.themeTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isCyberpunk
                            ? '${chatProvider.conversations.length} SESSIONS'
                            : '${chatProvider.conversations.length} sessions',
                        style: AppTheme.getBodyTextStyle(
                          fontSize: 11,
                          color: AppTheme.themeTextSecondary,
                        ),
                      ),
                    ),
                    if (chatProvider.conversations.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showClearAllDialog(context, chatProvider),
                        child: Text(
                          isCyberpunk ? 'PURGE ALL' : 'Clear All',
                          style: AppTheme.getBodyTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.themeError,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(isCyberpunk ? 8 : 16),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: accentColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            NeonText(
              text: isCyberpunk ? 'NO SESSIONS' : 'No Chats',
              color: AppTheme.themeTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              glowIntensity: 0.3,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new conversation',
              style: AppTheme.getBodyTextStyle(
                fontSize: 12,
                color: AppTheme.themeTextSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return DateFormat.jm().format(dateTime);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat.E().format(dateTime);
    } else {
      return DateFormat.MMMd().format(dateTime);
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    ChatProvider chatProvider,
    String conversationId,
  ) {
    final isCyberpunk = AppTheme.isCyberpunk;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isCyberpunk
            ? AppTheme.cardDark
            : Theme.of(context).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCyberpunk ? 8 : 16),
          side: isCyberpunk
              ? BorderSide(color: AppTheme.themeError.withValues(alpha: 0.5))
              : BorderSide.none,
        ),
        title: NeonText(
          text: isCyberpunk ? 'TERMINATE SESSION' : 'Delete Chat',
          color: AppTheme.themeError,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          glowIntensity: 0.8,
        ),
        content: Text(
          'This will permanently delete this conversation.',
          style: AppTheme.getBodyTextStyle(color: AppTheme.themeTextSecondary),
        ),
        actions: [
          CyberpunkButton(
            text: 'Cancel',
            color: AppTheme.themeTextSecondary,
            onPressed: () => Navigator.pop(context),
          ),
          CyberpunkButton(
            text: isCyberpunk ? 'Terminate' : 'Delete',
            color: AppTheme.themeError,
            filled: true,
            onPressed: () {
              chatProvider.deleteConversation(conversationId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, ChatProvider chatProvider) {
    final isCyberpunk = AppTheme.isCyberpunk;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isCyberpunk
            ? AppTheme.cardDark
            : Theme.of(context).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCyberpunk ? 8 : 16),
          side: isCyberpunk
              ? BorderSide(color: AppTheme.themeError.withValues(alpha: 0.5))
              : BorderSide.none,
        ),
        title: NeonText(
          text: isCyberpunk ? 'PURGE ALL DATA' : 'Clear All Chats',
          color: AppTheme.themeError,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          glowIntensity: 0.8,
        ),
        content: Text(
          'This will permanently delete all conversations. This action cannot be undone.',
          style: AppTheme.getBodyTextStyle(color: AppTheme.themeTextSecondary),
        ),
        actions: [
          CyberpunkButton(
            text: isCyberpunk ? 'Abort' : 'Cancel',
            color: AppTheme.themeTextSecondary,
            onPressed: () => Navigator.pop(context),
          ),
          CyberpunkButton(
            text: isCyberpunk ? 'Purge' : 'Clear All',
            color: AppTheme.themeError,
            filled: true,
            onPressed: () {
              chatProvider.clearAllConversations();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatefulWidget {
  final String title;
  final String preview;
  final String time;
  final bool isSelected;
  final bool useRag;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.title,
    required this.preview,
    required this.time,
    required this.isSelected,
    required this.useRag,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<_ConversationTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;
    final secondaryAccent = AppTheme.secondaryAccent;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? accentColor.withValues(alpha: 0.1)
                : _isHovered
                ? accentColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
            border: Border.all(
              color: widget.isSelected
                  ? accentColor.withValues(alpha: 0.6)
                  : _isHovered
                  ? accentColor.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
            boxShadow: widget.isSelected && isCyberpunk
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.useRag
                      ? secondaryAccent.withValues(alpha: 0.2)
                      : accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 8),
                ),
                child: Icon(
                  widget.useRag ? Icons.memory : Icons.terminal,
                  size: 14,
                  color: widget.useRag ? secondaryAccent : accentColor,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCyberpunk ? widget.title.toUpperCase() : widget.title,
                      style: AppTheme.getBodyTextStyle(
                        fontSize: 13,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: widget.isSelected
                            ? accentColor
                            : AppTheme.themeTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.preview,
                            style: AppTheme.getBodyTextStyle(
                              fontSize: 11,
                              color: AppTheme.themeTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          widget.time,
                          style: AppTheme.getBodyTextStyle(
                            fontSize: 10,
                            color: AppTheme.themeTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button (show on hover)
              if (_isHovered)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppTheme.themeError.withValues(alpha: 0.8),
                  ),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  splashRadius: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
