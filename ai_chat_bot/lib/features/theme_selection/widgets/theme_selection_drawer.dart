import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/providers/theme_provider.dart';
import '../../../core/theme/base/app_theme_base.dart';

class ThemeSelectionDrawer extends StatefulWidget {
  final bool isInDialog;
  const ThemeSelectionDrawer({super.key, this.isInDialog = false});

  @override
  State<ThemeSelectionDrawer> createState() => _ThemeSelectionDrawerState();
}

class _ThemeSelectionDrawerState extends State<ThemeSelectionDrawer> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final themes = _getFilteredThemes(themeProvider);
        final categories = _getCategories(themes);

        final content = Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                widget.isInDialog ? 20 : 50,
                16,
                20,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Themes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.isInDialog) ...[
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Personalize Your Experience',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Mode Toggle
                    _buildCompactThemeModeSelector(themeProvider),
                    const SizedBox(height: 20),

                    // Category Filter
                    if (categories.length > 1) ...[
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCompactCategoryFilter(categories),
                      const SizedBox(height: 16),
                    ],

                    // Theme List (scrollable)
                    Text(
                      'Available Themes',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildCompactThemeList(themes, themeProvider),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        if (widget.isInDialog) {
          return content;
        } else {
          return Drawer(width: 320, child: content);
        }
      },
    );
  }

  List<AppThemeBase> _getFilteredThemes(ThemeProvider themeProvider) {
    final allThemes = themeProvider.availableThemes;
    final currentBrightness = _getCurrentBrightness();

    // Filter themes based on current theme mode and brightness
    List<AppThemeBase> filteredThemes = allThemes.where((theme) {
      // Filter by category if selected
      if (selectedCategory != null && theme.category.name != selectedCategory) {
        return false;
      }

      // Filter by brightness compatibility
      if (currentBrightness == Brightness.dark) {
        // DARK MODE: Only show themes that are dark or have "dark" in their name
        return _isDarkTheme(theme);
      } else {
        // LIGHT MODE: Only show themes that are light or have "light" in their name
        return _isLightTheme(theme);
      }
    }).toList();

    return filteredThemes;
  }

  Brightness _getCurrentBrightness() {
    final themeMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).themeMode;

    switch (themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  bool _isDarkTheme(AppThemeBase theme) {
    // Check if theme is specifically a dark theme
    return theme.id.toLowerCase().contains('dark') ||
        theme.id.toLowerCase().contains('cyberpunk') ||
        theme.id.toLowerCase().contains('matrix') ||
        theme.name.toLowerCase().contains('dark');
  }

  bool _isLightTheme(AppThemeBase theme) {
    // Check if theme is specifically a light theme
    return theme.id.toLowerCase().contains('light') ||
        theme.name.toLowerCase().contains('light') ||
        (!theme.id.toLowerCase().contains('dark') &&
            !theme.id.toLowerCase().contains('cyberpunk') &&
            !theme.id.toLowerCase().contains('matrix'));
  }

  Widget _buildCompactThemeModeSelector(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactModeButton(
              'Light',
              Icons.light_mode,
              ThemeMode.light,
              themeProvider.themeMode == ThemeMode.light,
              () {
                themeProvider.setThemeMode(ThemeMode.light);
                setState(() {}); // Trigger rebuild to update filtered themes
              },
            ),
          ),
          Expanded(
            child: _buildCompactModeButton(
              'Dark',
              Icons.dark_mode,
              ThemeMode.dark,
              themeProvider.themeMode == ThemeMode.dark,
              () {
                themeProvider.setThemeMode(ThemeMode.dark);
                setState(() {}); // Trigger rebuild to update filtered themes
              },
            ),
          ),
          Expanded(
            child: _buildCompactModeButton(
              'Auto',
              Icons.settings_suggest,
              ThemeMode.system,
              themeProvider.themeMode == ThemeMode.system,
              () {
                themeProvider.setThemeMode(ThemeMode.system);
                setState(() {}); // Trigger rebuild to update filtered themes
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactModeButton(
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCategoryFilter(List<ThemeCategory> categories) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildCompactCategoryChip('All', null),
        ...categories.map(
          (category) =>
              _buildCompactCategoryChip(_getCategoryName(category), category),
        ),
      ],
    );
  }

  Widget _buildCompactCategoryChip(String label, ThemeCategory? category) {
    final isSelected = selectedCategory == category?.name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = isSelected ? null : category?.name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactThemeList(
    List<AppThemeBase> themes,
    ThemeProvider themeProvider,
  ) {
    return ListView.builder(
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = themeProvider.currentTheme?.id == theme.id;

        return _buildCompactThemeItem(theme, isSelected, () {
          themeProvider.setTheme(theme);

          // Close dialog if in dialog mode
          // if (widget.isInDialog) {
          //   Navigator.pop(context);
          // }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Applied ${theme.name} theme'),
              duration: const Duration(seconds: 1),
            ),
          );
        });
      },
    );
  }

  Widget _buildCompactThemeItem(
    AppThemeBase theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // Mini theme preview
                Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(theme.colorScheme.background.value),
                    border: Border.all(
                      color: Color(
                        theme.colorScheme.outline.value,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background gradient for special themes
                      if (theme.id.contains('cyberpunk'))
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              colors: [
                                Color(theme.colorScheme.background.value),
                                Color(
                                  theme.colorScheme.primary.value,
                                ).withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                        ),
                      // Mini interface elements
                      Positioned(
                        top: 3,
                        left: 3,
                        child: Container(
                          width: 12,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Color(theme.colorScheme.primary.value),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 3,
                        right: 3,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Color(theme.colorScheme.surface.value),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 3,
                        left: 3,
                        right: 8,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Color(
                              theme.colorScheme.surfaceVariant.value,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Theme info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getCategoryName(theme.category),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ThemeCategory> _getCategories(List<AppThemeBase> themes) {
    return themes.map((theme) => theme.category).toSet().toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  String _getCategoryName(ThemeCategory category) {
    switch (category) {
      case ThemeCategory.modern:
        return 'Modern';
      case ThemeCategory.classic:
        return 'Classic';
      case ThemeCategory.cyberpunk:
        return 'Cyberpunk';
      case ThemeCategory.notion:
        return 'Notion';
      case ThemeCategory.custom:
        return 'Custom';
      case ThemeCategory.accessibility:
        return 'Access';
    }
  }
}
