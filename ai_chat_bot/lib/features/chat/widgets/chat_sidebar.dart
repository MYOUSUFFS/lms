import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          right: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
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
                // Cyberpunk logo and title
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.neonPink, AppTheme.primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
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
                            text: 'LMS CHAT',
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            glowIntensity: 0.8,
                          ),
                          Text(
                            'v2.0 NEURAL',
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              color: AppTheme.textSecondaryDark,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.neonPink.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppTheme.neonPink.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        onPressed: onOpenSettings,
                        icon: const Icon(
                          Icons.tune,
                          color: AppTheme.neonPink,
                          size: 20,
                        ),
                        tooltip: 'SETTINGS',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Cyberpunk new chat button
                SizedBox(
                  width: double.infinity,
                  child: CyberpunkButton(
                    text: 'NEW SESSION',
                    icon: Icons.add,
                    color: AppTheme.primaryColor,
                    filled: true,
                    onPressed: onNewChat,
                  ),
                ),
              ],
            ),
          ),

          // Cyberpunk divider
          CyberpunkDivider(color: AppTheme.primaryColor),

          // Conversations list
          Expanded(
            child: chatProvider.conversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: chatProvider.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = chatProvider.conversations[index];
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
          const CyberpunkDivider(color: AppTheme.textSecondaryDark),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.storage_outlined,
                  size: 14,
                  color: AppTheme.textSecondaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${chatProvider.conversations.length} SESSIONS',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      color: AppTheme.textSecondaryDark,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (chatProvider.conversations.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showClearAllDialog(context, chatProvider),
                    child: Text(
                      'PURGE ALL',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: AppTheme.errorColor,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            NeonText(
              text: 'NO SESSIONS',
              color: AppTheme.textSecondaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              glowIntensity: 0.3,
            ),
            const SizedBox(height: 8),
            Text(
              'Initialize new session to begin',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.7),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.5)),
        ),
        title: NeonText(
          text: 'TERMINATE SESSION',
          color: AppTheme.errorColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          glowIntensity: 0.8,
        ),
        content: Text(
          'This action will permanently delete the session data.',
          style: GoogleFonts.rajdhani(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          CyberpunkButton(
            text: 'Cancel',
            color: AppTheme.textSecondaryDark,
            onPressed: () => Navigator.pop(context),
          ),
          CyberpunkButton(
            text: 'Terminate',
            color: AppTheme.errorColor,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.5)),
        ),
        title: NeonText(
          text: 'PURGE ALL DATA',
          color: AppTheme.errorColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          glowIntensity: 0.8,
        ),
        content: Text(
          'WARNING: This will permanently erase all session data. This action cannot be reversed.',
          style: GoogleFonts.rajdhani(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          CyberpunkButton(
            text: 'Abort',
            color: AppTheme.textSecondaryDark,
            onPressed: () => Navigator.pop(context),
          ),
          CyberpunkButton(
            text: 'Purge',
            color: AppTheme.errorColor,
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
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : _isHovered
                ? AppTheme.primaryColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.6)
                  : _isHovered
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Cyberpunk icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.useRag
                      ? AppTheme.neonPurple.withValues(alpha: 0.2)
                      : AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  widget.useRag ? Icons.memory : Icons.terminal,
                  size: 14,
                  color: widget.useRag
                      ? AppTheme.neonPurple
                      : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title.toUpperCase(),
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: widget.isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimaryDark,
                        letterSpacing: 0.5,
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
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              color: AppTheme.textSecondaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          widget.time,
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            color: AppTheme.textSecondaryDark,
                            letterSpacing: 0.5,
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
                    color: AppTheme.errorColor.withValues(alpha: 0.8),
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
