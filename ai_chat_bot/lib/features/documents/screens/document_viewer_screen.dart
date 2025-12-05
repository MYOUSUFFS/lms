import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/models/document.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Document viewer screen that displays different file types
class DocumentViewerScreen extends StatefulWidget {
  final DocumentInfo document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isLoading = true;
  String? _error;
  List<int>? _documentBytes;
  String? _textContent;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<DocumentProvider>().apiService;
      final bytes = await apiService.getDocumentContent(
        widget.document.documentId,
      );

      if (bytes != null) {
        setState(() {
          _documentBytes = bytes;
          _isLoading = false;
        });

        // For text-based documents only (not PDF or images), decode content
        if (!_isPdfDocument() && !_isImageDocument()) {
          if (_isTextBasedDocument() ||
              _isCsvDocument() ||
              _isHtmlDocument() ||
              _isMarkdownDocument()) {
            try {
              _textContent = String.fromCharCodes(bytes);
            } catch (e) {
              // If decoding fails, keep as bytes for binary viewing
            }
          }
        }
      } else {
        setState(() {
          _error = 'Failed to load document';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool _isTextBasedDocument() {
    return widget.document.documentType == DocumentType.txt &&
        !widget.document.filename.toLowerCase().endsWith('.pdf');
  }

  bool _isMarkdownDocument() {
    return !_isPdfDocument() &&
        (widget.document.filename.toLowerCase().endsWith('.md') ||
            widget.document.filename.toLowerCase().endsWith('.markdown'));
  }

  bool _isImageDocument() {
    return widget.document.documentType == DocumentType.image;
  }

  bool _isPdfDocument() {
    return widget.document.documentType == DocumentType.pdf ||
        widget.document.filename.toLowerCase().endsWith('.pdf');
  }

  bool _isCsvDocument() {
    return widget.document.documentType == DocumentType.csv &&
        !widget.document.filename.toLowerCase().endsWith('.pdf');
  }

  bool _isHtmlDocument() {
    return widget.document.documentType == DocumentType.html &&
        !widget.document.filename.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.document.filename,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.document.documentType.displayName,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          if (!_isLoading && _documentBytes != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDocument,
              tooltip: 'Reload',
            ),
          if (!_isLoading && _documentBytes != null && !kIsWeb)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadDocument,
              tooltip: 'Download',
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading document...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDocument,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_documentBytes == null) {
      return const Center(child: Text('No content available'));
    }

    // Display based on document type
    if (_isPdfDocument()) {
      return _buildPdfViewer();
    } else if (_isImageDocument()) {
      return _buildImageViewer();
    } else if (_isCsvDocument() && _textContent != null) {
      return _buildCsvViewer();
    } else if (_isHtmlDocument() && _textContent != null) {
      return _buildHtmlViewer();
    } else if (_isTextBasedDocument() && _textContent != null) {
      if (_isMarkdownDocument()) {
        return _buildMarkdownViewer();
      } else {
        return _buildTextViewer();
      }
    } else {
      return _buildUnsupportedViewer();
    }
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.memory(
      Uint8List.fromList(_documentBytes!),
      enableDoubleTapZooming: true,
      enableTextSelection: true,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load PDF: ${details.error}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      },
    );
  }

  Widget _buildImageViewer() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.memory(
          Uint8List.fromList(_documentBytes!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                const Text('Failed to load image'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextViewer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _textContent!,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      ),
    );
  }

  Widget _buildMarkdownViewer() {
    return Markdown(
      data: _textContent!,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 14),
        code: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor: Colors.black12,
        ),
      ),
    );
  }

  Widget _buildCsvViewer() {
    final lines = _textContent!
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const Center(child: Text('Empty CSV file'));
    }

    // Parse CSV (simple implementation - doesn't handle quoted commas)
    final rows = lines.map((line) => line.split(',')).toList();
    final headers = rows.isNotEmpty ? rows[0] : [];
    final dataRows = rows.length > 1 ? rows.sublist(1) : [];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
            border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.3)),
            columns: headers
                .map(
                  (header) => DataColumn(
                    label: Text(
                      header.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
            rows: dataRows
                .map(
                  (row) => DataRow(
                    cells: row
                        .map((cell) => DataCell(Text(cell.trim())))
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHtmlViewer() {
    // For HTML, render as markdown which supports basic HTML
    return Markdown(
      data: _textContent!,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 14),
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        code: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor: Colors.black12,
        ),
      ),
    );
  }

  Widget _buildUnsupportedViewer() {
    final theme = Theme.of(context);
    final apiService = context.read<DocumentProvider>().apiService;
    final documentUrl = apiService.getDocumentContentUrl(
      widget.document.documentId,
    );

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
                _getDocumentIcon(),
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.document.filename,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.document.documentType.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This file type cannot be displayed in the app.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can download it to view in another application.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (kIsWeb)
              ElevatedButton.icon(
                onPressed: () => _openInNewTab(documentUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in New Tab'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _downloadDocument,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${_documentBytes!.length} bytes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon() {
    switch (widget.document.documentType) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.txt:
        return Icons.description;
      case DocumentType.html:
        return Icons.web;
      case DocumentType.csv:
        return Icons.table_chart;
      case DocumentType.image:
        return Icons.image;
      case DocumentType.url:
        return Icons.link;
    }
  }

  void _openInNewTab(String url) {
    // For web, open in new tab
    if (kIsWeb) {
      // Use url_launcher or window.open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening document: $url'),
          action: SnackBarAction(
            label: 'Copy URL',
            onPressed: () {
              // Copy URL to clipboard
            },
          ),
        ),
      );
    }
  }

  Future<void> _downloadDocument() async {
    if (kIsWeb) {
      // On web, trigger download
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Download started...')));
      // Implement web download logic
    } else {
      // On mobile/desktop, save to file
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download feature coming soon')),
      );
      // Implement native download logic using file_picker or path_provider
    }
  }
}
