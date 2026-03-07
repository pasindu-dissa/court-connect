import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'summary_card.dart';
import 'daily_goal_card.dart';

class _HealthMockData {
  static const int playTimeHours = 8;
  static const int playTimeMinutes = 15;
  static const int caloriesBurned = 2450;
  static const int courtsVisited = 4;

  static const int activityGoalPct = 80;
  static const int caloriesGoalPct = 65;
  static const int activityCurrent = 48;
  static const int activityTarget = 60;
  static const int caloriesCurrent = 325;
  static const int caloriesTarget = 500;
}

class HealthAnalysisScreen extends StatelessWidget {
  const HealthAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Dark mode values ─────────────────────────────────────────────────
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF2F4F7);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE0E0E0);
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
        // Dark mode toggle for testing
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: textPrimary,
            ),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
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
            // ── Summary section ──────────────────────────────────────
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
                    value:
                        '${_HealthMockData.playTimeHours}h ${_HealthMockData.playTimeMinutes}m',
                    color: const Color(0xFF00695C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    value: '${_HealthMockData.caloriesBurned}',
                    color: const Color(0xFF00796B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SummaryCard(
              icon: Icons.location_on_rounded,
              label: 'Courts Visited',
              value: '${_HealthMockData.courtsVisited}',
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
                Expanded(
                  child: DailyGoalCard(
                    icon: Icons.directions_run_rounded,
                    label: 'Activity',
                    sublabel:
                        '${_HealthMockData.activityCurrent} / ${_HealthMockData.activityTarget} min',
                    percent: _HealthMockData.activityGoalPct,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DailyGoalCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    sublabel:
                        '${_HealthMockData.caloriesCurrent} / ${_HealthMockData.caloriesTarget} kcal',
                    percent: _HealthMockData.caloriesGoalPct,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── View Full History button ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: navigate to full history screen
                },
                child: const Text(
                  'View Full History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
