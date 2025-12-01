import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/message_list.dart';
import '../widgets/chat_input.dart';
import '../widgets/settings_drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showSidebar = true;

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isWideScreen = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const SettingsDrawer(),
      body: Row(
        children: [
          // Sidebar
          if (isWideScreen && _showSidebar)
            SizedBox(
              width: 280,
              child: ChatSidebar(
                onNewChat: () => chatProvider.createNewConversation(
                  useRag: settingsProvider.useRag,
                ),
              ),
            ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // App bar
                _buildAppBar(context, isWideScreen, chatProvider),

                // Messages or welcome screen
                Expanded(
                  child: chatProvider.hasConversation
                      ? const MessageList()
                      : _buildWelcomeScreen(
                          context,
                          chatProvider,
                          settingsProvider,
                        ),
                ),

                // Input area
                if (chatProvider.hasConversation)
                  ChatInput(
                    onSend: (message) {
                      if (settingsProvider.useStreaming) {
                        chatProvider.sendMessageStreaming(
                          message,
                          useRag: settingsProvider.useRag,
                        );
                      } else {
                        chatProvider.sendMessage(
                          message,
                          useRag: settingsProvider.useRag,
                        );
                      }
                    },
                    isLoading: chatProvider.isLoading,
                  ),
              ],
            ),
          ),
        ],
      ),
      // Mobile drawer
      drawer: !isWideScreen
          ? Drawer(
              child: ChatSidebar(
                onNewChat: () {
                  chatProvider.createNewConversation(
                    useRag: settingsProvider.useRag,
                  );
                  Navigator.pop(context);
                },
              ),
            )
          : null,
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    bool isWideScreen,
    ChatProvider chatProvider,
  ) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          // Menu button for mobile
          if (!isWideScreen)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),

          // Toggle sidebar on desktop
          if (isWideScreen)
            IconButton(
              icon: Icon(_showSidebar ? Icons.menu_open : Icons.menu),
              onPressed: () {
                setState(() {
                  _showSidebar = !_showSidebar;
                });
              },
              tooltip: _showSidebar ? 'Hide sidebar' : 'Show sidebar',
            ),

          const SizedBox(width: 8),

          // Title
          Expanded(
            child: Text(
              chatProvider.currentConversation?.title ?? 'LMS AI Assistant',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Connection status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: chatProvider.isConnected
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: chatProvider.isConnected
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  chatProvider.isConnected ? 'Connected' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: chatProvider.isConnected
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // RAG toggle
          Tooltip(
            message: settingsProvider.useRag
                ? 'Using document context (RAG)'
                : 'Direct chat mode',
            child: IconButton(
              icon: Icon(
                settingsProvider.useRag
                    ? Icons.library_books
                    : Icons.chat_bubble_outline,
                color: settingsProvider.useRag ? AppTheme.primaryColor : null,
              ),
              onPressed: () => settingsProvider.toggleRag(),
            ),
          ),

          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(
    BuildContext context,
    ChatProvider chatProvider,
    SettingsProvider settingsProvider,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 40,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'LMS AI Assistant',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your intelligent learning management companion',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Mode cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildModeCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Direct Chat',
                  description: 'Ask questions and get AI-powered responses',
                  onTap: () {
                    settingsProvider.setUseRag(false);
                    chatProvider.createNewConversation(useRag: false);
                  },
                ),
                _buildModeCard(
                  context,
                  icon: Icons.library_books_outlined,
                  title: 'Document Q&A',
                  description: 'Query your uploaded documents with RAG',
                  onTap: () {
                    settingsProvider.setUseRag(true);
                    chatProvider.createNewConversation(useRag: true);
                  },
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Quick prompts
            Text(
              'Try asking:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPromptChip(
                  context,
                  'Explain machine learning',
                  chatProvider,
                  settingsProvider,
                ),
                _buildPromptChip(
                  context,
                  'What is deep learning?',
                  chatProvider,
                  settingsProvider,
                ),
                _buildPromptChip(
                  context,
                  'Help me study algorithms',
                  chatProvider,
                  settingsProvider,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptChip(
    BuildContext context,
    String prompt,
    ChatProvider chatProvider,
    SettingsProvider settingsProvider,
  ) {
    return ActionChip(
      label: Text(prompt),
      onPressed: () {
        chatProvider.createNewConversation(useRag: settingsProvider.useRag);
        if (settingsProvider.useStreaming) {
          chatProvider.sendMessageStreaming(
            prompt,
            useRag: settingsProvider.useRag,
          );
        } else {
          chatProvider.sendMessage(prompt, useRag: settingsProvider.useRag);
        }
      },
    );
  }
}
