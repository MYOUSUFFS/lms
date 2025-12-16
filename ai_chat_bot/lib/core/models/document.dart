// Document models for LMS RAG Backend

/// Document types supported by the system
enum DocumentType { pdf, txt, html, csv, image, url }

/// Processing status for documents
enum ProcessingStatus { pending, processing, completed, failed }

/// Extension methods for DocumentType
extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.txt:
        return 'Text/Markdown';
      case DocumentType.html:
        return 'HTML';
      case DocumentType.csv:
        return 'CSV/Excel';
      case DocumentType.image:
        return 'Image (OCR)';
      case DocumentType.url:
        return 'Web Page';
    }
  }

  String get icon {
    switch (this) {
      case DocumentType.pdf:
        return '📄';
      case DocumentType.txt:
        return '📝';
      case DocumentType.html:
        return '🌐';
      case DocumentType.csv:
        return '📊';
      case DocumentType.image:
        return '🖼️';
      case DocumentType.url:
        return '🔗';
    }
  }

  static DocumentType fromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return DocumentType.pdf;
      case 'txt':
      case 'md':
      case 'markdown':
        return DocumentType.txt;
      case 'html':
      case 'htm':
        return DocumentType.html;
      case 'csv':
      case 'xlsx':
      case 'xls':
        return DocumentType.csv;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'webp':
        return DocumentType.image;
      default:
        return DocumentType.txt;
    }
  }
}

/// Extension methods for ProcessingStatus
extension ProcessingStatusExtension on ProcessingStatus {
  String get displayName {
    switch (this) {
      case ProcessingStatus.pending:
        return 'Pending';
      case ProcessingStatus.processing:
        return 'Processing';
      case ProcessingStatus.completed:
        return 'Completed';
      case ProcessingStatus.failed:
        return 'Failed';
    }
  }

  bool get isCompleted => this == ProcessingStatus.completed;
  bool get isFailed => this == ProcessingStatus.failed;
  bool get isProcessing => this == ProcessingStatus.processing;
  bool get isPending => this == ProcessingStatus.pending;
}

/// Document information model
class DocumentInfo {
  final String documentId;
  final String filename;
  final DocumentType documentType;
  final ProcessingStatus status;
  final int chunksCount;
  final DateTime? createdAt;
  final String? url;
  final String? classroomId; // Add classroom context

  // Add getter for id to match usage
  String get id => documentId;

  DocumentInfo({
    required this.documentId,
    required this.filename,
    required this.documentType,
    required this.status,
    this.chunksCount = 0,
    this.createdAt,
    this.url,
    this.classroomId,
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      documentId: json['document_id'] as String? ?? '',
      filename: json['filename'] as String? ?? 'Unknown',
      documentType: _parseDocumentType(json['document_type']),
      status: _parseProcessingStatus(json['status']),
      chunksCount: json['chunks_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      url: json['url'] as String?,
      classroomId: json['classroom_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'filename': filename,
      'document_type': documentType.name,
      'status': status.name,
      'chunks_count': chunksCount,
      'created_at': createdAt?.toIso8601String(),
      'url': url,
      'classroom_id': classroomId,
    };
  }

  static DocumentType _parseDocumentType(dynamic type) {
    if (type == null) return DocumentType.txt;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'pdf':
        return DocumentType.pdf;
      case 'html':
        return DocumentType.html;
      case 'csv':
        return DocumentType.csv;
      case 'image':
        return DocumentType.image;
      case 'url':
        return DocumentType.url;
      default:
        return DocumentType.txt;
    }
  }

  static ProcessingStatus _parseProcessingStatus(dynamic status) {
    if (status == null) return ProcessingStatus.pending;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'completed':
        return ProcessingStatus.completed;
      case 'processing':
        return ProcessingStatus.processing;
      case 'failed':
        return ProcessingStatus.failed;
      default:
        return ProcessingStatus.pending;
    }
  }
}

/// Result of document upload operation
class DocumentUploadResult {
  final bool success;
  final String? documentId;
  final String? filename;
  final DocumentType? documentType;
  final ProcessingStatus? status;
  final String message;
  final int chunksCreated;
  final String? url;
  final String? classroomId;

  DocumentUploadResult({
    required this.success,
    this.documentId,
    this.filename,
    this.documentType,
    this.status,
    required this.message,
    this.chunksCreated = 0,
    this.url,
    this.classroomId,
  });

  DocumentInfo? toDocumentInfo() {
    if (!success || documentId == null) return null;
    return DocumentInfo(
      documentId: documentId!,
      filename: filename ?? 'Unknown',
      documentType: documentType ?? DocumentType.txt,
      status: status ?? ProcessingStatus.completed,
      chunksCount: chunksCreated,
      createdAt: DateTime.now(),
      url: url,
      classroomId: classroomId,
    );
  }
}

/// Supported file extensions for upload
class SupportedFileTypes {
  static const List<String> all = [
    // PDF
    'pdf',
    // Text/Markdown
    'txt', 'md', 'markdown',
    // HTML
    'html', 'htm',
    // CSV/Excel
    'csv', 'xlsx', 'xls',
    // Images (for OCR)
    'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp',
  ];

  static const List<String> pdf = ['pdf'];
  static const List<String> text = ['txt', 'md', 'markdown'];
  static const List<String> html = ['html', 'htm'];
  static const List<String> csv = ['csv', 'xlsx', 'xls'];
  static const List<String> image = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'bmp',
    'webp',
  ];

  static bool isSupported(String extension) {
    return all.contains(extension.toLowerCase());
  }

  static DocumentType getType(String extension) {
    return DocumentTypeExtension.fromExtension(extension);
  }

  static String get filePickerFilter {
    return all.map((e) => '.$e').join(',');
  }
}
