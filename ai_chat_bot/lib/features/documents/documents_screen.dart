import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/document.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/theme/app_theme.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch documents when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().fetchDocuments();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: documentProvider.isLoading
                ? null
                : () => documentProvider.fetchDocuments(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Upload section
          _buildUploadSection(context, documentProvider),

          const Divider(height: 1),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Document list
          Expanded(child: _buildDocumentList(context, documentProvider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: documentProvider.isUploading
            ? null
            : () => _showUploadDialog(context, documentProvider),
        icon: const Icon(Icons.add),
        label: const Text('Add Document'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context, DocumentProvider provider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supported File Types',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFileTypeChip('📄 PDF', 'PDF documents'),
              _buildFileTypeChip('📝 TXT/MD', 'Text & Markdown'),
              _buildFileTypeChip('🌐 HTML', 'HTML files'),
              _buildFileTypeChip('📊 CSV/Excel', 'Spreadsheets'),
              _buildFileTypeChip('🖼️ Images', 'OCR supported'),
              _buildFileTypeChip('🔗 URLs', 'Web scraping'),
            ],
          ),

          // Progress indicator
          if (provider.isUploading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: provider.uploadProgress > 0
                  ? provider.uploadProgress
                  : null,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text('Uploading...', style: theme.textTheme.bodySmall),
          ],

          // Error message
          if (provider.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: provider.clearError,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileTypeChip(String label, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
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
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return _buildDocumentTile(context, documents[index], provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DocumentProvider provider) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No documents found'
                  : 'No documents yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Upload documents to start using RAG',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_searchQuery.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => provider.pickAndUploadFiles(),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Files'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showUrlDialog(context, provider),
                    icon: const Icon(Icons.link),
                    label: const Text('Add URL'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(
    BuildContext context,
    DocumentInfo document,
    DocumentProvider provider,
  ) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(document.documentId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text(
              'Are you sure you want to delete "${document.filename}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.deleteDocument(document.documentId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${document.filename} deleted')));
      },
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getDocumentTypeColor(
              document.documentType,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              document.documentType.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          document.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            _buildStatusChip(document.status),
            const SizedBox(width: 8),
            Text(
              '${document.chunksCount} chunks',
              style: theme.textTheme.bodySmall,
            ),
            if (document.createdAt != null) ...[
              const SizedBox(width: 8),
              Text(
                _formatDate(document.createdAt!),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleDocumentAction(context, value, document, provider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Details'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: AppTheme.errorColor),
                title: Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _showDocumentDetails(context, document),
      ),
    );
  }

  Widget _buildStatusChip(ProcessingStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleDocumentAction(
    BuildContext context,
    String action,
    DocumentInfo document,
    DocumentProvider provider,
  ) {
    switch (action) {
      case 'info':
        _showDocumentDetails(context, document);
        break;
      case 'delete':
        _confirmDelete(context, document, provider);
        break;
    }
  }

  void _showDocumentDetails(BuildContext context, DocumentInfo document) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  document.documentType.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    document.filename,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Document ID', document.documentId),
            _buildDetailRow('Type', document.documentType.displayName),
            _buildDetailRow('Status', document.status.displayName),
            _buildDetailRow('Chunks', '${document.chunksCount}'),
            if (document.createdAt != null)
              _buildDetailRow(
                'Created',
                '${document.createdAt!.day}/${document.createdAt!.month}/${document.createdAt!.year}',
              ),
            if (document.url != null) _buildDetailRow('URL', document.url!),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
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

  void _showUploadDialog(BuildContext context, DocumentProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Document',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildUploadOption(
                    context,
                    icon: Icons.upload_file,
                    label: 'Upload Files',
                    description: 'PDF, TXT, HTML, CSV, Images',
                    onTap: () {
                      Navigator.pop(context);
                      provider.pickAndUploadFiles();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUploadOption(
                    context,
                    icon: Icons.link,
                    label: 'Add URL',
                    description: 'Scrape web content',
                    onTap: () {
                      Navigator.pop(context);
                      _showUrlDialog(context, provider);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog(BuildContext context, DocumentProvider provider) {
    _urlController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a URL to scrape content from a webpage',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = _urlController.text.trim();
              if (url.isEmpty) return;

              Navigator.pop(context);

              final result = await provider.scrapeUrl(url);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.success
                          ? 'URL scraped successfully!'
                          : 'Failed: ${result.message}',
                    ),
                    backgroundColor: result.success
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Scrape'),
          ),
        ],
      ),
    );
  }
}
