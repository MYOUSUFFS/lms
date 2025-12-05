import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/document.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/theme/app_theme.dart';
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
    final theme = Theme.of(context);
    final provider = context.watch<DocumentProvider>();

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documents',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${provider.documentCount} learning materials',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Add document button
          IconButton(
            onPressed: () => AddDocumentDialog.show(
              context,
              onDocumentAdded: () => provider.fetchDocuments(),
            ),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            tooltip: 'Add Document',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search documents...',
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: theme.iconTheme.color?.withValues(alpha: 0.5),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context, DocumentProvider provider) {
    if (provider.isLoading && provider.documents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final documents = _searchQuery.isEmpty
        ? provider.documents
        : provider.searchDocuments(_searchQuery);

    if (documents.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return RefreshIndicator(
      onRefresh: provider.fetchDocuments,
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open,
                size: 40,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'No results found' : 'No documents yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Add learning materials to get started',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => AddDocumentDialog.show(
                  context,
                  onDocumentAdded: () => provider.fetchDocuments(),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
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
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Document type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getDocumentTypeColor(
                      document.documentType,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      document.documentType.icon,
                      style: const TextStyle(fontSize: 20),
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
                        document.filename,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
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
                            '${document.chunksCount} chunks',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete button (on hover or always visible)
                IconButton(
                  onPressed: () => _confirmDelete(context, document, provider),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: theme.iconTheme.color?.withValues(alpha: 0.4),
                  ),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
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
        color = Colors.grey;
        break;
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color _getDocumentTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Colors.red;
      case DocumentType.txt:
        return Colors.blue;
      case DocumentType.html:
        return Colors.orange;
      case DocumentType.csv:
        return Colors.green;
      case DocumentType.image:
        return Colors.purple;
      case DocumentType.url:
        return Colors.teal;
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
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete "${document.filename}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteDocument(document.documentId);
              if (document.documentId == widget.selectedDocumentId) {
                widget.onDocumentSelected?.call(null);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${document.filename} deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
