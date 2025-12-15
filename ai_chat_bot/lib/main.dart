import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/providers/theme_provider.dart';
import 'core/theme/repositories/theme_repository.dart';
import 'core/theme/widgets/cyberpunk_app_wrapper.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/organization_service.dart';
import 'core/services/classroom_service.dart';
import 'core/services/storage_service.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/document_provider.dart';
import 'core/providers/organization_provider.dart';
import 'core/providers/classroom_provider.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/learning_assistant/learning_assistant_screen.dart';
import 'features/organizations/screens/organizations_screen.dart';
import 'features/classrooms/screens/classrooms_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow Google Fonts to fetch fonts at runtime
  GoogleFonts.config.allowRuntimeFetching = true;

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  // Initialize theme repository with predefined themes
  ThemeRepository.initialize();

  // Load saved settings
  final apiKey = await storageService.getApiKey();
  final baseUrl = await storageService.getBaseUrl();

  final apiService = ApiService(apiKey: apiKey, baseUrl: baseUrl);
  final authService = AuthService(baseUrl: baseUrl ?? 'http://localhost:8000');
  final organizationService = OrganizationService(
    baseUrl: baseUrl ?? 'http://localhost:8000',
  );
  final classroomService = ClassroomService(
    baseUrl: baseUrl ?? 'http://localhost:8000',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(ThemeRepository(storageService)),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => DocumentProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrganizationProvider(organizationService),
        ),
        ChangeNotifierProvider(
          create: (_) => ClassroomProvider(classroomService),
        ),
      ],
      child: const AIChatBotApp(),
    ),
  );
}

class AIChatBotApp extends StatefulWidget {
  const AIChatBotApp({super.key});

  @override
  State<AIChatBotApp> createState() => _AIChatBotAppState();
}

class _AIChatBotAppState extends State<AIChatBotApp> {
  @override
  void initState() {
    super.initState();
    // Initialize providers after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    if (!mounted) return;

    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Initialize all providers
    await Future.wait([
      settingsProvider.init(),
      themeProvider.initialize(),
      chatProvider.init(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settings, themeProvider, _) {
        // Use new theme system if initialized, otherwise fall back to old system
        if (themeProvider.isInitialized && themeProvider.currentTheme != null) {
          return MaterialApp(
            key: ValueKey(
              '${themeProvider.currentTheme?.id}_${themeProvider.themeMode.name}',
            ),
            title: 'LMS AI Assistant',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const DashboardScreen(),
              '/chat': (context) =>
                  CyberpunkApp(child: const LearningAssistantScreen()),
              '/organizations': (context) => const OrganizationsScreen(),
              '/classrooms': (context) => const ClassroomsScreen(),
            },
          );
        }

        // Fallback to old theme system during initialization
        final brightness = _getBrightness(context, settings.themeMode);
        AppTheme.setBrightness(brightness);

        return MaterialApp(
          key: ValueKey(
            'fallback_${settings.colorTheme.id}_${settings.themeStyle.name}',
          ),
          title: 'LMS AI Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const DashboardScreen(),
            '/chat': (context) => const LearningAssistantScreen(),
            '/organizations': (context) => const OrganizationsScreen(),
            '/classrooms': (context) => const ClassroomsScreen(),
          },
        );
      },
    );
  }

  Brightness _getBrightness(BuildContext context, ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }
}
