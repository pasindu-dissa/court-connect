import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'summary_card.dart';
import 'daily_goal_card.dart';

// ---------------------------------------------------------------------------
// Mock state
// ---------------------------------------------------------------------------
class _HealthMockData {
  static const int playTimeHours = 8;
  static const int playTimeMinutes = 15;
  static const int caloriesBurned = 2450;
  static const int courtsVisited = 4;

  static const int hrAverage = 124;
  static const int hrMax = 162;
  static const int hrResting = 68;

  static const int activityGoalPct = 80;
  static const int caloriesGoalPct = 65;
  static const int activityCurrent = 48;
  static const int activityTarget = 60;
  static const int caloriesCurrent = 325;
  static const int caloriesTarget = 500;

  static const List<double> weeklyActivity = [
    0.55,
    0.45,
    0.68,
    0.60,
    1.0,
    0.38,
    0.72,
  ];
  static const List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static List<FlSpot> get heartRateSpots {
    const base = [
      124.0,
      118.0,
      132.0,
      128.0,
      140.0,
      135.0,
      122.0,
      130.0,
      145.0,
      138.0,
      127.0,
      133.0,
      119.0,
      125.0,
      142.0,
      137.0,
      129.0,
      121.0,
      134.0,
      141.0,
      126.0,
      116.0,
      131.0,
      143.0,
      136.0,
      128.0,
      118.0,
      125.0,
      138.0,
      144.0,
      132.0,
      127.0,
    ];
    return List.generate(base.length, (i) => FlSpot(i.toDouble(), base[i]));
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class HealthAnalysisScreen extends StatelessWidget {
  const HealthAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: textPrimary,
            ),
            onPressed: () =>
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
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
            // ── This Week's Summary ──────────────────────────────────
            _SectionHeader(
              title: "This Week's Summary",
              textColor: textPrimary,
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

            // ── Activity Levels ──────────────────────────────────────
            _SectionHeader(title: 'Activity Levels', textColor: textPrimary),
            Text(
              'Last 7 days',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 16),
            _ActivityBarChart(isDark: isDark),

            const SizedBox(height: 20),

            // ── Heart Rate ───────────────────────────────────────────
            _HeartRatePanel(
              cardColor: cardColor,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),

            const SizedBox(height: 28),

            // ── Daily Goals ──────────────────────────────────────────
            _SectionHeader(title: 'Daily Goals', textColor: textPrimary),
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

            // ── View Full History ────────────────────────────────────
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

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.textColor});
  final String title;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity bar chart
// ---------------------------------------------------------------------------
class _ActivityBarChart extends StatelessWidget {
  const _ActivityBarChart({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const highlightDay = 4;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _HealthMockData.weekDays[value.toInt()],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            _HealthMockData.weeklyActivity.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: _HealthMockData.weeklyActivity[i],
                  color: i == highlightDay
                      ? const Color(0xFF80CBC4)
                      : AppColors.primary,
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Heart rate panel
// ---------------------------------------------------------------------------
class _HeartRatePanel extends StatelessWidget {
  const _HeartRatePanel({
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Sparkline
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 110,
              child: LineChart(
                LineChartData(
                  minY: 60,
                  maxY: 180,
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withOpacity(0.08),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      color: Colors.white.withOpacity(0.08),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  backgroundColor: const Color(0xFF37474F),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _HealthMockData.heartRateSpots,
                      isCurved: true,
                      color: const Color(0xFFEF5350),
                      barWidth: 1.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFEF5350).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _HrStat(
                  label: 'Average',
                  value: '${_HealthMockData.hrAverage}',
                  unit: 'bpm',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Container(width: 1, height: 30, color: borderColor),
                _HrStat(
                  label: 'Max',
                  value: '${_HealthMockData.hrMax}',
                  unit: 'bpm',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Container(width: 1, height: 30, color: borderColor),
                _HrStat(
                  label: 'Resting',
                  value: '${_HealthMockData.hrResting}',
                  unit: 'bpm',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HrStat extends StatelessWidget {
  const _HrStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String label;
  final String value;
  final String unit;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
