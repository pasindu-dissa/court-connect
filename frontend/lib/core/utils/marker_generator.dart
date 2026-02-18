import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  static Future<BitmapDescriptor> createCustomMarkerBitmap(String title, {required Color color}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    
    // Config
    const double size = 120.0;
    final Paint circlePaint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    // 1. Draw Shadow
    canvas.drawCircle(const Offset(size / 2, size / 2 + 5), size / 2.2, shadowPaint);

    // 2. Draw Main Circle
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.2, circlePaint);
    
    // 3. Draw White Border
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.2, borderPaint);

    // 4. Draw Icon (Sport Icon)
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.location_on_rounded.codePoint),
      style: TextStyle(
        fontSize: size * 0.5,
        fontFamily: Icons.location_on_rounded.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}