// lib/features/health/ui/widgets/heart_rate_chart.dart

import 'package:flutter/material.dart';
import 'package:health/health.dart';

class HeartRateChart extends StatelessWidget {
  final List<HealthDataPoint> data;

  const HeartRateChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<double> values = data
        .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _HeartRatePainter(values: values),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _HeartRatePainter extends CustomPainter {
  final List<double> values;

  _HeartRatePainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double minVal = values.reduce((a, b) => a < b ? a : b) - 10;
    final double maxVal = values.reduce((a, b) => a > b ? a : b) + 10;
    final double range = maxVal - minVal;

    final gridPaint = Paint()
      ..color = Colors.teal.withOpacity(0.1)
      ..strokeWidth = 1;
    const int gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = size.height * i / gridLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
   }
}
