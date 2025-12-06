import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/cyberpunk_widgets.dart';
import '../../../core/models/color_theme.dart';

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

    return Drawer(
      width: 380,
      backgroundColor: AppTheme.backgroundDark,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Cyberpunk Header
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
                    title: 'DISPLAY',
                    child: _buildThemeSelector(theme, settings, isDark),
                  ),

                  const SizedBox(height: 16),

                  // Color Theme Section
                  _buildSectionCard(
                    theme,
                    isDark,
                    icon: Icons.color_lens_outlined,
                    title: 'ACCENT COLOR',
                    child: _buildColorThemeSelector(theme, settings, isDark),
                  ),

                  const SizedBox(height: 16),

                  // API Configuration Section
                  _buildSectionCard(
                    theme,
                    isDark,
                    icon: Icons.api_outlined,
                    title: 'API CONFIG',
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
                              color: AppTheme.primaryColor,
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
                    title: 'NEURAL SETTINGS',
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CyberpunkDivider(
                            color: AppTheme.textSecondaryDark,
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: settings.colorTheme.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
                    borderRadius: BorderRadius.circular(4),
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
                    borderRadius: BorderRadius.circular(8),
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
                        'SETTINGS',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
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
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'SYSTEM CONFIG',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
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
    final statusColor = isConnected
        ? AppTheme.successColor
        : AppTheme.errorColor;

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
                  isConnected ? 'LINK ESTABLISHED' : 'LINK OFFLINE',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isConnected
                      ? 'Neural network connected'
                      : 'Check server configuration',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppTheme.textSecondaryDark,
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
    return CyberpunkContainer(
      glowColor: AppTheme.primaryColor,
      glowIntensity: 0.3,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 10),
              NeonText(
                text: title,
                color: AppTheme.primaryColor,
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
    return Row(
      children: [
        _buildThemeOption(
          theme,
          isDark,
          icon: Icons.brightness_5_rounded,
          label: 'LIGHT',
          isSelected: settings.themeMode == ThemeMode.light,
          onTap: () => settings.setThemeMode(ThemeMode.light),
          color: AppTheme.neonYellow,
        ),
        const SizedBox(width: 12),
        _buildThemeOption(
          theme,
          isDark,
          icon: Icons.brightness_2_rounded,
          label: 'DARK',
          isSelected: settings.themeMode == ThemeMode.dark,
          onTap: () => settings.setThemeMode(ThemeMode.dark),
          color: AppTheme.neonPurple,
        ),
        const SizedBox(width: 12),
        _buildThemeOption(
          theme,
          isDark,
          icon: Icons.brightness_auto_rounded,
          label: 'AUTO',
          isSelected: settings.themeMode == ThemeMode.system,
          onTap: () => settings.setThemeMode(ThemeMode.system),
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildColorThemeSelector(
    ThemeData theme,
    SettingsProvider settings,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current theme indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: settings.colorTheme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
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
                  boxShadow: [
                    BoxShadow(
                      color: settings.colorTheme.primaryColor.withValues(
                        alpha: 0.5,
                      ),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                settings.colorTheme.name.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: settings.colorTheme.primaryColor,
                  letterSpacing: 1,
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
                        : [
                            BoxShadow(
                              color: colorTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 4,
                            ),
                          ],
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

  Widget _buildThemeOption(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? color
                  : AppTheme.textSecondaryDark.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
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
                color: isSelected ? color : AppTheme.textSecondaryDark,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppTheme.textSecondaryDark,
                  letterSpacing: 1,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.rajdhani(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondaryDark,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: GoogleFonts.rajdhani(
              color: AppTheme.textPrimaryDark,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.rajdhani(
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            cursorColor: AppTheme.primaryColor,
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
    return SizedBox(
      width: double.infinity,
      child: CyberpunkButton(
        text: _isTestingConnection ? 'TESTING...' : 'TEST CONNECTION',
        icon: Icons.network_check,
        color: AppTheme.primaryColor,
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
                        success ? 'CONNECTION SUCCESSFUL' : 'CONNECTION FAILED',
                        style: GoogleFonts.rajdhani(
                          color: success
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          letterSpacing: 1,
                        ),
                      ),
                      backgroundColor: AppTheme.cardDark,
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: value
                  ? AppTheme.primaryColor.withValues(alpha: 0.5)
                  : AppTheme.textSecondaryDark.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            color: value ? AppTheme.primaryColor : AppTheme.textSecondaryDark,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: value
                      ? AppTheme.primaryColor
                      : AppTheme.textPrimaryDark,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: AppTheme.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          inactiveThumbColor: AppTheme.textSecondaryDark,
          inactiveTrackColor: AppTheme.surfaceDark,
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme, bool isDark) {
    return CyberpunkContainer(
      glowColor: AppTheme.neonPink,
      glowIntensity: 0.3,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.neonPink,
                size: 18,
              ),
              const SizedBox(width: 10),
              NeonText(
                text: 'ABOUT',
                color: AppTheme.neonPink,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                glowIntensity: 0.5,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'NEURAL LINK v2.0',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI-POWERED LEARNING INTERFACE',
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              color: AppTheme.textSecondaryDark,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          const CyberpunkDivider(color: AppTheme.neonPink),
          const SizedBox(height: 12),
          Text(
            'Advanced neural network integration for enhanced learning experiences. Powered by cutting-edge AI technology.',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppTheme.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
