// Commit 16: Implement Circular Progress for Calories goal
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'summary_card.dart';
import 'daily_goal_card.dart';

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
            // ── Summary section ─────────────────────────────────────
            Text(
              "This Week's Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            SummaryCard(
              icon: Icons.location_on_rounded,
              label: 'Courts Visited',
              value: '4',
              color: const Color(0xFF00897B),
            ),

            const SizedBox(height: 28),

            // ── Daily Goals section ──────────────────────────────────
            Text(
              'Daily Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // Activity goal
                Expanded(
                  child: DailyGoalCard(
                    icon: Icons.directions_run_rounded,
                    label: 'Activity',
                    sublabel: '48 / 60 min',
                    percent: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                // Calories goal
                Expanded(
                  child: DailyGoalCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    sublabel: '325 / 500 kcal',
                    percent: 65,
                    color: AppColors.primary,
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
