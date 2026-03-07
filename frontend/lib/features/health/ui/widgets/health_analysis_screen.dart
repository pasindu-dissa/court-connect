import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HealthAnalysisScreen extends StatelessWidget {
  const HealthAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF2F4F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: const Center(child: Text('Health Analysis Screen')),
    );
  }
}
