import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document.dart';
import '../services/api_service.dart';

/// Provider for managing document state and operations
class DocumentProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<DocumentInfo> _documents = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  double _uploadProgress = 0.0;

  DocumentProvider({required ApiService apiService}) : _apiService = apiService;

  // Getters
  List<DocumentInfo> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  int get documentCount => _documents.length;
  bool get hasDocuments => _documents.isNotEmpty;

  /// Fetch all documents from the server
  Future<void> fetchDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await _apiService.getDocumentList();
    } catch (e) {
      _error = 'Failed to load documents: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload a document file
  Future<DocumentUploadResult> uploadDocument({
    required PlatformFile file,
    String? documentId,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      // Get file bytes
      final bytes = file.bytes;
      if (bytes == null) {
        return DocumentUploadResult(
          success: false,
          message: 'Failed to read file bytes',
        );
      }

      // Simulate progress (actual progress would require different implementation)
      _uploadProgress = 0.3;
      notifyListeners();

      final result = await _apiService.uploadDocument(
        filePath: file.path ?? '',
        fileName: file.name,
        fileBytes: bytes,
        documentId: documentId,
      );

      _uploadProgress = 1.0;
      notifyListeners();

      if (result.success) {
        // Add the new document to the list
        final docInfo = result.toDocumentInfo();
        if (docInfo != null) {
          _documents.insert(0, docInfo);
        }
      } else {
        _error = result.message;
      }

      return result;
    } catch (e) {
      _error = 'Upload failed: $e';
      return DocumentUploadResult(success: false, message: 'Upload failed: $e');
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  /// Upload multiple documents
  Future<List<DocumentUploadResult>> uploadMultipleDocuments({
    required List<PlatformFile> files,
  }) async {
    final results = <DocumentUploadResult>[];

    for (final file in files) {
      final result = await uploadDocument(file: file);
      results.add(result);
    }

    return results;
  }

  /// Scrape content from a URL
  Future<DocumentUploadResult> scrapeUrl(String url) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.scrapeUrl(url: url);

      if (result.success) {
        // Add the new document to the list
        final docInfo = result.toDocumentInfo();
        if (docInfo != null) {
          _documents.insert(0, docInfo);
        }
      } else {
        _error = result.message;
      }

      return result;
    } catch (e) {
      _error = 'Scrape failed: $e';
      return DocumentUploadResult(success: false, message: 'Scrape failed: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final success = await _apiService.deleteDocument(documentId);

      if (success) {
        _documents.removeWhere((doc) => doc.documentId == documentId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = 'Delete failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Pick and upload files using file picker
  Future<List<DocumentUploadResult>?> pickAndUploadFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: SupportedFileTypes.all,
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      return uploadMultipleDocuments(files: result.files);
    } catch (e) {
      _error = 'File picker error: $e';
      notifyListeners();
      return null;
    }
  }

  /// Pick and upload a single file
  Future<DocumentUploadResult?> pickAndUploadSingleFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: SupportedFileTypes.all,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      return uploadDocument(file: result.files.first);
    } catch (e) {
      _error = 'File picker error: $e';
      notifyListeners();
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh documents
  Future<void> refresh() => fetchDocuments();

  /// Get documents by type
  List<DocumentInfo> getDocumentsByType(DocumentType type) {
    return _documents.where((doc) => doc.documentType == type).toList();
  }

  /// Search documents by filename
  List<DocumentInfo> searchDocuments(String query) {
    if (query.isEmpty) return _documents;
    final lowerQuery = query.toLowerCase();
    return _documents.where((doc) {
      return doc.filename.toLowerCase().contains(lowerQuery) ||
          doc.documentId.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
