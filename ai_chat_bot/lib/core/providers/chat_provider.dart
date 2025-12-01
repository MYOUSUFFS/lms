import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  bool _isConnected = false;
  String _streamingContent = '';

  ChatProvider(this._apiService, this._storageService);

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  List<Message> get currentMessages => _currentConversation?.messages ?? [];
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String get streamingContent => _streamingContent;
  bool get hasConversation => _currentConversation != null;

  Future<void> init() async {
    _conversations = await _storageService.loadConversations();
    await checkConnection();
    notifyListeners();
  }

  Future<void> checkConnection() async {
    _isConnected = await _apiService.checkHealth();
    notifyListeners();
  }

  void updateApiConfig({String? apiKey, String? baseUrl}) {
    _apiService.updateConfig(apiKey: apiKey, baseUrl: baseUrl);
    checkConnection();
  }

  // Conversation Management
  void createNewConversation({bool useRag = false}) {
    _currentConversation = Conversation(title: 'New Chat', useRag: useRag);
    notifyListeners();
  }

  void selectConversation(String conversationId) {
    _currentConversation = _conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => _currentConversation!,
    );
    notifyListeners();
  }

  Future<void> deleteConversation(String conversationId) async {
    await _storageService.deleteConversation(conversationId);
    _conversations.removeWhere((c) => c.id == conversationId);

    if (_currentConversation?.id == conversationId) {
      _currentConversation = null;
    }
    notifyListeners();
  }

  Future<void> clearAllConversations() async {
    await _storageService.saveConversations([]);
    _conversations.clear();
    _currentConversation = null;
    notifyListeners();
  }

  // Message Handling
  Future<void> sendMessage(String content, {bool useRag = false}) async {
    if (content.trim().isEmpty) return;
    if (_currentConversation == null) {
      createNewConversation(useRag: useRag);
    }

    // Add user message
    final userMessage = Message(
      content: content,
      role: MessageRole.user,
      status: MessageStatus.sent,
    );

    _addMessage(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      Message response;

      if (useRag) {
        response = await _apiService.sendRagQuery(query: content);
      } else {
        // Build conversation history for context
        final history = _buildConversationHistory();
        response = await _apiService.sendChatMessage(
          message: content,
          conversationHistory: history,
        );
      }

      _addMessage(response);

      // Update conversation title from first message
      if (_currentConversation!.messages.length <= 2) {
        _updateConversationTitle(content);
      }
    } catch (e) {
      final errorMessage = Message(
        content: 'Failed to get response: ${e.toString()}',
        role: MessageRole.assistant,
        status: MessageStatus.error,
        errorMessage: e.toString(),
      );
      _addMessage(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessageStreaming(
    String content, {
    bool useRag = false,
  }) async {
    if (content.trim().isEmpty) return;
    if (_currentConversation == null) {
      createNewConversation(useRag: useRag);
    }

    // Add user message
    final userMessage = Message(
      content: content,
      role: MessageRole.user,
      status: MessageStatus.sent,
    );

    _addMessage(userMessage);
    _isLoading = true;
    _streamingContent = '';
    notifyListeners();

    try {
      Stream<String> stream;

      if (useRag) {
        stream = _apiService.streamRagQuery(query: content);
      } else {
        final history = _buildConversationHistory();
        stream = _apiService.streamChatMessage(
          message: content,
          conversationHistory: history,
        );
      }

      await for (final chunk in stream) {
        _streamingContent += chunk;
        notifyListeners();
      }

      // Add final message
      final assistantMessage = Message(
        content: _streamingContent,
        role: MessageRole.assistant,
        status: MessageStatus.sent,
      );
      _addMessage(assistantMessage);

      // Update conversation title from first message
      if (_currentConversation!.messages.length <= 2) {
        _updateConversationTitle(content);
      }
    } catch (e) {
      final errorMessage = Message(
        content: 'Failed to get response: ${e.toString()}',
        role: MessageRole.assistant,
        status: MessageStatus.error,
        errorMessage: e.toString(),
      );
      _addMessage(errorMessage);
    } finally {
      _isLoading = false;
      _streamingContent = '';
      notifyListeners();
    }
  }

  List<Map<String, String>> _buildConversationHistory() {
    if (_currentConversation == null) return [];

    // Get last 10 messages for context
    final messages = _currentConversation!.messages.take(10).toList();

    return messages
        .map(
          (m) => {
            'role': m.role == MessageRole.user ? 'user' : 'assistant',
            'content': m.content,
          },
        )
        .toList();
  }

  void _addMessage(Message message) {
    if (_currentConversation == null) return;

    final updatedMessages = [..._currentConversation!.messages, message];
    _currentConversation = _currentConversation!.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    _saveCurrentConversation();
  }

  void _updateConversationTitle(String firstMessage) {
    final title = firstMessage.length > 30
        ? '${firstMessage.substring(0, 30)}...'
        : firstMessage;

    _currentConversation = _currentConversation!.copyWith(title: title);
    _saveCurrentConversation();
  }

  Future<void> _saveCurrentConversation() async {
    if (_currentConversation == null) return;

    await _storageService.saveConversation(_currentConversation!);

    // Update local list
    final index = _conversations.indexWhere(
      (c) => c.id == _currentConversation!.id,
    );

    if (index >= 0) {
      _conversations[index] = _currentConversation!;
    } else {
      _conversations.insert(0, _currentConversation!);
    }

    notifyListeners();
  }

  void retryLastMessage() {
    if (_currentConversation == null ||
        _currentConversation!.messages.isEmpty) {
      return;
    }

    // Find last user message
    final messages = _currentConversation!.messages;
    Message? lastUserMessage;
    int removeFromIndex = -1;

    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == MessageRole.user) {
        lastUserMessage = messages[i];
        removeFromIndex = i;
        break;
      }
    }

    if (lastUserMessage == null) return;

    // Remove messages from last user message onwards
    final updatedMessages = messages.sublist(0, removeFromIndex);
    _currentConversation = _currentConversation!.copyWith(
      messages: updatedMessages,
    );
    notifyListeners();

    // Resend
    sendMessage(lastUserMessage.content, useRag: _currentConversation!.useRag);
  }
}
