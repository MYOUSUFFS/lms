import '../base/app_theme_base.dart';
import '../predefined/light_theme.dart';
import '../predefined/dark_theme.dart';
import '../predefined/notion_theme.dart';
import '../predefined/cyberpunk_themes.dart';
import '../predefined/enhanced_cyberpunk_themes.dart';
import '../predefined/neo_brutalism_theme.dart';
import '../predefined/accessibility_themes.dart';
import '../../services/storage_service.dart';

/// Repository for managing theme data and persistence
class ThemeRepository {
  final StorageService _storage;

  // Theme registry
  static final Map<String, AppThemeBase> _themes = {};
  static final List<AppThemeBase> _predefinedThemes = [];

  ThemeRepository(this._storage);

  /// Initialize the repository with predefined themes
  static void initialize() {
    // Register predefined themes
    _registerPredefinedThemes();
  }

  static void _registerPredefinedThemes() {
    final themes = [
      LightTheme(),
      DarkTheme(),
      NotionLightTheme(),
      NotionDarkTheme(),
      // Enhanced Cyberpunk themes with ThemeExtension
      EnhancedCyberpunkNeonTheme(),
      EnhancedMatrixTheme(),
      // Original cyberpunk themes (for compatibility)
      CyberpunkNeonTheme(),
      MatrixTheme(),
      // Neo-Brutalism themes
      NeoBrutalismTheme(),
      NeoBrutalismDarkTheme(),
      HighContrastTheme(),
      // Add more predefined themes here
    ];

    for (final theme in themes) {
      registerTheme(theme);
    }

    _predefinedThemes.addAll(themes);
  }

  /// Register a theme in the repository
  static void registerTheme(AppThemeBase theme) {
    _themes[theme.id] = theme;
  }

  /// Get all available themes
  static List<AppThemeBase> getAllThemes() {
    return _themes.values.toList();
  }

  /// Get themes by category
  static List<AppThemeBase> getThemesByCategory(ThemeCategory category) {
    return _themes.values.where((theme) => theme.category == category).toList();
  }

  /// Get theme by ID
  static AppThemeBase? getThemeById(String id) {
    return _themes[id];
  }

  /// Get predefined themes
  static List<AppThemeBase> getPredefinedThemes() {
    return _predefinedThemes;
  }

  /// Check if theme exists
  static bool hasTheme(String id) {
    return _themes.containsKey(id);
  }

  /// Save current theme ID to storage
  Future<void> saveCurrentThemeId(String themeId) async {
    await _storage.setCurrentTheme(themeId);
  }

  /// Load current theme ID from storage
  Future<String?> loadCurrentThemeId() async {
    return await _storage.getCurrentTheme();
  }

  /// Save theme mode (light/dark/system) to storage
  Future<void> saveThemeMode(String mode) async {
    await _storage.setThemeMode(mode);
  }

  /// Load theme mode from storage
  Future<String> loadThemeMode() async {
    return await _storage.getThemeMode() ?? 'system';
  }

  /// Save custom theme data
  Future<void> saveCustomTheme(AppThemeBase theme) async {
    registerTheme(theme);
    await _storage.saveCustomTheme(theme.id, _serializeTheme(theme));
  }

  /// Load custom themes from storage
  Future<void> loadCustomThemes() async {
    final customThemes = await _storage.getCustomThemes();
    for (final entry in customThemes.entries) {
      final theme = _deserializeTheme(entry.key, entry.value);
      if (theme != null) {
        registerTheme(theme);
      }
    }
  }

  /// Delete custom theme
  Future<void> deleteCustomTheme(String themeId) async {
    _themes.remove(themeId);
    await _storage.deleteCustomTheme(themeId);
  }

  /// Export theme data
  Map<String, dynamic> exportTheme(AppThemeBase theme) {
    return _serializeTheme(theme);
  }

  /// Import theme data
  AppThemeBase? importTheme(String themeId, Map<String, dynamic> themeData) {
    return _deserializeTheme(themeId, themeData);
  }

  /// Serialize theme to JSON
  Map<String, dynamic> _serializeTheme(AppThemeBase theme) {
    // This would contain the full serialization logic
    // For now, return basic metadata
    return {
      'id': theme.id,
      'name': theme.name,
      'description': theme.description,
      'category': theme.category.name,
      'supportsDarkMode': theme.supportsDarkMode,
      // Add color scheme, typography, etc. serialization here
    };
  }

  /// Deserialize theme from JSON
  AppThemeBase? _deserializeTheme(String themeId, Map<String, dynamic> data) {
    // This would contain the full deserialization logic
    // For now, return null (custom themes will be implemented later)
    return null;
  }

  /// Get default theme
  static AppThemeBase getDefaultTheme() {
    return _themes.values.first; // Return first available theme
  }

  /// Validate theme data
  static bool validateTheme(AppThemeBase theme) {
    // Add validation logic here
    return theme.id.isNotEmpty &&
        theme.name.isNotEmpty &&
        theme.description.isNotEmpty;
  }
}
