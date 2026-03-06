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
    final linePaint = Paint()
      ..color = const Color(0xFF00BFA5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - (size.height * (values[i] - minVal) / range);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Smooth cubic bezier
        final prevX = size.width * (i - 1) / (values.length - 1);
        final prevY = size.height - (size.height * (values[i - 1] - minVal) / range);
        final controlX1 = prevX + (x - prevX) / 2;
        path.cubicTo(controlX1, prevY, controlX1, y, x, y);
      }
    }

    // Fill gradient under line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00BFA5).withOpacity(0.3),
          const Color(0xFF00BFA5).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _HeartRatePainter old) => old.values != values;
}

class _StatLabel extends StatelessWidget {
  final String label;
  final String value;

  const _StatLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF00BFA5))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}