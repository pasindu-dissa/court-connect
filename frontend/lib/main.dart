import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/ui/screens/welcome_screen.dart';

void main() {
  runApp(const CourtConnectApp());
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
          themeMode: currentMode, // This listens to the toggle
          home: const WelcomeScreen(),
        );
      },
    );
  }
}