import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/document_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/cyberpunk_widgets.dart';
import '../chat/widgets/message_list.dart';
import '../chat/widgets/chat_input.dart';
import '../chat/widgets/chat_sidebar.dart';
import '../chat/widgets/settings_drawer.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: _scaffoldKey,
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
                onOpenSettings: () {
                  _scaffoldKey.currentState?.openEndDrawer();
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
                onOpenSettings: () {
                  Navigator.pop(context);
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            )
          : null,

      // Settings drawer (and documents on mobile)
      endDrawer: const SettingsDrawer(),
    );
  }

  Widget _buildCenterPanel(
    BuildContext context,
    bool isMediumScreen,
    bool isWideScreen,
  ) {
    final chatProvider = context.watch<ChatProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final documentProvider = context.watch<DocumentProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          left: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          right: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Stack(
        children: [
          // Background grid pattern for cyberpunk effect
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          // Main content
          Column(
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
                child:
                    chatProvider.hasConversation &&
                        chatProvider.currentMessages.isNotEmpty
                    ? const MessageList()
                    : _buildWelcomeWithUpload(context, documentProvider),
              ),

              // Chat input - always visible
              ChatInput(
                onSend: (message) {
                  // Use the user's RAG setting from settings
                  final shouldUseRag = settingsProvider.useRag;

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
    final settingsProvider = context.watch<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu button for chat history (mobile)
          if (!isWideScreen && !isMediumScreen)
            _buildCyberpunkIconButton(
              icon: Icons.menu,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              tooltip: 'Chat History',
            ),

          // Toggle chat history panel (medium screen)
          if (isMediumScreen && !isWideScreen)
            _buildCyberpunkIconButton(
              icon: _showChatHistory ? Icons.chat : Icons.chat_outlined,
              onPressed: () {
                setState(() {
                  _showChatHistory = !_showChatHistory;
                  if (_showChatHistory) _showDocuments = false;
                });
              },
              tooltip: 'Chat History',
              isActive: _showChatHistory,
            ),

          const SizedBox(width: 8),

          // Title with cyberpunk styling
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatProvider.currentConversation?.title ?? 'NEURAL LINK',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (documentProvider.hasDocuments) ...[
                      Text(
                        '${documentProvider.documentCount} DOCS',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondaryDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    CyberpunkStatusIndicator(
                      isActive: chatProvider.isConnected,
                      size: 6,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      chatProvider.isConnected ? 'ONLINE' : 'OFFLINE',
                      style: GoogleFonts.rajdhani(
                        color: chatProvider.isConnected
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RAG toggle with cyberpunk style
          _buildCyberpunkIconButton(
            icon: settingsProvider.useRag
                ? Icons.memory
                : Icons.chat_bubble_outline,
            onPressed: () => settingsProvider.toggleRag(),
            tooltip: settingsProvider.useRag
                ? 'RAG ENABLED - USING DOCUMENTS'
                : 'RAG DISABLED - CLICK TO ENABLE',
            isActive: settingsProvider.useRag,
            activeColor: AppTheme.neonPurple,
          ),

          // New chat button
          _buildCyberpunkIconButton(
            icon: Icons.add_comment_outlined,
            onPressed: () {
              chatProvider.createNewConversation(
                useRag: settingsProvider.useRag,
              );
            },
            tooltip: 'NEW SESSION',
            activeColor: AppTheme.neonPink,
          ),

          // Toggle documents panel (medium screen)
          if (isMediumScreen && !isWideScreen)
            _buildCyberpunkIconButton(
              icon: _showDocuments ? Icons.folder : Icons.folder_outlined,
              onPressed: () {
                setState(() {
                  _showDocuments = !_showDocuments;
                  if (_showDocuments) _showChatHistory = false;
                });
              },
              tooltip: 'Documents',
              isActive: _showDocuments,
            ),

          // Documents button (mobile)
          if (!isWideScreen && !isMediumScreen)
            _buildCyberpunkIconButton(
              icon: Icons.folder_outlined,
              onPressed: () => _showDocumentsBottomSheet(context),
              tooltip: 'Documents',
            ),

          // Settings button (mobile)
          if (!isWideScreen && !isMediumScreen)
            _buildCyberpunkIconButton(
              icon: Icons.settings_outlined,
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              tooltip: 'Settings',
            ),
        ],
      ),
    );
  }

  Widget _buildCyberpunkIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isActive = false,
    Color? activeColor,
  }) {
    final color = isActive
        ? (activeColor ?? AppTheme.primaryColor)
        : AppTheme.textSecondaryDark;

    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: IconButton(
          icon: Icon(icon, color: color, size: 20),
          onPressed: onPressed,
          splashRadius: 20,
        ),
      ),
    );
  }

  /// Welcome screen with upload prompt - shown in center panel when no conversation
  Widget _buildWelcomeWithUpload(
    BuildContext context,
    DocumentProvider provider,
  ) {
    final settingsProvider = context.watch<SettingsProvider>();
    final chatProvider = context.watch<ChatProvider>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cyberpunk Logo with glow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.neonPink, AppTheme.primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppTheme.neonPink.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_outlined,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Glowing title
            NeonText(
              text: 'NEURAL LINK',
              color: AppTheme.primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              glowIntensity: 1.2,
            ),

            const SizedBox(height: 8),

            Text(
              'AI-POWERED LEARNING INTERFACE',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppTheme.textSecondaryDark,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 48),

            // Show different content based on whether documents exist
            if (!provider.hasDocuments) ...[
              // Upload prompt when no documents
              CyberpunkContainer(
                glowColor: AppTheme.neonPink,
                glowIntensity: 0.7,
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.neonPink.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: AppTheme.neonPink.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    NeonText(
                      text: 'UPLOAD DATA',
                      color: AppTheme.neonPink,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Initialize neural network with your documents\nPDF • TXT • HTML • CSV • IMAGES • URLs',
                      style: GoogleFonts.rajdhani(
                        color: AppTheme.textSecondaryDark,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CyberpunkButton(
                      text: 'Add Document',
                      icon: Icons.add,
                      color: AppTheme.neonPink,
                      filled: true,
                      onPressed: () => AddDocumentDialog.show(
                        context,
                        onDocumentAdded: () => provider.fetchDocuments(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Cyberpunk divider
              const SizedBox(
                width: 200,
                child: CyberpunkDivider(color: AppTheme.textSecondaryDark),
              ),

              const SizedBox(height: 16),

              Text(
                'OR INITIATE DIRECT LINK',
                style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondaryDark.withValues(alpha: 0.6),
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ] else ...[
              // Status when documents exist
              CyberpunkContainer(
                glowColor: AppTheme.successColor,
                glowIntensity: 0.5,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CyberpunkStatusIndicator(isActive: true),
                    const SizedBox(width: 12),
                    Text(
                      '${provider.documentCount} DOCUMENTS LOADED',
                      style: GoogleFonts.rajdhani(
                        color: AppTheme.successColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NEURAL NETWORK READY',
                style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondaryDark,
                  fontSize: 12,
                  letterSpacing: 3,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Quick prompts with cyberpunk styling
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildCyberpunkPrompt(
                  context,
                  provider.hasDocuments ? 'ANALYZE DATA' : 'INITIALIZE',
                  provider.hasDocuments
                      ? Icons.analytics_outlined
                      : Icons.power_settings_new,
                  chatProvider,
                  settingsProvider,
                  AppTheme.primaryColor,
                ),
                _buildCyberpunkPrompt(
                  context,
                  provider.hasDocuments ? 'EXTRACT INFO' : 'CAPABILITIES',
                  provider.hasDocuments
                      ? Icons.lightbulb_outline
                      : Icons.help_outline,
                  chatProvider,
                  settingsProvider,
                  AppTheme.neonPurple,
                ),
                _buildCyberpunkPrompt(
                  context,
                  provider.hasDocuments ? 'GENERATE NOTES' : 'BEGIN LEARNING',
                  provider.hasDocuments
                      ? Icons.edit_note
                      : Icons.school_outlined,
                  chatProvider,
                  settingsProvider,
                  AppTheme.neonPink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberpunkPrompt(
    BuildContext context,
    String prompt,
    IconData icon,
    ChatProvider chatProvider,
    SettingsProvider settingsProvider,
    Color color,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final shouldUseRag = settingsProvider.useRag;
          chatProvider.createNewConversation(useRag: shouldUseRag);
          if (settingsProvider.useStreaming) {
            chatProvider.sendMessageStreaming(prompt, useRag: shouldUseRag);
          } else {
            chatProvider.sendMessage(prompt, useRag: shouldUseRag);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                prompt,
                style: GoogleFonts.rajdhani(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar with cyberpunk styling
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.neonPink, AppTheme.primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              // Documents panel
              const Expanded(child: DocumentsPanel()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid pattern painter for cyberpunk background effect
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
