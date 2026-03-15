import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import '../../../../core/constants/app_colors.dart';
<<<<<<< HEAD
import '../../../../core/utils/marker_generator.dart';
import '../../data/booking_service.dart';
import '../widgets/court_card.dart'; 
=======
import '../../../../core/services/app_activity_service.dart';
import '../../data/mock_data.dart';
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
import 'court_details_screen.dart';
import 'directions_map_screen.dart';
import '../widgets/booking_filters_modal.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  final Completer<GoogleMapController> _mapController = Completer();
  
  bool _isMapView = false;
  bool _isLoading = true;
  bool _isSearchVisible = false;
  String _searchQuery = "";
  String? _sportFilter;

  List<Map<String, dynamic>> _allCourts = [];
  Set<Marker> _markers = {};
  
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
      await _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    Set<Marker> newMarkers = {};
    
    final BitmapDescriptor availableIcon = await MarkerGenerator.createCustomMarkerBitmap("Court", color: const Color(0xFF00C853));
    final BitmapDescriptor busyIcon = await MarkerGenerator.createCustomMarkerBitmap("Court", color: const Color(0xFFFF3D00));

    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (var court in _filteredCourts) {
      double lat = (court['latitude'] as num?)?.toDouble() ?? 6.9271;
      double lng = (court['longitude'] as num?)?.toDouble() ?? 79.8612;
      
      // REAL LOGIC: Check today's bookings. 
      // 17 total slots per day. If >= 8 are booked, consider it busy/red.
      bool isBusy = false;
      if (court['_id'] != null) {
        try {
          List<String> bookedSlots = await _bookingService.getBookedSlots(court['_id'], todayStr);
          isBusy = bookedSlots.length >= 8; 
        } catch (e) {
          isBusy = false;
        }
      }

      newMarkers.add(Marker(
        markerId: MarkerId(court['_id'] ?? court['name']),
        position: LatLng(lat, lng),
        icon: isBusy ? busyIcon : availableIcon,
        onTap: () => _showCourtPreview(court),
      ));
    }

    if (mounted) {
      setState(() => _markers = newMarkers);
    }
  }

  Future<void> _locateUser() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    Position position = await Geolocator.getCurrentPosition();
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 14),
    ));
  }

  List<Map<String, dynamic>> get _filteredCourts {
    return _allCourts.where((court) {
      final matchesSearch = court['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSport = _sportFilter == null || 
                           court['sport'] == _sportFilter || 
                           (court['sports'] as List<dynamic>?)?.contains(_sportFilter) == true;
      return matchesSearch && matchesSport;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    AppActivityService.instance.recordScreenView('bookings');
    _recordActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() { _searchQuery = ""; _sportFilter = null; _isSearchVisible = false; });
          _updateMarkers(); // Will refetch availability
        },
        backgroundColor: Colors.white,
        mini: true,
        child: const Icon(Icons.refresh, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [
          Positioned.fill(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : (_isMapView ? _buildGoogleMap() : _buildListView()),
          ),

          // Header
          Positioned(
            top: 50, left: 20, right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildGlassButton(
                          icon: _isSearchVisible ? Icons.close : Icons.search,
                          label: _isSearchVisible ? "Close" : "Search",
                          isActive: _isSearchVisible,
                          onTap: () => setState(() => _isSearchVisible = !_isSearchVisible),
                        ),
                        const SizedBox(width: 8),
                        _buildGlassIconBtn(
                          icon: Icons.tune, 
                          isActive: _sportFilter != null,
                          onTap: _showFilterModal,
                        ),
                      ],
                    ),
<<<<<<< HEAD
=======
                    
                    const SizedBox(width: 8),

                    // Search Toggle Button
                    _buildGlassButton(
                      context,
                      icon: _isSearchVisible ? Icons.close : Icons.search, 
                      label: "Search", 
                      onTap: () {
                         setState(() {
                           _isSearchVisible = !_isSearchVisible;
                           if (!_isSearchVisible) _searchQuery = ""; // Clear on close
                         });
                         _recordActivity();
                      }
                    ),

                    const Spacer(),

                    // Map/List Toggle
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(30)),
                      child: Row(children: [_buildToggleBtn("List", false), _buildToggleBtn("Map", true)]),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearchVisible ? 60 : 0,
                  margin: const EdgeInsets.only(top: 10),
                  child: _isSearchVisible ? TextField(
<<<<<<< HEAD
                    onChanged: (val) { setState(() => _searchQuery = val); if(_isMapView) _updateMarkers(); },
=======
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _recordActivity(searchQuery: val);
                    },
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
                    decoration: InputDecoration(
                      hintText: "Search courts...", filled: true, fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ) : const SizedBox(),
                ),
              ],
            ),
          ),

          if (_isMapView && !_isLoading)
            Positioned(
              bottom: 30, left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem("Available", const Color(0xFF00C853)),
                    const SizedBox(height: 8),
                    _buildLegendItem("Busy / Full", const Color(0xFFFF3D00)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _defaultLocation,
      mapType: MapType.normal,
      markers: _markers,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      onMapCreated: (c) { _mapController.complete(c); _locateUser(); },
=======
  Widget _buildMapView() {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCourt = null);
        _recordActivity(selectedCourt: '');
      },
      child: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://placehold.co/800x1200/png?text=Map+View"), 
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: Stack(
          children: _filteredCourts.map((court) {
            return Positioned(
              top: MediaQuery.of(context).size.height * court.top,
              left: MediaQuery.of(context).size.width * court.left,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedCourt = court);
                  _recordActivity(selectedCourt: court.name);
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(court.status), 
                        shape: BoxShape.circle, 
                        border: Border.all(color: Colors.white, width: 2), 
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]
                      ),
                      // Dynamic Icon based on Sport Type
                      child: Icon(_getSportIcon(court.sportType), color: Colors.white, size: 22),
                    ),
                    // Pin Needle
                    Container(height: 10, width: 2, color: Colors.black54)
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 140, 20, 100),
      itemCount: _filteredCourts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
<<<<<<< HEAD
        return CourtCard(
          court: _filteredCourts[index],
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: _filteredCourts[index])));
            _updateMarkers(); // Refresh pin colors when coming back
          },
=======
        final court = _filteredCourts[index];
        return GestureDetector(
          onTap: () {
            _recordActivity(selectedCourt: court.name);
            Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: court)));
          },
          child: _buildCourtPreviewCard(court),
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CourtCard(
              court: court,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: court)));
                _updateMarkers();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DirectionsMapScreen(court: court)));
                    },
                    icon: const Icon(Icons.directions, color: Colors.blue),
                    label: const Text("Directions"),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: court)));
                      _updateMarkers();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text("Book Now"),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }

<<<<<<< HEAD
  void _showFilterModal() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => BookingFiltersModal(onApply: (sport) { setState(() => _sportFilter = sport); if(_isMapView) _updateMarkers(); }));
=======
  // --- HELPERS ---

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filter by Sport", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: SportType.values.map((type) {
                      final isSelected = _selectedFilters.contains(type);
                      return FilterChip(
                        label: Text(type.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedFilters.add(type);
                            } else {
                              _selectedFilters.remove(type);
                            }
                          });
                          setState(() {}); // Update Parent Screen
                          _recordActivity();
                        },
                        checkmarkColor: Colors.white,
                        selectedColor: AppColors.primary,
                        backgroundColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: AppColors.primary),
                    child: const Text("Apply Filters"),
                  )
                ],
              ),
            );
          },
        );
      }
    );
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
  }

  Widget _buildToggleBtn(String text, bool isMap) {
    final isActive = _isMapView == isMap;
<<<<<<< HEAD
    return GestureDetector(onTap: () => setState(() => _isMapView = isMap), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.w600))));
=======
    return GestureDetector(
      onTap: () {
        setState(() => _isMapView = isMap);
        _recordActivity(bookingView: isMap ? 'map' : 'list');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
  }

  Widget _buildGlassButton({required IconData icon, required String label, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]), child: Row(children: [Icon(icon, size: 20, color: isActive ? Colors.white : Colors.black), const SizedBox(width: 8), Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black))])));
  }

  Widget _buildGlassIconBtn({required IconData icon, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]), child: Icon(icon, size: 20, color: isActive ? Colors.white : Colors.black)));
  }

  void _recordActivity({
    String? searchQuery,
    String? selectedCourt,
    String? bookingView,
  }) {
    final selectedSport = _selectedFilters.isNotEmpty
        ? _selectedFilters.first.name
        : null;

    AppActivityService.instance.recordBookingState(
      selectedSport: selectedSport,
      searchQuery: searchQuery ?? _searchQuery,
      selectedCourt: selectedCourt ?? _selectedCourt?.name,
      bookingView: bookingView ?? (_isMapView ? 'map' : 'list'),
      selectedFilterCount: _selectedFilters.length,
    );
  }
}
