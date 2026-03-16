import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/marker_generator.dart';
import '../../data/booking_service.dart';
import '../widgets/booking_filters_modal.dart';
import '../widgets/court_card.dart';
import 'court_details_screen.dart';
import 'directions_map_screen.dart';

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
  String _searchQuery = '';
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
    if (!mounted) return;
    setState(() {
      _allCourts = courts;
      _isLoading = false;
    });
    await _updateMarkers();
  }

  Future<void> _updateMarkers() async {
    final newMarkers = <Marker>{};
    final availableIcon = await MarkerGenerator.createCustomMarkerBitmap(
      'Court',
      color: const Color(0xFF00C853),
    );
    final busyIcon = await MarkerGenerator.createCustomMarkerBitmap(
      'Court',
      color: const Color(0xFFFF3D00),
    );

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (final court in _filteredCourts) {
      final lat = (court['latitude'] as num?)?.toDouble() ?? 6.9271;
      final lng = (court['longitude'] as num?)?.toDouble() ?? 79.8612;

      var isBusy = false;
      if (court['_id'] != null) {
        try {
          final bookedSlots =
              await _bookingService.getBookedSlots(court['_id'], todayStr);
          isBusy = bookedSlots.length >= 8;
        } catch (_) {
          isBusy = false;
        }
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(court['_id'] ?? court['name']),
          position: LatLng(lat, lng),
          icon: isBusy ? busyIcon : availableIcon,
          onTap: () => _showCourtPreview(court),
        ),
      );
    }

    if (mounted) {
      setState(() => _markers = newMarkers);
    }
  }

  Future<void> _locateUser() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredCourts {
    return _allCourts.where((court) {
      final matchesSearch = court['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesSport = _sportFilter == null ||
          court['sport'] == _sportFilter ||
          (court['sports'] as List<dynamic>?)?.contains(_sportFilter) == true;
      return matchesSearch && matchesSport;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _searchQuery = '';
            _sportFilter = null;
            _isSearchVisible = false;
          });
          _updateMarkers();
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
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildGlassButton(
                          icon: _isSearchVisible ? Icons.close : Icons.search,
                          label: _isSearchVisible ? 'Close' : 'Search',
                          isActive: _isSearchVisible,
                          onTap: () => setState(
                            () => _isSearchVisible = !_isSearchVisible,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildGlassIconBtn(
                          icon: Icons.tune,
                          isActive: _sportFilter != null,
                          onTap: _showFilterModal,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          _buildToggleBtn('List', false),
                          _buildToggleBtn('Map', true),
                        ],
                      ),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearchVisible ? 60 : 0,
                  margin: const EdgeInsets.only(top: 10),
                  child: _isSearchVisible
                      ? TextField(
                          onChanged: (val) {
                            setState(() => _searchQuery = val);
                            if (_isMapView) _updateMarkers();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search courts...',
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
          if (_isMapView && !_isLoading)
            Positioned(
              bottom: 30,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem('Available', const Color(0xFF00C853)),
                    const SizedBox(height: 8),
                    _buildLegendItem('Busy / Full', const Color(0xFFFF3D00)),
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
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _defaultLocation,
      mapType: MapType.normal,
      markers: _markers,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        _mapController.complete(controller);
        _locateUser();
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 140, 20, 100),
      itemCount: _filteredCourts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final court = _filteredCourts[index];
        return CourtCard(
          court: court,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourtDetailsScreen(court: court),
              ),
            );
            _updateMarkers();
          },
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
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CourtCard(
              court: court,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourtDetailsScreen(court: court),
                  ),
                );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DirectionsMapScreen(court: court),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions, color: Colors.blue),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourtDetailsScreen(court: court),
                        ),
                      );
                      _updateMarkers();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        },
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isMap) {
    final isActive = _isMapView == isMap;
    return GestureDetector(
      onTap: () => setState(() => _isMapView = isMap),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassIconBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
