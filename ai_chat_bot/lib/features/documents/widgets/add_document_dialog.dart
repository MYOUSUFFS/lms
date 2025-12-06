import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Add Document Dialog with drag & drop, file upload, paste text, and URL input
class AddDocumentDialog extends StatefulWidget {
  final VoidCallback? onDocumentAdded;

  const AddDocumentDialog({super.key, this.onDocumentAdded});

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onDocumentAdded,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddDocumentDialog(onDocumentAdded: onDocumentAdded),
    );
  }

  @override
  State<AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<AddDocumentDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DocumentProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 560.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Tab Bar
            _buildTabBar(theme),

            // Content
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUploadTab(context, provider),
                  _buildPasteTextTab(context, provider),
                  _buildUrlTab(context, provider),
                ],
              ),
            ),

            // Progress indicator
            if (provider.isUploading) _buildProgressIndicator(provider),

            // Error message
            if (provider.error != null) _buildErrorMessage(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Document',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Upload learning materials to enhance your AI experience',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: theme.textTheme.bodyMedium?.color,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(icon: Icon(Icons.upload_file), text: 'Upload'),
          Tab(icon: Icon(Icons.paste), text: 'Paste Text'),
          Tab(icon: Icon(Icons.link), text: 'Add URL'),
        ],
      ),
    );
  }

  Widget _buildUploadTab(BuildContext context, DocumentProvider provider) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag & Drop Area
          MouseRegion(
            onEnter: (_) => setState(() => _isDragOver = true),
            onExit: (_) => setState(() => _isDragOver = false),
            child: GestureDetector(
              onTap: () => _pickFiles(provider),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _isDragOver
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isDragOver
                        ? AppTheme.primaryColor
                        : theme.dividerColor,
                    width: _isDragOver ? 2 : 1,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: _isDragOver
                          ? AppTheme.primaryColor
                          : theme.iconTheme.color?.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Drag & drop files here',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'or click to browse',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Supported file types
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
              _buildFileTypeChip(context, '📄', 'PDF'),
              _buildFileTypeChip(context, '📝', 'TXT/MD'),
              _buildFileTypeChip(context, '🌐', 'HTML'),
              _buildFileTypeChip(context, '📊', 'CSV/Excel'),
              _buildFileTypeChip(context, '🖼️', 'Images'),
            ],
          ),

          const SizedBox(height: 20),

          // Upload button
          ElevatedButton.icon(
            onPressed: provider.isUploading ? null : () => _pickFiles(provider),
            icon: const Icon(Icons.folder_open),
            label: const Text('Browse Files'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeChip(BuildContext context, String emoji, String label) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildPasteTextTab(BuildContext context, DocumentProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Document Title',
              hintText: 'Enter a title for your document',
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Text area
          TextField(
            controller: _textController,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: 'Content',
              hintText: 'Paste or type your learning material here...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Paste from clipboard button
          OutlinedButton.icon(
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text != null) {
                _textController.text = data!.text!;
              }
            },
            icon: const Icon(Icons.content_paste),
            label: const Text('Paste from Clipboard'),
          ),

          const SizedBox(height: 20),

          // Add button
          ElevatedButton.icon(
            onPressed: provider.isUploading
                ? null
                : () => _addTextDocument(provider),
            icon: const Icon(Icons.add),
            label: const Text('Add Document'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlTab(BuildContext context, DocumentProvider provider) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // URL input
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Website URL',
              hintText: 'https://example.com/article',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 16),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The AI will scrape and process the content from the provided URL to use as learning material.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Add button
          ElevatedButton.icon(
            onPressed: provider.isUploading ? null : () => _addUrl(provider),
            icon: const Icon(Icons.download),
            label: const Text('Fetch Content'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(DocumentProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: provider.uploadProgress > 0 ? provider.uploadProgress : null,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          const Text('Processing document...'),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(DocumentProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.error!,
              style: const TextStyle(color: AppTheme.errorColor),
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
    );
  }

  Future<void> _pickFiles(DocumentProvider provider) async {
    final results = await provider.pickAndUploadFiles();

    if (results == null) return;

    if (!mounted) return;

    final successCount = results.where((r) => r.success).length;

    if (successCount > 0) {
      widget.onDocumentAdded?.call();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount == 1
                  ? 'Document added successfully!'
                  : '$successCount documents added successfully!',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Future<void> _addTextDocument(DocumentProvider provider) async {
    final title = _titleController.text.trim();
    final content = _textController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a document title'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some content'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Todo: Implement text document upload via API
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text document feature coming soon!'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  Future<void> _addUrl(DocumentProvider provider) async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a URL'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid URL starting with http:// or https://',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final result = await provider.scrapeUrl(url);

    if (!mounted) return;

    if (result.success) {
      widget.onDocumentAdded?.call();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL content added successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}
