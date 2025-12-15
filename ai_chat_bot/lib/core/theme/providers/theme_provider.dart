import 'package:flutter/material.dart';
import '../base/app_theme_base.dart';
import '../repositories/theme_repository.dart';

/// Provider for managing theme state and switching
class ThemeProvider extends ChangeNotifier {
  final ThemeRepository _repository;

  AppThemeBase? _currentTheme;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeProvider(this._repository);

  /// Initialize the theme provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize the theme repository
    ThemeRepository.initialize();

    // Load saved theme settings
    await _loadSavedSettings();

    _isInitialized = true;
    notifyListeners();
  }

  /// Load saved theme settings from storage
  Future<void> _loadSavedSettings() async {
    try {
      // Load theme mode
      final savedThemeMode = await _repository.loadThemeMode();
      _themeMode = _parseThemeMode(savedThemeMode);

      // Load current theme
      final savedThemeId = await _repository.loadCurrentThemeId();
      if (savedThemeId != null) {
        _currentTheme = ThemeRepository.getThemeById(savedThemeId);
      }

      // If no theme is saved or theme not found, use default
      _currentTheme ??= ThemeRepository.getDefaultTheme();

      // Load custom themes
      await _repository.loadCustomThemes();
    } catch (e) {
      // If loading fails, use defaults
      _currentTheme = ThemeRepository.getDefaultTheme();
      _themeMode = ThemeMode.system;
    }
  }

  /// Parse theme mode string to ThemeMode enum
  ThemeMode _parseThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Convert ThemeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // Getters
  AppThemeBase? get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Get all available themes
  List<AppThemeBase> get availableThemes => ThemeRepository.getAllThemes();

  /// Get themes by category
  List<AppThemeBase> getThemesByCategory(ThemeCategory category) {
    return ThemeRepository.getThemesByCategory(category);
  }

  /// Get predefined themes
  List<AppThemeBase> get predefinedThemes =>
      ThemeRepository.getPredefinedThemes();

  // Theme Data Getters
  ThemeData? get lightTheme => _currentTheme?.toThemeData();
  ThemeData? get darkTheme => _currentTheme?.supportsDarkMode == true
      ? _currentTheme?.toDarkThemeData()
      : _currentTheme?.toThemeData();

  /// Set the current theme
  Future<void> setTheme(AppThemeBase theme) async {
    if (_currentTheme?.id == theme.id) return;

    _currentTheme = theme;
    await _repository.saveCurrentThemeId(theme.id);
    notifyListeners();
  }

  /// Set the theme by ID
  Future<void> setThemeById(String themeId) async {
    final theme = ThemeRepository.getThemeById(themeId);
    if (theme != null) {
      await setTheme(theme);
    }
  }

  /// Set the theme mode (light/dark/system)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _repository.saveThemeMode(_themeModeToString(mode));
    notifyListeners();
  }

  /// Toggle between light and dark theme modes
  Future<void> toggleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        // When system, switch to opposite of current brightness
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        await setThemeMode(
          brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light,
        );
        break;
    }
  }

  /// Save a custom theme
  Future<void> saveCustomTheme(AppThemeBase theme) async {
    await _repository.saveCustomTheme(theme);
    notifyListeners();
  }

  /// Delete a custom theme
  Future<void> deleteCustomTheme(String themeId) async {
    await _repository.deleteCustomTheme(themeId);

    // If the deleted theme was current, switch to default
    if (_currentTheme?.id == themeId) {
      await setTheme(ThemeRepository.getDefaultTheme());
    }

    notifyListeners();
  }

  /// Reset to default theme
  Future<void> resetToDefault() async {
    await setTheme(ThemeRepository.getDefaultTheme());
    await setThemeMode(ThemeMode.system);
  }

  /// Check if a theme is currently selected
  bool isThemeSelected(String themeId) {
    return _currentTheme?.id == themeId;
  }

  /// Get theme preview data (useful for theme selection UI)
  Map<String, dynamic> getThemePreview(AppThemeBase theme) {
    return {
      'id': theme.id,
      'name': theme.name,
      'description': theme.description,
      'category': theme.category,
      'primaryColor': theme.colorScheme.primary,
      'backgroundColor': theme.colorScheme.background,
      'surfaceColor': theme.colorScheme.surface,
      'supportsDarkMode': theme.supportsDarkMode,
    };
  }

  /// Export current theme settings
  Map<String, dynamic> exportCurrentSettings() {
    return {
      'themeId': _currentTheme?.id,
      'themeMode': _themeModeToString(_themeMode),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Import theme settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      final themeId = settings['themeId'] as String?;
      final themeMode = settings['themeMode'] as String?;

      if (themeId != null) {
        await setThemeById(themeId);
      }

      if (themeMode != null) {
        await setThemeMode(_parseThemeMode(themeMode));
      }
    } catch (e) {
      // Handle import errors gracefully
      debugPrint('Error importing theme settings: $e');
    }
  }
}
