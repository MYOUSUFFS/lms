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

  // New theme system keys
  static const String _currentThemeKey = 'current_theme';
  static const String _customThemesKey = 'custom_themes';

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

  Future<String?> getThemeMode() async {
    await init();
    return _prefs.getString(_themeKey);
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

  // New theme system methods
  /// Get the current theme ID
  Future<String?> getCurrentTheme() async {
    await init();
    return _prefs.getString(_currentThemeKey);
  }

  /// Set the current theme ID
  Future<void> setCurrentTheme(String themeId) async {
    await init();
    await _prefs.setString(_currentThemeKey, themeId);
  }

  /// Save a custom theme
  Future<void> saveCustomTheme(
    String themeId,
    Map<String, dynamic> themeData,
  ) async {
    await init();
    final customThemes = await getCustomThemes();
    customThemes[themeId] = themeData;
    final data = jsonEncode(customThemes);
    await _prefs.setString(_customThemesKey, data);
  }

  /// Get all custom themes
  Future<Map<String, Map<String, dynamic>>> getCustomThemes() async {
    await init();
    final data = _prefs.getString(_customThemesKey);
    if (data == null) return {};

    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return map.map(
        (key, value) => MapEntry(key, value as Map<String, dynamic>),
      );
    } catch (e) {
      return {};
    }
  }

  /// Delete a custom theme
  Future<void> deleteCustomTheme(String themeId) async {
    await init();
    final customThemes = await getCustomThemes();
    customThemes.remove(themeId);
    final data = jsonEncode(customThemes);
    await _prefs.setString(_customThemesKey, data);
  }

  Future<void> clearAll() async {
    await init();
    await _prefs.clear();
  }
}
