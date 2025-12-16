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
  String? _currentClassroomId; // Add classroom context

  ChatProvider(this._apiService, this._storageService);

  List<Conversation> get conversations => _conversations;
  
  // Get filtered conversations for current classroom context
  List<Conversation> get filteredConversations {
    if (_currentClassroomId == null) {
      // If no classroom context, show ALL conversations
      return _conversations;
    }
    // Show only conversations for current classroom
    return _conversations.where((c) => c.metadata?['classroomId'] == _currentClassroomId).toList();
  }
  
  Conversation? get currentConversation => _currentConversation;
  List<Message> get currentMessages => _currentConversation?.messages ?? [];
  List<Message> get messages => currentMessages; // Add messages getter
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String get streamingContent => _streamingContent;
  bool get hasConversation => _currentConversation != null;
  String? get currentClassroomId => _currentClassroomId;
  bool get isClassroomContext => _currentClassroomId != null;

  // Set classroom context for chat
  void setClassroomContext(String classroomId) {
    _currentClassroomId = classroomId;
    _loadClassroomConversation(classroomId);
  }

  // Clear classroom context (when leaving classroom)
  void clearClassroomContext() {
    _currentClassroomId = null;
    _currentConversation = null;
    notifyListeners();
  }

  // Load chat history for specific classroom
  Future<void> loadChatHistory(String classroomId) async {
    _currentClassroomId = classroomId;
    await _loadClassroomConversation(classroomId);
  }

  // Load or create conversation for classroom
  Future<void> _loadClassroomConversation(String classroomId) async {
    // Find existing conversation for this classroom
    final existingConversation = _conversations.firstWhere(
      (c) => c.metadata?['classroomId'] == classroomId,
      orElse: () {
        // Create new conversation for this classroom
        final newConversation = Conversation(
          title: 'Classroom Chat',
          useRag: true,
          metadata: {'classroomId': classroomId},
        );
        _conversations.add(newConversation);
        return newConversation;
      },
    );

    _currentConversation = existingConversation;
    notifyListeners();
  }

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
    // If in classroom context, create conversation with classroom metadata
    if (_currentClassroomId != null) {
      final newConversation = Conversation(
        title: 'Classroom Chat',
        useRag: useRag,
        metadata: {'classroomId': _currentClassroomId},
      );
      _conversations.add(newConversation);
      _currentConversation = newConversation;
    } else {
      _currentConversation = Conversation(title: 'New Chat', useRag: useRag);
    }
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
  Future<void> sendMessage(
    String content, {
    bool useRag = false,
    List<String>? documentIds,
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
    notifyListeners();

    try {
      Message response;

      if (useRag) {
        response = await _apiService.sendRagQuery(
          query: content,
          documentIds: documentIds,
        );
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
    List<String>? documentIds,
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
        stream = _apiService.streamRagQuery(
          query: content,
          documentIds: documentIds,
        );
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

  /// Get document IDs for current classroom
  Future<List<String>?> _getClassroomDocumentIds() async {
    if (_currentClassroomId == null) return null;
    
    // We need access to DocumentProvider to get the documents
    // For now, return null and we'll inject DocumentProvider
    // This will be handled when we import and use Provider.of in the method
    return null;
  }

  List<Map<String, String>> _buildConversationHistory() {
    if (_currentConversation == null) return [];

    final allMessages = _currentConversation!.messages;

    // Exclude the last message (which is the current user message just added)
    // This prevents sending the current question as part of history
    final historyMessages = allMessages.length > 1
        ? allMessages.sublist(0, allMessages.length - 1)
        : <Message>[];

    // Take the last 20 messages for better context memory
    final recentMessages = historyMessages.length > 20
        ? historyMessages.sublist(historyMessages.length - 20)
        : historyMessages;

    return recentMessages
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
