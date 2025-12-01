import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  ThemeMode _themeMode = ThemeMode.system;
  String _apiKey = '';
  String _baseUrl = 'http://localhost:8000';
  bool _useStreaming = true; // Enabled by default for real-time streaming
  bool _useRag = false;

  SettingsProvider(this._storage);

  ThemeMode get themeMode => _themeMode;
  String get apiKey => _apiKey;
  String get baseUrl => _baseUrl;
  bool get useStreaming => _useStreaming;
  bool get useRag => _useRag;

  Future<void> init() async {
    await _storage.init();

    final themeModeStr = await _storage.getThemeMode();
    _themeMode = _parseThemeMode(themeModeStr);

    _apiKey = await _storage.getApiKey() ?? '';
    _baseUrl = await _storage.getBaseUrl() ?? 'http://localhost:8000';

    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.setThemeMode(_themeModeToString(mode));
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _storage.setApiKey(key);
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    await _storage.setBaseUrl(url);
    notifyListeners();
  }

  void setUseStreaming(bool value) {
    _useStreaming = value;
    notifyListeners();
  }

  void setUseRag(bool value) {
    _useRag = value;
    notifyListeners();
  }

  void toggleRag() {
    _useRag = !_useRag;
    notifyListeners();
  }
}
