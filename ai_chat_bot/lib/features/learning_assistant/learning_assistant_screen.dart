import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/document_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../chat/widgets/message_list.dart';
import '../chat/widgets/chat_input.dart';
import '../chat/widgets/chat_sidebar.dart';
import '../documents/widgets/documents_panel.dart';
import '../documents/widgets/add_document_dialog.dart';

/// Main 3-panel layout for the LMS AI Assistant
/// Left: Chat History | Center: Active Chat + Upload Prompt | Right: Documents
class LearningAssistantScreen extends StatefulWidget {
  const LearningAssistantScreen({super.key});

  @override
  State<LearningAssistantScreen> createState() =>
      _LearningAssistantScreenState();
}

class _LearningAssistantScreenState extends State<LearningAssistantScreen> {
  bool _showChatHistory = true;
  bool _showDocuments = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;
    final settingsProvider = context.watch<SettingsProvider>();
    final chatProvider = context.watch<ChatProvider>();

    // Adjust panel visibility based on screen size
    final showLeftPanel = isWideScreen || (isMediumScreen && _showChatHistory);
    final showRightPanel =
        isWideScreen || (isMediumScreen && _showDocuments && !_showChatHistory);

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Chat History
          if (showLeftPanel)
            SizedBox(
              width: isWideScreen ? 280 : 260,
              child: ChatSidebar(
                onNewChat: () {
                  chatProvider.createNewConversation(
                    useRag: settingsProvider.useRag,
                  );
                },
              ),
            ),

          // Center Panel - Active Chat + Upload Prompt
          Expanded(
            child: _buildCenterPanel(context, isMediumScreen, isWideScreen),
          ),

          // Right Panel - Documents
          if (showRightPanel)
            SizedBox(
              width: isWideScreen ? 320 : 300,
              child: const DocumentsPanel(),
            ),
        ],
      ),

      // Mobile drawer for chat history
      drawer: !isMediumScreen
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

      // Mobile drawer for documents
      endDrawer: !isMediumScreen ? const Drawer(child: DocumentsPanel()) : null,
    );
  }

  Widget _buildCenterPanel(
    BuildContext context,
    bool isMediumScreen,
    bool isWideScreen,
  ) {
    final theme = Theme.of(context);
    final chatProvider = context.watch<ChatProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final documentProvider = context.watch<DocumentProvider>();

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          left: BorderSide(color: theme.dividerColor),
          right: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        children: [
          // App bar
          _buildAppBar(
            context,
            isMediumScreen,
            isWideScreen,
            chatProvider,
            documentProvider,
          ),

          // Main content area - Chat or Welcome/Upload prompt
          Expanded(
            child: chatProvider.hasConversation
                ? const MessageList()
                : _buildWelcomeWithUpload(context, documentProvider),
          ),

          // Chat input - always visible
          ChatInput(
            onSend: (message) {
              // Auto-enable RAG when documents exist for better experience
              final shouldUseRag =
                  documentProvider.hasDocuments || settingsProvider.useRag;

              if (!chatProvider.hasConversation) {
                chatProvider.createNewConversation(useRag: shouldUseRag);
              }
              if (settingsProvider.useStreaming) {
                chatProvider.sendMessageStreaming(
                  message,
                  useRag: shouldUseRag,
                );
              } else {
                chatProvider.sendMessage(message, useRag: shouldUseRag);
              }
            },
            isLoading: chatProvider.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    bool isMediumScreen,
    bool isWideScreen,
    ChatProvider chatProvider,
    DocumentProvider documentProvider,
  ) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // Menu button for chat history (mobile)
          if (!isWideScreen && !isMediumScreen)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Chat History',
            ),

          // Toggle chat history panel (medium screen)
          if (isMediumScreen && !isWideScreen)
            IconButton(
              icon: Icon(
                _showChatHistory ? Icons.chat : Icons.chat_outlined,
                color: _showChatHistory ? AppTheme.primaryColor : null,
              ),
              onPressed: () {
                setState(() {
                  _showChatHistory = !_showChatHistory;
                  if (_showChatHistory) _showDocuments = false;
                });
              },
              tooltip: 'Chat History',
            ),

          const SizedBox(width: 8),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatProvider.currentConversation?.title ?? 'LMS AI Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    if (documentProvider.hasDocuments) ...[
                      Text(
                        '${documentProvider.documentCount} documents',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.dividerColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: chatProvider.isConnected
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      chatProvider.isConnected ? 'Connected' : 'Offline',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: chatProvider.isConnected
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RAG toggle
          Tooltip(
            message: documentProvider.hasDocuments
                ? (settingsProvider.useRag
                      ? 'RAG enabled - AI uses your documents'
                      : 'RAG disabled - Click to use documents')
                : 'Upload documents to enable RAG',
            child: IconButton(
              icon: Icon(
                documentProvider.hasDocuments && settingsProvider.useRag
                    ? Icons.library_books
                    : documentProvider.hasDocuments
                    ? Icons.library_books_outlined
                    : Icons.chat_bubble_outline,
                color: documentProvider.hasDocuments && settingsProvider.useRag
                    ? AppTheme.primaryColor
                    : null,
              ),
              onPressed: () => settingsProvider.toggleRag(),
            ),
          ),

          // New chat button
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              chatProvider.createNewConversation(
                useRag: settingsProvider.useRag,
              );
            },
            tooltip: 'New Chat',
          ),

          // Toggle documents panel (medium screen)
          if (isMediumScreen && !isWideScreen)
            IconButton(
              icon: Icon(
                _showDocuments ? Icons.folder : Icons.folder_outlined,
                color: _showDocuments ? AppTheme.primaryColor : null,
              ),
              onPressed: () {
                setState(() {
                  _showDocuments = !_showDocuments;
                  if (_showDocuments) _showChatHistory = false;
                });
              },
              tooltip: 'Documents',
            ),

          // Documents button (mobile)
          if (!isWideScreen && !isMediumScreen)
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Documents',
            ),
        ],
      ),
    );
  }

  /// Welcome screen with upload prompt - shown in center panel when no conversation
  Widget _buildWelcomeWithUpload(
    BuildContext context,
    DocumentProvider provider,
  ) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final chatProvider = context.watch<ChatProvider>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
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
                Icons.school_outlined,
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
              'Your intelligent learning companion',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),

            const SizedBox(height: 40),

            // Show different content based on whether documents exist
            if (!provider.hasDocuments) ...[
              // Upload prompt when no documents
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 48,
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add a document to get started',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload PDF, TXT, HTML, CSV, images, or add URLs to enhance your learning experience',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => AddDocumentDialog.show(
                        context,
                        onDocumentAdded: () => provider.fetchDocuments(),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Or start chatting directly
              Text(
                'or start chatting directly',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ] else ...[
              // Quick prompts when documents exist
              Text(
                'Start a conversation with your documents',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.documentCount} documents loaded',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.successColor,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Quick prompts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickPrompt(
                  context,
                  provider.hasDocuments ? 'Summarize my documents' : 'Hello!',
                  provider.hasDocuments ? Icons.summarize : Icons.waving_hand,
                  chatProvider,
                  settingsProvider,
                ),
                _buildQuickPrompt(
                  context,
                  provider.hasDocuments ? 'Key concepts' : 'What can you do?',
                  provider.hasDocuments
                      ? Icons.lightbulb_outline
                      : Icons.help_outline,
                  chatProvider,
                  settingsProvider,
                ),
                _buildQuickPrompt(
                  context,
                  provider.hasDocuments
                      ? 'Create study notes'
                      : 'Help me learn',
                  provider.hasDocuments
                      ? Icons.note_alt_outlined
                      : Icons.school_outlined,
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

  Widget _buildQuickPrompt(
    BuildContext context,
    String prompt,
    IconData icon,
    ChatProvider chatProvider,
    SettingsProvider settingsProvider,
  ) {
    final documentProvider = context.read<DocumentProvider>();

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(prompt),
      onPressed: () {
        // Auto-enable RAG when documents exist for better experience
        final shouldUseRag =
            documentProvider.hasDocuments || settingsProvider.useRag;

        chatProvider.createNewConversation(useRag: shouldUseRag);
        if (settingsProvider.useStreaming) {
          chatProvider.sendMessageStreaming(prompt, useRag: shouldUseRag);
        } else {
          chatProvider.sendMessage(prompt, useRag: shouldUseRag);
        }
      },
    );
  }
}
