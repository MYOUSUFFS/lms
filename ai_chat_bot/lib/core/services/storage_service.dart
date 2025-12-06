import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';

class StorageService {
  static const String _conversationsKey = 'conversations';
  // static const String _settingsKey = 'settings';
  static const String _apiKeyKey = 'api_key';
  static const String _baseUrlKey = 'base_url';
  static const String _themeKey = 'theme_mode';
  static const String _colorThemeKey = 'color_theme';
  static const String _themeStyleKey = 'theme_style';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Conversations
  Future<List<Conversation>> loadConversations() async {
    await init();
    final data = _prefs.getString(_conversationsKey);
    if (data == null) return [];

    try {
      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveConversations(List<Conversation> conversations) async {
    await init();
    final data = jsonEncode(conversations.map((c) => c.toJson()).toList());
    await _prefs.setString(_conversationsKey, data);
  }

  Future<void> saveConversation(Conversation conversation) async {
    final conversations = await loadConversations();
    final index = conversations.indexWhere((c) => c.id == conversation.id);

    if (index >= 0) {
      conversations[index] = conversation;
    } else {
      conversations.insert(0, conversation);
    }

    await saveConversations(conversations);
  }

  Future<void> deleteConversation(String conversationId) async {
    final conversations = await loadConversations();
    conversations.removeWhere((c) => c.id == conversationId);
    await saveConversations(conversations);
  }

  // Settings
  Future<String?> getApiKey() async {
    await init();
    return _prefs.getString(_apiKeyKey);
  }

  Future<void> setApiKey(String apiKey) async {
    await init();
    await _prefs.setString(_apiKeyKey, apiKey);
  }

  Future<String?> getBaseUrl() async {
    await init();
    return _prefs.getString(_baseUrlKey);
  }

  Future<void> setBaseUrl(String baseUrl) async {
    await init();
    await _prefs.setString(_baseUrlKey, baseUrl);
  }

  Future<String> getThemeMode() async {
    await init();
    return _prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await init();
    await _prefs.setString(_themeKey, mode);
  }

  // Color Theme
  Future<String> getColorTheme() async {
    await init();
    return _prefs.getString(_colorThemeKey) ?? 'electric_blue';
  }

  Future<void> setColorTheme(String themeId) async {
    await init();
    await _prefs.setString(_colorThemeKey, themeId);
  }

  // Theme Style
  Future<String> getThemeStyle() async {
    await init();
    return _prefs.getString(_themeStyleKey) ?? 'classic';
  }

  Future<void> setThemeStyle(String style) async {
    await init();
    await _prefs.setString(_themeStyleKey, style);
  }

  Future<void> clearAll() async {
    await init();
    await _prefs.clear();
  }
}
