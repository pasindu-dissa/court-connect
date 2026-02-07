import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class InteractiveMap extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final bool isTeam;
  final Function(Map<String, dynamic>) onMarkerTap;

  const InteractiveMap({
    super.key,
    required this.data,
    required this.isTeam,
    required this.onMarkerTap,
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  late AnimationController _radarController;
  
  // Initial Camera Position (Colombo)
  static const CameraPosition _colombo = CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 13,
  );

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _loadMarkers();
  }

  @override
  void didUpdateWidget(covariant InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _loadMarkers();
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _loadMarkers() {
    setState(() {
      _markers = widget.data.map((item) {
        return Marker(
          markerId: MarkerId(item['name']),
          position: LatLng(item['lat'], item['lng']),
          // Blue for Teams, Red for Players
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.isTeam ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
          ),
          onTap: () => widget.onMarkerTap(item),
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Google Map
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _colombo,
          markers: _markers,
          myLocationEnabled: true, // Show blue dot
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // Optional: Dark Mode Map Style could go here
          },
        ),

        // 2. Radar Scan Overlay (Engaging UI)
        IgnorePointer(
          child: Center(
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return Container(
                  width: 300 + (_radarController.value * 100), // Expands
                  height: 300 + (_radarController.value * 100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(1.0 - _radarController.value),
                      width: 2,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1 * (1.0 - _radarController.value)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 3. "Scanning Area" Text
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 10, height: 10,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Scanning area for ${widget.isTeam ? 'Teams' : 'Players'}...",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}