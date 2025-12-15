import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/providers/theme_provider.dart';
import '../../../core/theme/base/app_theme_base.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final themes = themeProvider.availableThemes;
        final categories = _getCategories(themes);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Choose Your Style'),
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Personalize Your Experience',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a theme that matches your style',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),

                // Theme Mode Toggle
                _buildThemeModeSelector(themeProvider),
                const SizedBox(height: 32),

                // Category Filter
                if (categories.length > 1) ...[
                  _buildCategoryFilter(categories),
                  const SizedBox(height: 24),
                ],

                // Theme Grid
                _buildThemeGrid(themes, themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeModeSelector(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              'Light',
              Icons.light_mode,
              ThemeMode.light,
              themeProvider.themeMode == ThemeMode.light,
              () => themeProvider.setThemeMode(ThemeMode.light),
            ),
          ),
          Expanded(
            child: _buildModeButton(
              'Dark',
              Icons.dark_mode,
              ThemeMode.dark,
              themeProvider.themeMode == ThemeMode.dark,
              () => themeProvider.setThemeMode(ThemeMode.dark),
            ),
          ),
          Expanded(
            child: _buildModeButton(
              'Auto',
              Icons.settings_suggest,
              ThemeMode.system,
              themeProvider.themeMode == ThemeMode.system,
              () => themeProvider.setThemeMode(ThemeMode.system),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<ThemeCategory> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('All', null),
              const SizedBox(width: 8),
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCategoryChip(
                    _getCategoryName(category),
                    category,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, ThemeCategory? category) {
    final isSelected = selectedCategory == category?.name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = isSelected ? null : category?.name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
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
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeGrid(
    List<AppThemeBase> themes,
    ThemeProvider themeProvider,
  ) {
    final filteredThemes = selectedCategory != null
        ? themes
              .where((theme) => theme.category.name == selectedCategory)
              .toList()
        : themes;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredThemes.length,
      itemBuilder: (context, index) {
        final theme = filteredThemes[index];
        final isSelected = themeProvider.currentTheme?.id == theme.id;

        return _buildThemeCard(theme, isSelected, () {
          themeProvider.setTheme(theme);
          // Show feedback
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

  Widget _buildThemeCard(
    AppThemeBase theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              // Theme Preview
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(theme.colorScheme.background.value),
                  ),
                  child: Stack(
                    children: [
                      // Gradient overlay for cyberpunk themes
                      if (theme.id.contains('cyberpunk'))
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(theme.colorScheme.background.value),
                                Color(
                                  theme.colorScheme.primary.value,
                                ).withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      // Mini interface preview
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            // Mock app bar
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(theme.colorScheme.surface.value),
                                borderRadius: BorderRadius.circular(
                                  theme.id.contains('neo_brutalism') ? 2 : 6,
                                ),
                                border: _getThemeBorder(theme),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        theme.colorScheme.primary.value,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 20,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        theme.colorScheme.onSurface.value,
                                      ).withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Mock content
                            Expanded(
                              child: Row(
                                children: [
                                  // Sidebar
                                  Container(
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        theme.colorScheme.surfaceVariant.value,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        theme.id.contains('neo_brutalism')
                                            ? 0
                                            : 4,
                                      ),
                                      border: _getThemeBorder(theme),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Main content
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              theme.colorScheme.primary.value,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              theme.id.contains('neo_brutalism')
                                                  ? 0
                                                  : 4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              theme.colorScheme.surface.value,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              theme.id.contains('neo_brutalism')
                                                  ? 0
                                                  : 2,
                                            ),
                                            border: _getThemeBorder(theme),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              theme.colorScheme.surface.value,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              theme.id.contains('neo_brutalism')
                                                  ? 0
                                                  : 2,
                                            ),
                                            border: _getThemeBorder(theme),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Selection indicator
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Theme Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryName(theme.category),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Border? _getThemeBorder(AppThemeBase theme) {
    // Special borders for certain themes
    if (theme.id.contains('neo_brutalism')) {
      return Border.all(
        color: Color(theme.colorScheme.outline.value),
        width: 1,
      );
    }
    if (theme.id.contains('cyberpunk')) {
      return Border.all(
        color: Color(theme.colorScheme.primary.value).withValues(alpha: 0.3),
        width: 0.5,
      );
    }
    return null;
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
        return 'Accessibility';
    }
  }
}
