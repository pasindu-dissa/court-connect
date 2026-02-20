import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/directions_service.dart';

class DirectionsMapScreen extends StatefulWidget {
  final Map<String, dynamic> court;
  
  const DirectionsMapScreen({super.key, required this.court});

  @override
  State<DirectionsMapScreen> createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen> {
  final DirectionsService _directionsService = DirectionsService();
  GoogleMapController? _mapController;
  
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  String _distance = "";
  String _duration = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDirections();
  }

  Future<void> _initDirections() async {
    // 1. Get User Location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentLocation = LatLng(position.latitude, position.longitude);

    // 2. Get Court Location
    double destLat = (widget.court['latitude'] as num).toDouble();
    double destLng = (widget.court['longitude'] as num).toDouble();
    LatLng destination = LatLng(destLat, destLng);

    // 3. Fetch Route
    final directions = await _directionsService.getDirections(
      origin: _currentLocation!,
      destination: destination,
    );

    if (directions != null && mounted) {
      setState(() {
        _distance = directions['distance'];
        _duration = directions['duration'];
        
        // Draw Route Line
        _polylines.add(Polyline(
          polylineId: const PolylineId("route"),
          points: directions['polylinePoints'],
          color: Colors.blue,
          width: 5,
        ));

        // Add Pins
        _markers.add(Marker(
          markerId: const MarkerId("start"),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "You"),
        ));
        
        _markers.add(Marker(
          markerId: const MarkerId("dest"),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: widget.court['name']),
        ));

        _isLoading = false;
      });

      // Zoom to fit route
      await Future.delayed(const Duration(milliseconds: 500));
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList(directions['polylinePoints']),
          50.0,
        ),
      );
    } else {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to zoom map correctly
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;
    for (final latLng in list) {
      if (minLat == null || latLng.latitude < minLat) minLat = latLng.latitude;
      if (maxLat == null || latLng.latitude > maxLat) maxLat = latLng.latitude;
      if (minLng == null || latLng.longitude < minLng) minLng = latLng.longitude;
      if (maxLng == null || latLng.longitude > maxLng) maxLng = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(6.9271, 79.8612), zoom: 12),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (c) => _mapController = c,
          ),
          
          // Back Button
          Positioned(
            top: 50, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Info Card
          if (!_isLoading && _duration.isNotEmpty)
            Positioned(
              bottom: 30, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.directions_car, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$_duration ($_distance)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Text("Fastest route now", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {}, // Optional: Open external map if they really want
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text("Start"),
                    )
                  ],
                ),
              ),
            ),
            
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}