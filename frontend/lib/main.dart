import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Add this package
import 'core/theme/app_theme.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'core/services/user_provider.dart';
import 'features/home/ui/main_wrapper.dart'; // Import Wrapper
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
      ],
      child: const CourtConnectApp(),
    ),
  );
}

class CourtConnectApp extends StatelessWidget {
  const CourtConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Court Connect',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          // Check if user is already logged in via Firebase
          home: AuthService().currentUser != null ? const MainWrapper() : const LoginScreen(),
        );
      },
    );
  }
}