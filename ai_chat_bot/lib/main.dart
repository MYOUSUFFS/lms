import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/document_provider.dart';
import 'features/learning_assistant/learning_assistant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow Google Fonts to fetch fonts at runtime
  GoogleFonts.config.allowRuntimeFetching = true;

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  // Load saved settings
  final apiKey = await storageService.getApiKey();
  final baseUrl = await storageService.getBaseUrl();

  final apiService = ApiService(apiKey: apiKey, baseUrl: baseUrl);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiService, storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => DocumentProvider(apiService: apiService),
        ),
      ],
      child: const AIChatBotApp(),
    ),
  );
}

class AIChatBotApp extends StatelessWidget {
  const AIChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      // Use both color theme id and style as key to force rebuild when either changes
      key: ValueKey('${settings.colorTheme.id}_${settings.themeStyle.name}'),
      title: 'LMS AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const LearningAssistantScreen(),
    );
  }
}
