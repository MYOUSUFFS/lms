import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/message.dart';

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

      final streamedResponse = await http.Client().send(request);

      if (streamedResponse.statusCode == 200) {
        await for (final chunk in streamedResponse.stream.transform(
          utf8.decoder,
        )) {
          yield chunk;
        }
      } else {
        yield 'Error: Failed to stream response';
      }
    } catch (e) {
      yield 'Error: ${e.toString()}';
    }
  }

  /// Stream RAG query response
  Stream<String> streamRagQuery({required String query, int topK = 5}) async* {
    try {
      final body = {'query': query, 'top_k': topK};

      final request = http.Request('POST', Uri.parse('$_apiBase/query/stream'));
      request.headers.addAll(_headers);
      request.body = jsonEncode(body);

      final streamedResponse = await http.Client().send(request);

      if (streamedResponse.statusCode == 200) {
        await for (final chunk in streamedResponse.stream.transform(
          utf8.decoder,
        )) {
          yield chunk;
        }
      } else {
        yield 'Error: Failed to stream response';
      }
    } catch (e) {
      yield 'Error: ${e.toString()}';
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
