import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../constants/api_constants.dart';
import '../models/message.dart';
import '../models/document.dart';

class ApiService {
  String _apiKey;
  String _baseUrl;

  ApiService({String? apiKey, String? baseUrl})
    : _apiKey = apiKey ?? ApiConstants.defaultApiKey,
      _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  void updateConfig({String? apiKey, String? baseUrl}) {
    if (apiKey != null) _apiKey = apiKey;
    if (baseUrl != null) _baseUrl = baseUrl;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-API-Key': _apiKey,
  };

  String get _apiBase => '$_baseUrl/api/${ApiConstants.apiVersion}';

  /// Check API health
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.healthEndpoint))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Send a direct chat message (without RAG)
  Future<Message> sendChatMessage({
    required String message,
    List<Map<String, String>>? conversationHistory,
    String? systemPrompt,
  }) async {
    try {
      final body = {
        'message': message,
        if (conversationHistory != null)
          'conversation_history': conversationHistory,
        if (systemPrompt != null) 'system_prompt': systemPrompt,
      };

      final response = await http
          .post(
            Uri.parse('$_apiBase/chat'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Message(
          content: (data['answer'] ?? data['response']) as String,
          role: MessageRole.assistant,
          status: MessageStatus.sent,
        );
      } else {
        final error = _parseError(response);
        return Message(
          content: 'Error: $error',
          role: MessageRole.assistant,
          status: MessageStatus.error,
          errorMessage: error,
        );
      }
    } catch (e) {
      return Message(
        content: 'Failed to send message: ${e.toString()}',
        role: MessageRole.assistant,
        status: MessageStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Send a RAG query (with document context)
  Future<Message> sendRagQuery({required String query, int topK = 5}) async {
    try {
      final body = {'query': query, 'top_k': topK};

      final response = await http
          .post(
            Uri.parse('$_apiBase/query'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sources = (data['sources'] as List<dynamic>?)
            ?.map((s) => s['source'].toString())
            .toList();

        return Message(
          content: data['response'] as String,
          role: MessageRole.assistant,
          status: MessageStatus.sent,
          sources: sources,
        );
      } else {
        final error = _parseError(response);
        return Message(
          content: 'Error: $error',
          role: MessageRole.assistant,
          status: MessageStatus.error,
          errorMessage: error,
        );
      }
    } catch (e) {
      return Message(
        content: 'Failed to send query: ${e.toString()}',
        role: MessageRole.assistant,
        status: MessageStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Stream chat response
  Stream<String> streamChatMessage({
    required String message,
    List<Map<String, String>>? conversationHistory,
    String? systemPrompt,
  }) async* {
    final client = http.Client();
    try {
      final body = {
        'message': message,
        if (conversationHistory != null)
          'conversation_history': conversationHistory,
        if (systemPrompt != null) 'system_prompt': systemPrompt,
      };

      final request = http.Request('POST', Uri.parse('$_apiBase/chat/stream'));
      request.headers.addAll(_headers);
      request.body = jsonEncode(body);

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        // Use a StringBuffer for proper stream handling
        final buffer = StringBuffer();
        await for (final bytes in streamedResponse.stream) {
          final chunk = utf8.decode(bytes);
          buffer.write(chunk);
          yield chunk;
        }
      } else {
        yield 'Error: Failed to stream response (${streamedResponse.statusCode})';
      }
    } catch (e) {
      yield 'Error: ${e.toString()}';
    } finally {
      client.close();
    }
  }

  /// Stream RAG query response
  Stream<String> streamRagQuery({required String query, int topK = 5}) async* {
    final client = http.Client();
    try {
      final body = {'query': query, 'top_k': topK};

      final request = http.Request('POST', Uri.parse('$_apiBase/query/stream'));
      request.headers.addAll(_headers);
      request.body = jsonEncode(body);

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        await for (final bytes in streamedResponse.stream) {
          final chunk = utf8.decode(bytes);
          yield chunk;
        }
      } else {
        yield 'Error: Failed to stream response (${streamedResponse.statusCode})';
      }
    } catch (e) {
      yield 'Error: ${e.toString()}';
    } finally {
      client.close();
    }
  }

  /// Get list of documents
  Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      final response = await http
          .get(Uri.parse('$_apiBase/documents'), headers: _headers)
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['documents'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Upload a document file
  /// Supports: PDF, TXT, MD, HTML, CSV, XLSX, XLS, PNG, JPG, JPEG
  Future<DocumentUploadResult> uploadDocument({
    required String filePath,
    required String fileName,
    required List<int> fileBytes,
    String? documentId,
  }) async {
    try {
      final uri = Uri.parse('$_apiBase/documents/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['X-API-Key'] = _apiKey;

      // Determine MIME type
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final mimeTypeParts = mimeType.split('/');

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: http.MediaType(mimeTypeParts[0], mimeTypeParts[1]),
        ),
      );

      // Add optional document ID
      if (documentId != null) {
        request.fields['document_id'] = documentId;
      }

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5), // Longer timeout for file uploads
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DocumentUploadResult(
          success: true,
          documentId: data['document_id'] as String,
          filename: data['filename'] as String,
          documentType: _parseDocumentType(data['document_type']),
          status: _parseProcessingStatus(data['status']),
          message: data['message'] as String? ?? 'Upload successful',
          chunksCreated: data['chunks_created'] as int? ?? 0,
        );
      } else {
        final error = _parseError(response);
        return DocumentUploadResult(success: false, message: error);
      }
    } catch (e) {
      return DocumentUploadResult(
        success: false,
        message: 'Upload failed: ${e.toString()}',
      );
    }
  }

  /// Scrape content from a URL
  Future<DocumentUploadResult> scrapeUrl({required String url}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_apiBase/documents/scrape'),
            headers: _headers,
            body: jsonEncode({'url': url}),
          )
          .timeout(const Duration(minutes: 2));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DocumentUploadResult(
          success: true,
          documentId: data['document_id'] as String,
          filename: data['title'] as String? ?? url,
          documentType: DocumentType.html,
          status: _parseProcessingStatus(data['status']),
          message: data['message'] as String? ?? 'Scrape successful',
          chunksCreated: data['chunks_created'] as int? ?? 0,
          url: data['url'] as String?,
        );
      } else {
        final error = _parseError(response);
        return DocumentUploadResult(success: false, message: error);
      }
    } catch (e) {
      return DocumentUploadResult(
        success: false,
        message: 'Scrape failed: ${e.toString()}',
      );
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_apiBase/documents/$documentId'),
            headers: _headers,
          )
          .timeout(ApiConstants.connectionTimeout);

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get document info
  Future<DocumentInfo?> getDocument(String documentId) async {
    try {
      final response = await http
          .get(Uri.parse('$_apiBase/documents/$documentId'), headers: _headers)
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DocumentInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get list of documents as DocumentInfo objects
  Future<List<DocumentInfo>> getDocumentList() async {
    try {
      final response = await http
          .get(Uri.parse('$_apiBase/documents'), headers: _headers)
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List<dynamic>;
        return documents
            .map((doc) => DocumentInfo.fromJson(doc as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  DocumentType _parseDocumentType(dynamic type) {
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

  ProcessingStatus _parseProcessingStatus(dynamic status) {
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

  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['detail']?.toString() ??
          'Unknown error (${response.statusCode})';
    } catch (e) {
      return 'Error: ${response.statusCode}';
    }
  }
}
