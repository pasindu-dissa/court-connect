import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/health_notifier.dart';
import 'activity_chart.dart';
import 'heart_rate_chart.dart';

class HealthChartsSection extends StatefulWidget {
  const HealthChartsSection({super.key});

  @override
  State<HealthChartsSection> createState() => _HealthChartsSectionState();
}

class _HealthChartsSectionState extends State<HealthChartsSection> {
  @override
  void initState() {
    super.initState();
    // Load data when section mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthNotifier>().loadAll();
    });
  }
}
  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HealthNotifier>();
  }

  final activityData = List.generate(7, (i) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      // Today's real steps for last bar, simulated for others
      final value = i == 6
          ? notifier.steps.toDouble()
          : (notifier.steps * (0.5 + i * 0.08)).clamp(0, 15000).toDouble();
      return ActivityChartData(day: days[i], value: value);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Activity (Steps)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ActivityChart(
            data: activityData,
            unit: 'steps',
            maxY: 12000,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
