import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
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
    final isCyberpunk = AppTheme.isCyberpunk;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isCyberpunk
            ? AppTheme.backgroundDark
            : theme.scaffoldBackgroundColor,
        border: Border(
          left: BorderSide(
            color: isCyberpunk
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : theme.dividerColor,
          ),
          right: BorderSide(
            color: isCyberpunk
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : theme.dividerColor,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Background grid pattern for cyberpunk effect
          if (isCyberpunk)
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
                child: chatProvider.hasConversation &&
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
    final isCyberpunk = AppTheme.isCyberpunk;
    final theme = Theme.of(context);
    final accentColor =
        isCyberpunk ? AppTheme.primaryColor : const Color(0xFF6366F1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCyberpunk ? AppTheme.cardDark : theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: isCyberpunk
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : theme.dividerColor,
          ),
        ),
        boxShadow: isCyberpunk
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatProvider.currentConversation?.title ??
                      (isCyberpunk ? 'NEURAL LINK' : 'AI Assistant'),
                  style: isCyberpunk
                      ? GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                          letterSpacing: 1,
                        )
                      : TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isWideScreen && isMediumScreen)
                      if (documentProvider.hasDocuments) ...[
                        Text(
                          isCyberpunk
                              ? '${documentProvider.documentCount} DOCS'
                              : '${documentProvider.documentCount} docs',
                          style: isCyberpunk
                              ? GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                )
                              : TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w500,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isCyberpunk
                                ? AppTheme.textSecondaryDark
                                : Colors.grey,
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
                      chatProvider.isConnected
                          ? (isCyberpunk ? 'ONLINE' : 'Online')
                          : (isCyberpunk ? 'OFFLINE' : 'Offline'),
                      style: isCyberpunk
                          ? GoogleFonts.rajdhani(
                              color: chatProvider.isConnected
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            )
                          : TextStyle(
                              color: chatProvider.isConnected
                                  ? Colors.green[600]
                                  : Colors.red[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RAG toggle
          _buildCyberpunkIconButton(
            icon: settingsProvider.useRag
                ? Icons.memory
                : Icons.chat_bubble_outline,
            onPressed: () => settingsProvider.toggleRag(),
            tooltip: settingsProvider.useRag
                ? (isCyberpunk
                    ? 'RAG ENABLED - USING DOCUMENTS'
                    : 'RAG Enabled - Using Documents')
                : (isCyberpunk
                    ? 'RAG DISABLED - CLICK TO ENABLE'
                    : 'RAG Disabled - Click to Enable'),
            isActive: settingsProvider.useRag,
            activeColor:
                isCyberpunk ? AppTheme.neonPurple : const Color(0xFF8B5CF6),
          ),

          // New chat button
          _buildCyberpunkIconButton(
            icon: Icons.add_comment_outlined,
            onPressed: () {
              chatProvider.createNewConversation(
                useRag: settingsProvider.useRag,
              );
            },
            tooltip: isCyberpunk ? 'NEW SESSION' : 'New Chat',
            activeColor: AppTheme.accentColor,
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

          // Organizations button
          _buildCyberpunkIconButton(
            icon: Icons.business_outlined,
            onPressed: () => Navigator.pushNamed(context, '/organizations'),
            tooltip: isCyberpunk ? 'ORGANIZATIONS' : 'Organizations',
            activeColor: const Color(0xFF10B981),
          ),

          // Classrooms button
          _buildCyberpunkIconButton(
            icon: Icons.class_outlined,
            onPressed: () => Navigator.pushNamed(context, '/classrooms'),
            tooltip: isCyberpunk ? 'CLASSROOMS' : 'Classrooms',
            activeColor: const Color(0xFF3B82F6),
          ),

          // Home/Dashboard button
          _buildCyberpunkIconButton(
            icon: Icons.dashboard_outlined,
            onPressed: () => Navigator.pushNamed(context, '/home'),
            tooltip: isCyberpunk ? 'DASHBOARD' : 'Dashboard',
            activeColor: const Color(0xFFEF4444),
          ),

          // Logout button
          _buildCyberpunkIconButton(
            icon: Icons.logout,
            onPressed: () => _handleLogout(context),
            tooltip: isCyberpunk ? 'LOGOUT' : 'Logout',
            activeColor: Colors.red,
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

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  Widget _buildCyberpunkIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isActive = false,
    Color? activeColor,
  }) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final defaultColor =
        isCyberpunk ? AppTheme.primaryColor : const Color(0xFF6366F1);
    final color = isActive
        ? (activeColor ?? defaultColor)
        : (isCyberpunk ? AppTheme.textSecondaryDark : Colors.grey[600]!);

    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: isCyberpunk
              ? Border.all(
                  color: isActive
                      ? color.withValues(alpha: 0.5)
                      : Colors.transparent,
                )
              : null,
          borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 8),
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
    final isCyberpunk = AppTheme.isCyberpunk;
    final theme = Theme.of(context);
    final accentColor = AppTheme.accentColor;
    final primaryAccent = AppTheme.accentColor;
    final secondaryAccent = AppTheme.secondaryAccent;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with glow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [secondaryAccent, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isCyberpunk ? 16 : 24),
                border: isCyberpunk
                    ? Border.all(
                        color: primaryAccent.withValues(alpha: 0.5),
                        width: 2,
                      )
                    : null,
                boxShadow: isCyberpunk
                    ? [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
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

            // Title
            isCyberpunk
                ? NeonText(
                    text: 'NEURAL LINK',
                    color: primaryAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    glowIntensity: 1.2,
                  )
                : Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),

            const SizedBox(height: 8),

            Text(
              isCyberpunk
                  ? 'AI-POWERED LEARNING INTERFACE'
                  : 'Your intelligent learning companion',
              style: isCyberpunk
                  ? GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppTheme.textSecondaryDark,
                      letterSpacing: 4,
                    )
                  : TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
            ),

            const SizedBox(height: 48),

            // Show different content based on whether documents exist
            if (!provider.hasDocuments) ...[
              // Upload prompt when no documents
              CyberpunkContainer(
                glowColor: accentColor,
                glowIntensity: isCyberpunk ? 0.7 : 0,
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(
                          isCyberpunk ? 8 : 12,
                        ),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: accentColor.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isCyberpunk
                        ? NeonText(
                            text: 'UPLOAD DATA',
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          )
                        : Text(
                            'Upload Documents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                    const SizedBox(height: 12),
                    Text(
                      isCyberpunk
                          ? 'Initialize neural network with your documents\nPDF • TXT • HTML • CSV • IMAGES • URLs'
                          : 'Add your documents to get started\nPDF • TXT • HTML • CSV • Images • URLs',
                      style: isCyberpunk
                          ? GoogleFonts.rajdhani(
                              color: AppTheme.textSecondaryDark,
                              fontSize: 13,
                            )
                          : TextStyle(color: Colors.grey[600], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CyberpunkButton(
                      text: 'Add Document',
                      icon: Icons.add,
                      color: accentColor,
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

              // Divider
              SizedBox(
                width: 200,
                child: isCyberpunk
                    ? const CyberpunkDivider(color: AppTheme.textSecondaryDark)
                    : Divider(color: Colors.grey[300]),
              ),

              const SizedBox(height: 16),

              Text(
                isCyberpunk ? 'OR INITIATE DIRECT LINK' : 'or start chatting',
                style: isCyberpunk
                    ? GoogleFonts.rajdhani(
                        color: AppTheme.textSecondaryDark.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 12,
                        letterSpacing: 2,
                      )
                    : TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ] else ...[
              // Status when documents exist
              CyberpunkContainer(
                glowColor: AppTheme.successColor,
                glowIntensity: isCyberpunk ? 0.5 : 0,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CyberpunkStatusIndicator(isActive: true),
                    const SizedBox(width: 12),
                    Text(
                      isCyberpunk
                          ? '${provider.documentCount} DOCUMENTS LOADED'
                          : '${provider.documentCount} documents loaded',
                      style: isCyberpunk
                          ? GoogleFonts.rajdhani(
                              color: AppTheme.successColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            )
                          : TextStyle(
                              color: Colors.green[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isCyberpunk ? 'NEURAL NETWORK READY' : 'Ready to assist',
                style: isCyberpunk
                    ? GoogleFonts.rajdhani(
                        color: AppTheme.textSecondaryDark,
                        fontSize: 12,
                        letterSpacing: 3,
                      )
                    : TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],

            const SizedBox(height: 32),

            // Quick prompts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildCyberpunkPrompt(
                  context,
                  provider.hasDocuments
                      ? (isCyberpunk ? 'ANALYZE DATA' : 'Analyze Data')
                      : (isCyberpunk ? 'INITIALIZE' : 'Get Started'),
                  provider.hasDocuments
                      ? Icons.analytics_outlined
                      : Icons.power_settings_new,
                  chatProvider,
                  settingsProvider,
                  primaryAccent,
                ),
                _buildCyberpunkPrompt(
                  context,
                  provider.hasDocuments
                      ? (isCyberpunk ? 'EXTRACT INFO' : 'Extract Info')
                      : (isCyberpunk ? 'CAPABILITIES' : 'Capabilities'),
                  provider.hasDocuments
                      ? Icons.lightbulb_outline
                      : Icons.help_outline,
                  chatProvider,
                  settingsProvider,
                  isCyberpunk ? AppTheme.neonPurple : const Color(0xFF8B5CF6),
                ),
                _buildCyberpunkPrompt(
                  context,
                  provider.hasDocuments
                      ? (isCyberpunk ? 'GENERATE NOTES' : 'Generate Notes')
                      : (isCyberpunk ? 'BEGIN LEARNING' : 'Start Learning'),
                  provider.hasDocuments
                      ? Icons.edit_note
                      : Icons.school_outlined,
                  chatProvider,
                  settingsProvider,
                  accentColor,
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
    final isCyberpunk = AppTheme.isCyberpunk;

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
            borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                prompt,
                style: isCyberpunk
                    ? GoogleFonts.rajdhani(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      )
                    : TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentsBottomSheet(BuildContext context) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final theme = Theme.of(context);
    final accentColor = AppTheme.accentColor;
    final primaryAccent = AppTheme.accentColor;

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
            color: isCyberpunk ? AppTheme.cardDark : theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: isCyberpunk
                ? Border.all(color: primaryAccent.withValues(alpha: 0.3))
                : null,
            boxShadow: isCyberpunk
                ? [
                    BoxShadow(
                      color: primaryAccent.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: isCyberpunk
                      ? LinearGradient(colors: [accentColor, primaryAccent])
                      : null,
                  color: isCyberpunk ? null : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isCyberpunk
                      ? [
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
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
