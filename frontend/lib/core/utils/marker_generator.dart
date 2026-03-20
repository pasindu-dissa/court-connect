import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  // NEW: Cache system to prevent lag when rendering many pins
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> createCustomMarkerBitmap(
    String title, {
    required Color color,
    String? sport, 
  }) async {
    // Check if we already created this exact pin color + sport combo!
    final String cacheKey = '${color.value}_${sport ?? "default"}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    
    // Size limit to prevent giant markers
    const double size = 100.0; 
    
    final Paint circlePaint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0; 

    // Draw Main Circle & Border
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.2, circlePaint);
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.2, borderPaint);

    // Determine the correct icon based on the sport
    IconData iconData = Icons.location_on_rounded; // Default fallback
    
    if (sport != null && sport.isNotEmpty) {
      switch (sport.toLowerCase()) {
        case 'tennis': iconData = Icons.sports_tennis; break;
        case 'basketball': iconData = Icons.sports_basketball; break;
        case 'football': 
        case 'futsal': iconData = Icons.sports_soccer; break;
        case 'cricket': iconData = Icons.sports_cricket; break;
        case 'swimming': iconData = Icons.pool; break;
        case 'badminton': iconData = Icons.sports_tennis; break;
        default: iconData = Icons.sports; break;
      }
    }

    // Draw the Icon perfectly centered
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.55,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage, 
        color: Colors.white,
      ),
    );
    textPainter.layout();
    
    textPainter.paint(
      canvas, 
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2)
    );

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    
    final bitmap = BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    
    // Save to cache before returning
    _cache[cacheKey] = bitmap;
    return bitmap;
  }
}