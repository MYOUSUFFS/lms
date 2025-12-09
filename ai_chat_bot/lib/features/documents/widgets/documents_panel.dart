import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/document.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/cyberpunk_widgets.dart';
import '../screens/document_viewer_screen.dart';
import 'add_document_dialog.dart';

/// Left panel showing list of documents with search and add functionality
class DocumentsPanel extends StatefulWidget {
  final Function(DocumentInfo?)? onDocumentSelected;
  final String? selectedDocumentId;

  const DocumentsPanel({
    super.key,
    this.onDocumentSelected,
    this.selectedDocumentId,
  });

  @override
  State<DocumentsPanel> createState() => _DocumentsPanelState();
}

class _DocumentsPanelState extends State<DocumentsPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DocumentProvider>().fetchDocuments();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentProvider>();
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;

    return Container(
      decoration: BoxDecoration(
        color: isCyberpunk
            ? AppTheme.backgroundDark
            : Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          left: BorderSide(color: accentColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, provider),

          // Search bar
          _buildSearchBar(context),

          // Document list
          Expanded(child: _buildDocumentList(context, provider)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DocumentProvider provider) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCyberpunk ? AppTheme.cardDark : Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: accentColor.withValues(alpha: 0.3)),
        ),
        boxShadow: isCyberpunk
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isCyberpunk ? 6 : 12),
              border: Border.all(color: accentColor.withValues(alpha: 0.5)),
            ),
            child: Icon(Icons.storage_outlined, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonText(
                  text: isCyberpunk ? 'DATA VAULT' : 'Documents',
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  glowIntensity: 0.8,
                ),
                Text(
                  isCyberpunk
                      ? '${provider.documentCount} FILES LOADED'
                      : '${provider.documentCount} files',
                  style: AppTheme.getBodyTextStyle(
                    fontSize: 11,
                    color: AppTheme.themeTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Add document button
          Container(
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
              border: Border.all(color: accentColor),
              boxShadow: isCyberpunk
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              onPressed: () => AddDocumentDialog.show(
                context,
                onDocumentAdded: () => provider.fetchDocuments(),
              ),
              icon: Icon(Icons.add, color: accentColor, size: 20),
              tooltip: isCyberpunk ? 'ADD FILE' : 'Add File',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: isCyberpunk
              ? AppTheme.surfaceDark
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: TextField(
          controller: _searchController,
          style: AppTheme.getBodyTextStyle(
            fontSize: 14,
            color: AppTheme.themeTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: isCyberpunk ? 'SEARCH FILES...' : 'Search files...',
            hintStyle: AppTheme.getBodyTextStyle(
              fontSize: 14,
              color: AppTheme.themeTextSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: accentColor.withValues(alpha: 0.7),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 16,
                      color: AppTheme.themeError.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          cursorColor: accentColor,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context, DocumentProvider provider) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;

    if (provider.isLoading && provider.documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCyberpunk ? 'LOADING DATA...' : 'Loading...',
              style: AppTheme.getBodyTextStyle(color: accentColor),
            ),
          ],
        ),
      );
    }

    final documents = _searchQuery.isEmpty
        ? provider.documents
        : provider.searchDocuments(_searchQuery);

    if (documents.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return RefreshIndicator(
      onRefresh: provider.fetchDocuments,
      color: accentColor,
      backgroundColor: isCyberpunk
          ? AppTheme.cardDark
          : Theme.of(context).cardColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          final isSelected = doc.documentId == widget.selectedDocumentId;
          return _buildDocumentItem(context, doc, isSelected, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DocumentProvider provider) {
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
                Icons.folder_open,
                size: 40,
                color: accentColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            NeonText(
              text: _searchQuery.isNotEmpty
                  ? (isCyberpunk ? 'NO RESULTS' : 'No Results')
                  : (isCyberpunk ? 'VAULT EMPTY' : 'No Documents'),
              color: AppTheme.themeTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              glowIntensity: 0.3,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Modify search parameters'
                  : 'Upload files to initialize',
              style: AppTheme.getBodyTextStyle(
                fontSize: 12,
                color: AppTheme.themeTextSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              CyberpunkButton(
                text: 'Add File',
                icon: Icons.add,
                color: AppTheme.accentColor,
                onPressed: () => AddDocumentDialog.show(
                  context,
                  onDocumentAdded: () => provider.fetchDocuments(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
    BuildContext context,
    DocumentInfo document,
    bool isSelected,
    DocumentProvider provider,
  ) {
    final typeColor = _getDocumentTypeColor(document.documentType);
    final isCyberpunk = AppTheme.isCyberpunk;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
        child: InkWell(
          onTap: () {
            // Open document viewer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentViewerScreen(document: document),
              ),
            );
            // Also notify selection callback if provided
            widget.onDocumentSelected?.call(document);
          },
          borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? typeColor.withValues(alpha: 0.1)
                  : (isCyberpunk
                        ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                        : Theme.of(context).cardColor),
              borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
              border: Border.all(
                color: isSelected
                    ? typeColor.withValues(alpha: 0.6)
                    : AppTheme.themeTextSecondary.withValues(alpha: 0.2),
              ),
              boxShadow: isSelected && isCyberpunk
                  ? [
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Document type icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 8),
                    border: Border.all(color: typeColor.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      document.documentType.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Document info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCyberpunk
                            ? document.filename.toUpperCase()
                            : document.filename,
                        style: AppTheme.getBodyTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? typeColor
                              : AppTheme.themeTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildStatusDot(document.status),
                          const SizedBox(width: 6),
                          Text(
                            isCyberpunk
                                ? '${document.chunksCount} CHUNKS'
                                : '${document.chunksCount} chunks',
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

                // Delete button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.themeError.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 8),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        _confirmDelete(context, document, provider),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppTheme.themeError.withValues(alpha: 0.7),
                    ),
                    tooltip: 'DELETE',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDot(ProcessingStatus status) {
    final isCyberpunk = AppTheme.isCyberpunk;
    Color color;
    switch (status) {
      case ProcessingStatus.completed:
        color = AppTheme.themeSuccess;
        break;
      case ProcessingStatus.processing:
        color = AppTheme.themeWarning;
        break;
      case ProcessingStatus.failed:
        color = AppTheme.themeError;
        break;
      case ProcessingStatus.pending:
        color = AppTheme.themeTextSecondary;
        break;
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: status == ProcessingStatus.completed && isCyberpunk
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Color _getDocumentTypeColor(DocumentType type) {
    final isCyberpunk = AppTheme.isCyberpunk;
    if (!isCyberpunk) {
      // Classic theme colors
      switch (type) {
        case DocumentType.pdf:
          return const Color(0xFFEF4444);
        case DocumentType.txt:
          return AppTheme.primaryColor;
        case DocumentType.html:
          return const Color(0xFFF97316);
        case DocumentType.csv:
          return const Color(0xFF22C55E);
        case DocumentType.image:
          return const Color(0xFF8B5CF6);
        case DocumentType.url:
          return const Color(0xFFEC4899);
      }
    }
    // Cyberpunk neon colors
    switch (type) {
      case DocumentType.pdf:
        return AppTheme.neonRed;
      case DocumentType.txt:
        return AppTheme.primaryColor;
      case DocumentType.html:
        return AppTheme.neonOrange;
      case DocumentType.csv:
        return AppTheme.neonGreen;
      case DocumentType.image:
        return AppTheme.neonPurple;
      case DocumentType.url:
        return AppTheme.neonPink;
    }
  }

  void _confirmDelete(
    BuildContext context,
    DocumentInfo document,
    DocumentProvider provider,
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
          text: isCyberpunk ? 'DELETE FILE' : 'Delete File',
          color: AppTheme.themeError,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          glowIntensity: 0.8,
        ),
        content: Text(
          'Permanently remove "${document.filename}"?',
          style: AppTheme.getBodyTextStyle(color: AppTheme.themeTextSecondary),
        ),
        actions: [
          CyberpunkButton(
            text: 'Cancel',
            color: AppTheme.themeTextSecondary,
            onPressed: () => Navigator.pop(context),
          ),
          CyberpunkButton(
            text: 'Delete',
            color: AppTheme.themeError,
            filled: true,
            onPressed: () {
              Navigator.pop(context);
              provider.deleteDocument(document.documentId);
              if (document.documentId == widget.selectedDocumentId) {
                widget.onDocumentSelected?.call(null);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isCyberpunk
                        ? 'FILE REMOVED: ${document.filename}'
                        : 'File removed: ${document.filename}',
                    style: AppTheme.getBodyTextStyle(
                      color: AppTheme.themeError,
                    ),
                  ),
                  backgroundColor: isCyberpunk ? AppTheme.cardDark : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
