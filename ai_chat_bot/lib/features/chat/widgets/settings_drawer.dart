import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/cyberpunk_widgets.dart';
import '../../../core/models/color_theme.dart';
import '../../../core/models/theme_style.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer>
    with SingleTickerProviderStateMixin {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showApiKey = false;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _baseUrlController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final isCyberpunk = AppTheme.isCyberpunk;

    return Drawer(
      width: 380,
      backgroundColor: isCyberpunk
          ? AppTheme.backgroundDark
          : theme.scaffoldBackgroundColor,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header
            _buildCyberpunkHeader(context, settings),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                children: [
                  // Connection Status Card
                  _buildConnectionStatusCard(theme, chatProvider, isDark),

                  const SizedBox(height: 24),

                  // Appearance Section
                  _buildSectionCard(
                    theme,
                    isDark,
                    icon: Icons.palette_outlined,
                    title: isCyberpunk ? 'DISPLAY' : 'Display',
                    child: _buildThemeSelector(theme, settings, isDark),
                  ),

                  const SizedBox(height: 16),

                  // Theme Style Section
                  _buildSectionCard(
                    theme,
                    isDark,
                    icon: Icons.style_outlined,
                    title: isCyberpunk ? 'THEME STYLE' : 'Theme Style',
                    child: _buildThemeStyleSelector(theme, settings, isDark),
                  ),

                  const SizedBox(height: 16),

                  // Color Theme Section
                  _buildSectionCard(
                    theme,
                    isDark,
                    icon: Icons.color_lens_outlined,
                    title: isCyberpunk ? 'ACCENT COLOR' : 'Accent Color',
                    child: _buildColorThemeSelector(theme, settings, isDark),
                  ),

                  const SizedBox(height: 16),

                  // API Configuration Section
                  _buildSectionCard(
                    theme,
                    isDark,
                    icon: Icons.api_outlined,
                    title: isCyberpunk ? 'API CONFIG' : 'API Configuration',
                    child: Column(
                      children: [
                        _buildTextField(
                          theme,
                          isDark,
                          label: 'Server URL',
                          controller: _baseUrlController,
                          hint: 'http://localhost:8000',
                          icon: Icons.dns_outlined,
                          onChanged: (value) async {
                            await settings.setBaseUrl(value);
                            chatProvider.updateApiConfig(baseUrl: value);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          theme,
                          isDark,
                          label: 'API Key',
                          controller: _apiKeyController,
                          hint: 'Enter your API key',
                          icon: Icons.vpn_key_outlined,
                          isPassword: !_showApiKey,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showApiKey
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppTheme.accentColor,
                            ),
                            onPressed: () {
                              setState(() => _showApiKey = !_showApiKey);
                            },
                          ),
                          onChanged: (value) async {
                            await settings.setApiKey(value);
                            chatProvider.updateApiConfig(apiKey: value);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTestConnectionButton(context, chatProvider),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Chat Settings Section
                  _buildSectionCard(
                    theme,
                    isDark,
                    icon: Icons.chat_bubble_outline,
                    title: isCyberpunk ? 'NEURAL SETTINGS' : 'Chat Settings',
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          theme,
                          isDark,
                          icon: Icons.stream,
                          title: 'Enable Streaming',
                          subtitle: 'Real-time response generation',
                          value: settings.useStreaming,
                          onChanged: settings.setUseStreaming,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: CyberpunkDivider(
                            color: AppTheme.themeTextSecondary,
                          ),
                        ),
                        _buildSwitchTile(
                          theme,
                          isDark,
                          icon: Icons.memory,
                          title: 'Document Context (RAG)',
                          subtitle: 'Neural network uses uploaded data',
                          value: settings.useRag,
                          onChanged: (value) => settings.setUseRag(value),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  _buildAboutSection(theme, isDark),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberpunkHeader(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final isCyberpunk = AppTheme.isCyberpunk;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.colorTheme.primaryColor,
            settings.colorTheme.primaryColor.withBlue(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isCyberpunk ? 16 : 24),
          bottomRight: Radius.circular(isCyberpunk ? 16 : 24),
        ),
        boxShadow: isCyberpunk
            ? [
                BoxShadow(
                  color: settings.colorTheme.primaryColor.withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isCyberpunk ? 8 : 16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCyberpunk ? 'SETTINGS' : 'Settings',
                        style: isCyberpunk
                            ? GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              )
                            : GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            isCyberpunk ? 4 : 8,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          isCyberpunk
                              ? 'SYSTEM CONFIG'
                              : 'System Configuration',
                          style: isCyberpunk
                              ? GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                )
                              : GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard(
    ThemeData theme,
    ChatProvider chatProvider,
    bool isDark,
  ) {
    final isConnected = chatProvider.isConnected;
    final isCyberpunk = AppTheme.isCyberpunk;
    final statusColor = isConnected
        ? AppTheme.themeSuccess
        : AppTheme.themeError;

    return CyberpunkContainer(
      glowColor: statusColor,
      glowIntensity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CyberpunkStatusIndicator(isActive: isConnected, size: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? (isCyberpunk ? 'LINK ESTABLISHED' : 'Connected')
                      : (isCyberpunk ? 'LINK OFFLINE' : 'Disconnected'),
                  style: AppTheme.getHeaderTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isConnected
                      ? (isCyberpunk
                            ? 'Neural network connected'
                            : 'Server is reachable')
                      : (isCyberpunk
                            ? 'Check server configuration'
                            : 'Check your settings'),
                  style: AppTheme.getBodyTextStyle(
                    fontSize: 12,
                    color: AppTheme.themeTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isConnected ? Icons.link : Icons.link_off,
            color: statusColor,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final accentColor = AppTheme.accentColor;

    return CyberpunkContainer(
      glowColor: accentColor,
      glowIntensity: 0.3,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 10),
              NeonText(
                text: title,
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                glowIntensity: 0.5,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    ThemeData theme,
    SettingsProvider settings,
    bool isDark,
  ) {
    final isCyberpunk = AppTheme.isCyberpunk;

    return Row(
      children: [
        _buildThemeOption(
          theme,
          isDark,
          icon: Icons.brightness_5_rounded,
          label: isCyberpunk ? 'LIGHT' : 'Light',
          isSelected: settings.themeMode == ThemeMode.light,
          onTap: () => settings.setThemeMode(ThemeMode.light),
          color: isCyberpunk ? AppTheme.neonYellow : const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 12),
        _buildThemeOption(
          theme,
          isDark,
          icon: Icons.brightness_2_rounded,
          label: isCyberpunk ? 'DARK' : 'Dark',
          isSelected: settings.themeMode == ThemeMode.dark,
          onTap: () => settings.setThemeMode(ThemeMode.dark),
          color: isCyberpunk ? AppTheme.neonPurple : const Color(0xFF8B5CF6),
        ),
        const SizedBox(width: 12),
        _buildThemeOption(
          theme,
          isDark,
          icon: Icons.brightness_auto_rounded,
          label: isCyberpunk ? 'AUTO' : 'Auto',
          isSelected: settings.themeMode == ThemeMode.system,
          onTap: () => settings.setThemeMode(ThemeMode.system),
          color: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildColorThemeSelector(
    ThemeData theme,
    SettingsProvider settings,
    bool isDark,
  ) {
    final isCyberpunk = AppTheme.isCyberpunk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current theme indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: settings.colorTheme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 8),
            border: Border.all(
              color: settings.colorTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: settings.colorTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: isCyberpunk
                      ? [
                          BoxShadow(
                            color: settings.colorTheme.primaryColor.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isCyberpunk
                    ? settings.colorTheme.name.toUpperCase()
                    : settings.colorTheme.name,
                style: AppTheme.getBodyTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: settings.colorTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Color grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ColorThemes.all.map((colorTheme) {
            final isSelected = settings.colorTheme.id == colorTheme.id;
            return GestureDetector(
              onTap: () => settings.setColorTheme(colorTheme),
              child: Tooltip(
                message: colorTheme.name,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : colorTheme.primaryDark,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorTheme.primaryColor.withValues(
                                alpha: 0.6,
                              ),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : isCyberpunk
                        ? [
                            BoxShadow(
                              color: colorTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeStyleSelector(
    ThemeData theme,
    SettingsProvider settings,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildThemeStyleOption(
              theme,
              isDark,
              icon: Icons.star_outline,
              label: 'Classic',
              description: 'Clean & Modern',
              isSelected: settings.themeStyle == ThemeStyle.classic,
              onTap: () => settings.setThemeStyle(ThemeStyle.classic),
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(width: 12),
            _buildThemeStyleOption(
              theme,
              isDark,
              icon: Icons.flash_on_outlined,
              label: 'Cyberpunk',
              description: 'Neon & Futuristic',
              isSelected: settings.themeStyle == ThemeStyle.cyberpunk,
              onTap: () => settings.setThemeStyle(ThemeStyle.cyberpunk),
              color: const Color(0xFF8B5CF6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeStyleOption(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isCyberpunk = AppTheme.isCyberpunk;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : (isCyberpunk ? AppTheme.surfaceDark : theme.cardColor),
            borderRadius: BorderRadius.circular(isCyberpunk ? 8 : 12),
            border: Border.all(
              color: isSelected
                  ? color
                  : AppTheme.themeTextSecondary.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected && isCyberpunk
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppTheme.themeTextSecondary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                isCyberpunk ? label.toUpperCase() : label,
                style: AppTheme.getBodyTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppTheme.themeTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTheme.getBodyTextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.themeTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isCyberpunk = AppTheme.isCyberpunk;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : (isCyberpunk ? AppTheme.surfaceDark : theme.cardColor),
            borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
            border: Border.all(
              color: isSelected
                  ? color
                  : AppTheme.themeTextSecondary.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected && isCyberpunk
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppTheme.themeTextSecondary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTheme.getBodyTextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppTheme.themeTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    bool isDark, {
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isCyberpunk ? label.toUpperCase() : label,
          style: AppTheme.getBodyTextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.themeTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isCyberpunk ? AppTheme.surfaceDark : theme.cardColor,
            borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 12),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: AppTheme.getBodyTextStyle(
              fontSize: 14,
              color: AppTheme.themeTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.getBodyTextStyle(
                fontSize: 14,
                color: AppTheme.themeTextSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(icon, color: accentColor, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            cursorColor: accentColor,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTestConnectionButton(
    BuildContext context,
    ChatProvider chatProvider,
  ) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;

    return SizedBox(
      width: double.infinity,
      child: CyberpunkButton(
        text: _isTestingConnection
            ? (isCyberpunk ? 'TESTING...' : 'Testing...')
            : (isCyberpunk ? 'TEST CONNECTION' : 'Test Connection'),
        icon: Icons.network_check,
        color: accentColor,
        isLoading: _isTestingConnection,
        onPressed: _isTestingConnection
            ? null
            : () async {
                setState(() => _isTestingConnection = true);
                await chatProvider.checkConnection();
                final success = chatProvider.isConnected;
                setState(() => _isTestingConnection = false);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? (isCyberpunk
                                  ? 'CONNECTION SUCCESSFUL'
                                  : 'Connection successful')
                            : (isCyberpunk
                                  ? 'CONNECTION FAILED'
                                  : 'Connection failed'),
                        style: AppTheme.getBodyTextStyle(
                          color: success
                              ? AppTheme.themeSuccess
                              : AppTheme.themeError,
                        ),
                      ),
                      backgroundColor: isCyberpunk ? AppTheme.cardDark : null,
                    ),
                  );
                }
              },
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isCyberpunk = AppTheme.isCyberpunk;
    final accentColor = AppTheme.accentColor;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? accentColor.withValues(alpha: 0.2)
                : (isCyberpunk ? AppTheme.surfaceDark : theme.cardColor),
            borderRadius: BorderRadius.circular(isCyberpunk ? 4 : 8),
            border: Border.all(
              color: value
                  ? accentColor.withValues(alpha: 0.5)
                  : AppTheme.themeTextSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            color: value ? accentColor : AppTheme.themeTextSecondary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCyberpunk ? title.toUpperCase() : title,
                style: AppTheme.getBodyTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: value ? accentColor : AppTheme.themeTextPrimary,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.getBodyTextStyle(
                  fontSize: 11,
                  color: AppTheme.themeTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accentColor,
          activeTrackColor: accentColor.withValues(alpha: 0.3),
          inactiveThumbColor: AppTheme.themeTextSecondary,
          inactiveTrackColor: isCyberpunk
              ? AppTheme.surfaceDark
              : theme.cardColor,
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme, bool isDark) {
    final secondaryAccent = AppTheme.secondaryAccent;

    return CyberpunkContainer(
      glowColor: secondaryAccent,
      glowIntensity: 0.3,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: secondaryAccent, size: 18),
              const SizedBox(width: 10),
              NeonText(
                text: AppTheme.isCyberpunk ? 'ABOUT' : 'About',
                color: secondaryAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                glowIntensity: 0.5,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppTheme.isCyberpunk ? 'NEURAL LINK v2.0' : 'LMS AI Assistant',
            style: AppTheme.getHeaderTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.themeTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppTheme.isCyberpunk
                ? 'AI-POWERED LEARNING INTERFACE'
                : 'AI-Powered Learning Interface',
            style: AppTheme.getBodyTextStyle(
              fontSize: 11,
              color: AppTheme.themeTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          CyberpunkDivider(color: secondaryAccent),
          const SizedBox(height: 12),
          Text(
            AppTheme.isCyberpunk
                ? 'Advanced neural network integration for enhanced learning experiences. Powered by cutting-edge AI technology.'
                : 'Enhanced learning experiences powered by cutting-edge AI technology.',
            style: AppTheme.getBodyTextStyle(
              fontSize: 12,
              color: AppTheme.themeTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
