import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/booking_service.dart';
import 'court_details_screen.dart';
import '../widgets/booking_filters_modal.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  final Completer<GoogleMapController> _mapController = Completer();
  
  // UI State
  bool _isMapView = true;
  bool _isLoading = true;
  bool _isSearchVisible = false;
  String _searchQuery = "";
  String? _sportFilter;

  // Data
  List<Map<String, dynamic>> _allCourts = [];
  Set<Marker> _markers = {};
  
  // Default Location (Colombo)
  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final courts = await _bookingService.getAllCourts();
    if (mounted) {
      setState(() {
        _allCourts = courts;
        _isLoading = false;
      });
      _updateMarkers(); // Generate markers initially
    }
  }

  // --- GPS LOGIC ---
  Future<void> _locateUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Get Position
    Position position = await Geolocator.getCurrentPosition();
    final GoogleMapController controller = await _mapController.future;
    
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14,
      ),
    ));
  }

  // --- FILTER & MARKER LOGIC ---
  List<Map<String, dynamic>> get _filteredCourts {
    return _allCourts.where((court) {
      final nameMatches = court['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final locationMatches = court['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final sportMatches = _sportFilter == null || 
                           court['sport'] == _sportFilter || 
                           (court['sports'] as List<dynamic>?)?.contains(_sportFilter) == true;
      
      return (nameMatches || locationMatches) && sportMatches;
    }).toList();
  }

  void _updateMarkers() {
    setState(() {
      _markers = _filteredCourts.map((court) {
        // Parse Lat/Lng safely
        double lat = (court['latitude'] as num?)?.toDouble() ?? 6.9271;
        double lng = (court['longitude'] as num?)?.toDouble() ?? 79.8612;

        return Marker(
          markerId: MarkerId(court['_id'] ?? court['name']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: court['name'], snippet: court['location']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Green for Courts
          onTap: () => _showCourtPreview(court),
        );
      }).toSet();
    });
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      
      // Refresh / Reset Button (Bottom Right)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _searchQuery = "";
            _sportFilter = null;
            _isSearchVisible = false;
          });
          _loadData(); // Re-fetch
        },
        backgroundColor: Colors.white,
        mini: true,
        child: const Icon(Icons.refresh, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [
          // 1. Main Content (Map or List)
          Positioned.fill(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : (_isMapView ? _buildGoogleMap() : _buildListView()),
          ),

          // 2. Floating Header (Search + Filter + Toggle)
          Positioned(
            top: 50, left: 20, right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Search & Filter Group
                    Row(
                      children: [
                        // Search Button
                        _buildGlassButton(
                          icon: _isSearchVisible ? Icons.close : Icons.search,
                          label: _isSearchVisible ? "Close" : "Search",
                          isActive: _isSearchVisible,
                          onTap: () => setState(() {
                            _isSearchVisible = !_isSearchVisible;
                            if (!_isSearchVisible) _searchQuery = "";
                          }),
                        ),
                        const SizedBox(width: 8),
                        
                        // Filter Button (Small)
                        _buildGlassIconBtn(
                          icon: Icons.tune, 
                          isActive: _sportFilter != null,
                          onTap: _showFilterModal,
                        ),
                      ],
                    ),

                    // Map/List Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          _buildToggleBtn("List", false),
                          _buildToggleBtn("Map", true),
                        ],
                      ),
                    ),
                  ],
                ),

                // Animated Search Bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearchVisible ? 60 : 0,
                  margin: const EdgeInsets.only(top: 10),
                  child: _isSearchVisible ? TextField(
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      if (_isMapView) _updateMarkers(); // Real-time marker update
                    },
                    decoration: InputDecoration(
                      hintText: "Search courts...",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ) : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB WIDGETS ---

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _defaultLocation,
      mapType: MapType.normal,
      markers: _markers,
      myLocationEnabled: true, // Show Blue Dot
      myLocationButtonEnabled: false, // We use custom logic if needed
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
        _locateUser(); // Auto-zoom to user on load
      },
    );
  }

  Widget _buildListView() {
    if (_filteredCourts.isEmpty) {
      return const Center(child: Text("No courts match your filter."));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 140, 20, 100),
      itemCount: _filteredCourts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: _filteredCourts[index]))),
          child: _buildCourtCard(_filteredCourts[index]),
        );
      },
    );
  }

  void _showCourtPreview(Map<String, dynamic> court) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: court)));
          },
          child: _buildCourtCard(court),
        ),
      )
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court) {
    String image = (court['images'] as List?)?.isNotEmpty == true ? court['images'][0] : "https://via.placeholder.com/150";
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(image, width: 90, height: 90, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[300]))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(court['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(court['location'], style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
            const SizedBox(height: 8),
            Text("LKR ${court['pricePerHour']}/hr", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ])),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingFiltersModal(
        onApply: (sport) {
          setState(() => _sportFilter = sport);
          if (_isMapView) _updateMarkers();
        }
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isMap) {
    final isActive = _isMapView == isMap;
    return GestureDetector(
      onTap: () => setState(() => _isMapView = isMap),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required String label, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
        child: Row(children: [
          Icon(icon, size: 20, color: isActive ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black)),
        ]),
      ),
    );
  }

  Widget _buildGlassIconBtn({required IconData icon, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
        child: Icon(icon, size: 20, color: isActive ? Colors.white : Colors.black),
      ),
    );
  }
}