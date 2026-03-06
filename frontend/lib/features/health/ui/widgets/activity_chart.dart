// lib/features/health/ui/widgets/activity_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityChartData {
  final String day;   // e.g. "Mon"
  final double value; // steps or calories

  const ActivityChartData({required this.day, required this.value});
}

class ActivityChart extends StatelessWidget {
  final List<ActivityChartData> data;
  final String unit; // "steps" or "kcal"
  final double maxY;

  const ActivityChart({
    super.key,
    required this.data,
    this.unit = 'steps',
    this.maxY = 10000,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.teal.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[index].day,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].value,
                ),  
              ], 
            ),
        },            
      ),
    );
  }
}
