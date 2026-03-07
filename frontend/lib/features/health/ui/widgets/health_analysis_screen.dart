import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'summary_card.dart';

class HealthAnalysisScreen extends StatelessWidget {
  const HealthAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF2F4F7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF212121);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF757575);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Health Analysis',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Powered by Google Fit | Synced 5m ago',
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This Week's Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Play Time & Calories side by side
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    icon: Icons.play_circle_filled_rounded,
                    label: 'Play Time',
                    value: '8h 15m',
                    color: const Color(0xFF00695C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    value: '2,450',
                    color: const Color(0xFF00796B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
