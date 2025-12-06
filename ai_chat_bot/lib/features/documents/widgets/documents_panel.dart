import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
      context.read<DocumentProvider>().fetchDocuments();
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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          left: BorderSide(color: AppTheme.neonPurple.withValues(alpha: 0.2)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPurple.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.neonPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.neonPurple.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.storage_outlined,
              color: AppTheme.neonPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonText(
                  text: 'DATA VAULT',
                  color: AppTheme.neonPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  glowIntensity: 0.8,
                ),
                Text(
                  '${provider.documentCount} FILES LOADED',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    color: AppTheme.textSecondaryDark,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // Add document button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.neonPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.neonPurple),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonPurple.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => AddDocumentDialog.show(
                context,
                onDocumentAdded: () => provider.fetchDocuments(),
              ),
              icon: const Icon(Icons.add, color: AppTheme.neonPurple, size: 20),
              tooltip: 'ADD FILE',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.rajdhani(
            color: AppTheme.textPrimaryDark,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'SEARCH FILES...',
            hintStyle: GoogleFonts.rajdhani(
              color: AppTheme.textSecondaryDark.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: AppTheme.neonPurple.withValues(alpha: 0.7),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 16,
                      color: AppTheme.errorColor.withValues(alpha: 0.7),
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
          cursorColor: AppTheme.neonPurple,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context, DocumentProvider provider) {
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
                color: AppTheme.neonPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'LOADING DATA...',
              style: GoogleFonts.rajdhani(
                color: AppTheme.neonPurple,
                letterSpacing: 2,
              ),
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
      color: AppTheme.neonPurple,
      backgroundColor: AppTheme.cardDark,
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
                  color: AppTheme.neonPurple.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder_open,
                size: 40,
                color: AppTheme.neonPurple.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            NeonText(
              text: _searchQuery.isNotEmpty ? 'NO RESULTS' : 'VAULT EMPTY',
              color: AppTheme.textSecondaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              glowIntensity: 0.3,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Modify search parameters'
                  : 'Upload files to initialize',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              CyberpunkButton(
                text: 'Add File',
                icon: Icons.add,
                color: AppTheme.neonPurple,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
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
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? typeColor.withValues(alpha: 0.1)
                  : AppTheme.surfaceDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? typeColor.withValues(alpha: 0.6)
                    : AppTheme.textSecondaryDark.withValues(alpha: 0.2),
              ),
              boxShadow: isSelected
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
                // Document type icon with cyberpunk styling
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
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
                        document.filename.toUpperCase(),
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? typeColor
                              : AppTheme.textPrimaryDark,
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
                            '${document.chunksCount} CHUNKS',
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              color: AppTheme.textSecondaryDark,
                              letterSpacing: 1,
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
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        _confirmDelete(context, document, provider),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppTheme.errorColor.withValues(alpha: 0.7),
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
    Color color;
    switch (status) {
      case ProcessingStatus.completed:
        color = AppTheme.successColor;
        break;
      case ProcessingStatus.processing:
        color = AppTheme.warningColor;
        break;
      case ProcessingStatus.failed:
        color = AppTheme.errorColor;
        break;
      case ProcessingStatus.pending:
        color = AppTheme.textSecondaryDark;
        break;
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: status == ProcessingStatus.completed
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.5)),
        ),
        title: NeonText(
          text: 'DELETE FILE',
          color: AppTheme.errorColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          glowIntensity: 0.8,
        ),
        content: Text(
          'Permanently remove "${document.filename}" from vault?',
          style: GoogleFonts.rajdhani(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          CyberpunkButton(
            text: 'Cancel',
            color: AppTheme.textSecondaryDark,
            onPressed: () => Navigator.pop(context),
          ),
          CyberpunkButton(
            text: 'Delete',
            color: AppTheme.errorColor,
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
                    'FILE REMOVED: ${document.filename}',
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.errorColor,
                      letterSpacing: 1,
                    ),
                  ),
                  backgroundColor: AppTheme.cardDark,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
