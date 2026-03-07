// lib/features/health/ui/widgets/health_charts_section.dart

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

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HealthNotifier>();

    if (notifier.hasError) {
      return _PermissionError(
        message: notifier.errorMessage,
        onRetry: () {
          notifier.clearError();
          notifier.loadAll();
        },
      );
    }

    if (notifier.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
        ),
      );
    }

    // Build last-7-days mock data from today's steps (real device will have full data)
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

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Heart Rate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        notifier.heartRateData.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No heart rate data available.',
                    style: TextStyle(color: Colors.grey)),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HeartRateChart(data: notifier.heartRateData),
              ),
      ],
    );
  }
}

class _PermissionError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PermissionError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.health_and_safety_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message.isEmpty ? 'Health permissions are required.' : message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Grant Permission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}