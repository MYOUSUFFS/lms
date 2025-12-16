import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/organization_provider.dart';
import '../../core/providers/classroom_provider.dart';
import 'login_screen.dart';

/// Splash screen that initializes auth state
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer initialization until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize auth state
    await authProvider.init();

    // Wait minimum time for splash screen
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Navigate based on auth state
    if (authProvider.isAuthenticated) {
      // Initialize organization and classroom providers with token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token != null && mounted) {
        Provider.of<OrganizationProvider>(context, listen: false).setToken(token);
        Provider.of<ClassroomProvider>(context, listen: false).setToken(token);
      }
      
      // Navigate to Classrooms screen (home)
      Navigator.of(context).pushReplacementNamed('/classrooms');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'LMS System',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
