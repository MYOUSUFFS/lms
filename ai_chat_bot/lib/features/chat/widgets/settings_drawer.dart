import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/theme/app_theme.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _baseUrlController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<SettingsProvider>();
    _apiKeyController.text = settings.apiKey;
    _baseUrlController.text = settings.baseUrl;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final chatProvider = context.read<ChatProvider>();

    return Drawer(
      width: 360,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Appearance Section
                _buildSectionHeader(theme, 'Appearance'),
                const SizedBox(height: 12),
                _buildThemeSelector(theme, settings),

                const SizedBox(height: 32),

                // API Configuration Section
                _buildSectionHeader(theme, 'API Configuration'),
                const SizedBox(height: 12),

                // Base URL
                _buildTextField(
                  theme,
                  label: 'Base URL',
                  controller: _baseUrlController,
                  hint: 'http://localhost:8000',
                  icon: Icons.link,
                  onChanged: (value) async {
                    await settings.setBaseUrl(value);
                    chatProvider.updateApiConfig(baseUrl: value);
                  },
                ),

                const SizedBox(height: 16),

                // API Key
                _buildTextField(
                  theme,
                  label: 'API Key',
                  controller: _apiKeyController,
                  hint: 'Enter your API key',
                  icon: Icons.key,
                  isPassword: !_showApiKey,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showApiKey ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showApiKey = !_showApiKey;
                      });
                    },
                  ),
                  onChanged: (value) async {
                    await settings.setApiKey(value);
                    chatProvider.updateApiConfig(apiKey: value);
                  },
                ),

                const SizedBox(height: 12),

                // Test connection button
                OutlinedButton.icon(
                  onPressed: () async {
                    await chatProvider.checkConnection();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            chatProvider.isConnected
                                ? 'Connected successfully!'
                                : 'Connection failed. Check your settings.',
                          ),
                          backgroundColor: chatProvider.isConnected
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Test Connection'),
                ),

                const SizedBox(height: 32),

                // Chat Settings Section
                _buildSectionHeader(theme, 'Chat Settings'),
                const SizedBox(height: 12),

                // Streaming toggle
                _buildSwitchTile(
                  theme,
                  title: 'Enable Streaming',
                  subtitle: 'Show responses as they are generated',
                  value: settings.useStreaming,
                  onChanged: settings.setUseStreaming,
                ),

                const SizedBox(height: 8),

                // RAG mode toggle
                _buildSwitchTile(
                  theme,
                  title: 'Document Context (RAG)',
                  subtitle: 'Use uploaded documents for context',
                  value: settings.useRag,
                  onChanged: (value) => settings.setUseRag(value),
                ),

                const SizedBox(height: 32),

                // About Section
                _buildSectionHeader(theme, 'About'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.smart_toy_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LMS AI Assistant',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Version 1.0.0',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Powered by RAG technology with local LLM support via Ollama.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildThemeSelector(ThemeData theme, SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          _buildThemeOption(
            theme,
            settings,
            mode: ThemeMode.light,
            icon: Icons.light_mode,
            label: 'Light',
          ),
          _buildThemeOption(
            theme,
            settings,
            mode: ThemeMode.dark,
            icon: Icons.dark_mode,
            label: 'Dark',
          ),
          _buildThemeOption(
            theme,
            settings,
            mode: ThemeMode.system,
            icon: Icons.settings_suggest,
            label: 'System',
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeData theme,
    SettingsProvider settings, {
    required ThemeMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = settings.themeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => settings.setThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : theme.iconTheme.color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : theme.textTheme.bodySmall?.color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme, {
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
