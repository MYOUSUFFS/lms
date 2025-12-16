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
  String? _currentClassroomId; // Add classroom context

  DocumentProvider({required ApiService apiService}) : _apiService = apiService;

  // Getters
  ApiService get apiService => _apiService;
  
  // Get documents filtered by current classroom context
  List<DocumentInfo> get documents {
    print('=== Getting documents ===');
    print('Current classroom ID: $_currentClassroomId');
    print('Total documents in _documents: ${_documents.length}');
    
    if (_currentClassroomId == null) {
      print('No filter - returning all ${_documents.length} documents');
      return _documents;
    }
    
    final filtered = _documents.where((doc) {
      print('Doc: ${doc.filename}, classroomId: ${doc.classroomId}');
      return doc.classroomId == _currentClassroomId;
    }).toList();
    
    print('Filtered to ${filtered.length} documents for classroom $_currentClassroomId');
    return filtered;
  }
  
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  int get documentCount => documents.length;
  bool get hasDocuments => documents.isNotEmpty;
  String? get currentClassroomId => _currentClassroomId;

  /// Set classroom context for documents
  void setClassroomContext(String classroomId) {
    _currentClassroomId = classroomId;
    notifyListeners();
  }

  /// Load documents for specific classroom
  Future<void> loadDocuments({String? classroomId}) async {
    _currentClassroomId = classroomId ?? _currentClassroomId;
    await fetchDocuments();
  }

  /// Fetch all documents from the server
  /// Filtering by classroom is done in the documents getter
  Future<void> fetchDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allDocs = await _apiService.getDocumentList();
      _documents = allDocs;
    } catch (e) {
      _error = 'Failed to load documents: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload a document file with optional classroom context
  Future<DocumentUploadResult> uploadDocument({
    required PlatformFile file,
    String? documentId,
    String? classroomId,
    String? filePath,
    String? filename,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      // Get file bytes - on web, bytes are required since path is not available
      final bytes = file.bytes;
      if (bytes == null) {
        return DocumentUploadResult(
          success: false,
          message: 'Failed to read file bytes. Please try again.',
        );
      }

      // Simulate progress
      _uploadProgress = 0.3;
      notifyListeners();

      // Get file path safely - on web, path is not available
      String actualFilePath = filePath ?? file.path ?? '';
      if (!kIsWeb && actualFilePath.isEmpty) {
        actualFilePath = file.path ?? '';
      }

      final result = await _apiService.uploadDocument(
        filePath: actualFilePath,
        fileName: filename ?? file.name,
        fileBytes: bytes,
        documentId: documentId,
        classroomId: classroomId ?? _currentClassroomId,
      );

      _uploadProgress = 1.0;
      notifyListeners();

      if (result.success) {
        // Add the new document to the list with classroom context
        final docInfo = result.toDocumentInfo();
        if (docInfo != null) {
          // Create a copy with classroom ID if needed
          final docWithClassroom = DocumentInfo(
            documentId: docInfo.documentId,
            filename: docInfo.filename,
            documentType: docInfo.documentType,
            status: docInfo.status,
            chunksCount: docInfo.chunksCount,
            createdAt: docInfo.createdAt,
            url: docInfo.url,
            classroomId: classroomId ?? _currentClassroomId,
          );
          
          print('=== Document Uploaded ===');
          print('Filename: ${docWithClassroom.filename}');
          print('Classroom ID: ${docWithClassroom.classroomId}');
          print('Current classroom context: $_currentClassroomId');
          
          _documents.insert(0, docWithClassroom);
          print('Added to _documents. Total count: ${_documents.length}');
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
      notifyListeners();
    }
  }

  /// Upload multiple documents
  Future<List<DocumentUploadResult>> uploadMultipleDocuments({
    required List<PlatformFile> files,
  }) async {
    final results = <DocumentUploadResult>[];

    for (final file in files) {
      final result = await uploadDocument(
        file: file,
        classroomId: _currentClassroomId,
      );
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
        // Add the new document to the list with classroom context
        final docInfo = result.toDocumentInfo();
        if (docInfo != null) {
          // Create a copy with classroom ID if needed
          final docWithClassroom = DocumentInfo(
            documentId: docInfo.documentId,
            filename: docInfo.filename,
            documentType: docInfo.documentType,
            status: docInfo.status,
            chunksCount: docInfo.chunksCount,
            createdAt: docInfo.createdAt,
            url: docInfo.url,
            classroomId: _currentClassroomId,
          );
          _documents.insert(0, docWithClassroom);
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
