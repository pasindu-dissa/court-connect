import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/marker_generator.dart';
import '../../../../core/services/user_provider.dart';
import '../../data/matchmaking_service.dart';
import '../widgets/match_card.dart';
import '../widgets/matchmaking_filters_modal.dart';
import 'create_match_screen.dart';
import 'match_details_screen.dart'; // Implemented below

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final MatchmakingService _matchmakingService = MatchmakingService();
  final Completer<GoogleMapController> _mapController = Completer();

  bool _isLoading = true;
  bool _isMapView = false;
  bool _isSearchVisible = false;
  String _searchQuery = "";
  String? _sportFilter;
  String? _skillFilter;
  String? _timeFilter;
  String? _locationFilter;

  List<Map<String, dynamic>> _matches = [];
  Set<Marker> _markers = {};

  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final matchesData = await _matchmakingService.getMatches();

    if (mounted) {
      setState(() {
        _matches = matchesData;
        _isLoading = false;
      });
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    Set<Marker> newMarkers = {};
    final BitmapDescriptor matchIcon =
        await MarkerGenerator.createCustomMarkerBitmap(
          "Match",
          color: AppColors.primary,
        );

    for (var match in _filteredMatches) {
      double lat = (match['latitude'] ?? 6.9271).toDouble();
      double lng = (match['longitude'] ?? 79.8612).toDouble();
      String id = match['_id'] ?? match['title'];

      newMarkers.add(
        Marker(
          markerId: MarkerId(id),
          position: LatLng(lat, lng),
          icon: matchIcon,
          onTap: () => _showMatchPreviewBottomSheet(match),
        ),
      );
    }

    setState(() => _markers = newMarkers);
  }

  Future<void> _locateUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 13,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredMatches {
    return _matches.where((match) {
      final matchesSearch = (match['title'] ?? match['courtName'] ?? "")
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesSport =
          _sportFilter == null || match['sport'] == _sportFilter;
      final matchesSkill =
          _skillFilter == null || match['skill'] == _skillFilter;
      final matchesLocation =
          _locationFilter == null ||
          (match['location'] ?? "").toString().toLowerCase().contains(
            _locationFilter!.toLowerCase(),
          );

      // Calculate Time duration match
      bool matchesTime = true;
      if (_timeFilter != null) {
        final timeStr = match['time'] ?? "";
        if (timeStr.isNotEmpty) {
          final isAM = timeStr.contains("AM");
          final hourStr = timeStr.split(":")[0];
          int hour = int.tryParse(hourStr) ?? 12;
          if (hour == 12 && isAM) hour = 0;
          if (hour != 12 && !isAM) hour += 12;

          if (_timeFilter == "Morning") {
            matchesTime = (hour >= 5 && hour < 12);
          } else if (_timeFilter == "Afternoon")
            matchesTime = (hour >= 12 && hour < 17);
          else if (_timeFilter == "Evening")
            matchesTime = (hour >= 17 && hour < 20);
          else if (_timeFilter == "Night")
            matchesTime = (hour >= 20 || hour < 5);
        }
      }

      return matchesSearch &&
          matchesSport &&
          matchesSkill &&
          matchesLocation &&
          matchesTime;
    }).toList();
  }

  void _navigateToDetails(Map<String, dynamic> match) async {
    // Navigate and wait to see if data changed (e.g. joined, edited, unpublished)
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MatchDetailsScreen(matchData: match)),
    );
    if (shouldRefresh == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,

      floatingActionButton: !_isMapView
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final newMatch = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateMatchScreen(),
                    ),
                  );
                  if (newMatch != null) _loadData();
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text(
                  "Host Match",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
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
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildGlassButton(
                          context,
                          icon: _isSearchVisible ? Icons.close : Icons.search,
                          label: _isSearchVisible ? "Close" : "Search",
                          onTap: () => setState(() {
                            _isSearchVisible = !_isSearchVisible;
                            if (!_isSearchVisible) {
                              _searchQuery = "";
                              _updateMarkers();
                            }
                          }),
                          isActive: _isSearchVisible,
                        ),
                        const SizedBox(width: 8),
                        _buildGlassIconBtn(
                          context,
                          icon: Icons.tune,
                          isActive:
                              _sportFilter != null ||
                              _skillFilter != null ||
                              _timeFilter != null ||
                              _locationFilter != null,
                          onTap: _openFilterModal,
                        ),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[800]
                            : Colors.black.withValues(alpha: 0.8),
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
                            hintText: "Search matches...",
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MatchmakingFiltersModal(
        onScan: (filters) {
          setState(() {
            _sportFilter = filters['sport'];
            _skillFilter = filters['skill'];
            _timeFilter = filters['timeDuration'];
            _locationFilter = filters['location'];
          });
          if (_isMapView) _updateMarkers();
        },
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _defaultLocation,
      mapType: MapType.normal,
      markers: _markers,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      onMapCreated: (c) {
        if (!_mapController.isCompleted) {
          _mapController.complete(c);
        }
        _locateUser();
      },
    );
  }

  Widget _buildListView() {
    if (_filteredMatches.isEmpty) {
      return const Center(child: Text("No active matches found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 140, 20, 150),
      itemCount: _filteredMatches.length,
      itemBuilder: (context, index) {
        final item = _filteredMatches[index];
        return MatchCard(
          sport: item['sport'] ?? "Sport",
          courtName: item['title'] ?? item['courtName'] ?? "Match",
          time: item['time'] ?? "Upcoming",
          skill: item['skill'] ?? "All Levels",
          currentPlayers: item['currentPlayers'] ?? 1,
          maxPlayers: item['maxPlayers'] ?? 4,
          fee: (item['fee'] ?? 0).toDouble(),
          onTap: () => _navigateToDetails(item), // Opens Details Screen
        );
      },
    );
  }

  // Modern Bottom Sheet for Map Pins
  void _showMatchPreviewBottomSheet(Map<String, dynamic> match) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    bool isHost = currentUser != null && match['hostId'] == currentUser['_id'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    match['image'] ??
                        "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match['title'] ?? match['courtName'] ?? 'Match',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${match['sport']} • ${match['time']}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "LKR ${match['fee'] ?? 0} per person",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                      _navigateToDetails(match); // Open Details Screen
                    },
                    icon: Icon(isHost ? Icons.edit : Icons.info_outline),
                    label: Text(isHost ? "Manage Match" : "View Full Details"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHost
                          ? Colors.orange
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildGlassButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : Theme.of(context).cardColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? Colors.white
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassIconBtn(
    BuildContext context, {
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
              : Theme.of(context).cardColor.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
