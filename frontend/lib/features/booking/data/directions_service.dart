import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/utils/polyline_decoder.dart';

class DirectionsService {
  // ⚠️ REPLACE WITH YOUR REAL KEY
  static const String _googleApiKey = "AIzaSyC5N0csklDUAKAmHw6B0XNriAYxaDO9tXU"; 

  Future<Map<String, dynamic>?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$_googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if ((data['routes'] as List).isEmpty) return null;

        final route = data['routes'][0];
        final overviewPolyline = route['overview_polyline']['points'];
        final distance = route['legs'][0]['distance']['text'];
        final duration = route['legs'][0]['duration']['text'];

        return {
          'polylinePoints': PolylineDecoder.decodePolyline(overviewPolyline),
          'distance': distance,
          'duration': duration,
          'bounds': route['bounds'],
        };
      }
    } catch (e) {
      print("Error fetching directions: $e");
    }
    return null;
  }
}