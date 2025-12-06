import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/color_theme.dart';
import '../models/theme_style.dart';
import '../theme/app_theme.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  ThemeMode _themeMode = ThemeMode.system;
  String _apiKey = '';
  String _baseUrl = 'http://localhost:8000';
  bool _useStreaming = true; // Enabled by default for real-time streaming
  bool _useRag = false;
  ColorThemeOption _colorTheme = ColorThemes.defaultTheme;
  ThemeStyle _themeStyle = ThemeStyle.classic;

  SettingsProvider(this._storage);

  ThemeMode get themeMode => _themeMode;
  String get apiKey => _apiKey;
  String get baseUrl => _baseUrl;
  bool get useStreaming => _useStreaming;
  bool get useRag => _useRag;
  ColorThemeOption get colorTheme => _colorTheme;
  ThemeStyle get themeStyle => _themeStyle;

  Future<void> init() async {
    await _storage.init();

    final themeModeStr = await _storage.getThemeMode();
    _themeMode = _parseThemeMode(themeModeStr);

    _apiKey = await _storage.getApiKey() ?? '';
    _baseUrl = await _storage.getBaseUrl() ?? 'http://localhost:8000';

    // Load color theme
    final colorThemeId = await _storage.getColorTheme();
    _colorTheme = ColorThemes.getById(colorThemeId);

    // Load theme style
    final themeStyleStr = await _storage.getThemeStyle();
    _themeStyle = _parseThemeStyle(themeStyleStr);

    AppTheme.setColorTheme(_colorTheme);
    AppTheme.setThemeStyle(_themeStyle);

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

  ThemeStyle _parseThemeStyle(String style) {
    switch (style) {
      case 'classic':
        return ThemeStyle.classic;
      case 'cyberpunk':
        return ThemeStyle.cyberpunk;
      default:
        return ThemeStyle.classic;
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

  String _themeStyleToString(ThemeStyle style) {
    switch (style) {
      case ThemeStyle.classic:
        return 'classic';
      case ThemeStyle.cyberpunk:
        return 'cyberpunk';
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

  /// Set the color theme
  Future<void> setColorTheme(ColorThemeOption theme) async {
    _colorTheme = theme;
    AppTheme.setColorTheme(theme);
    await _storage.setColorTheme(theme.id);
    notifyListeners();
  }

  /// Set the color theme by ID
  Future<void> setColorThemeById(String themeId) async {
    final theme = ColorThemes.getById(themeId);
    await setColorTheme(theme);
  }

  /// Set the theme style
  Future<void> setThemeStyle(ThemeStyle style) async {
    _themeStyle = style;
    AppTheme.setThemeStyle(style);
    await _storage.setThemeStyle(_themeStyleToString(style));
    notifyListeners();
  }

  /// Set the theme style by string
  Future<void> setThemeStyleByString(String styleStr) async {
    final style = _parseThemeStyle(styleStr);
    await setThemeStyle(style);
  }
}
