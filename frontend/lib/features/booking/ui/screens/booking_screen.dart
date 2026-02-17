import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/booking_service.dart'; // Import Service
import 'court_details_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  bool _isMapView = true;
  List<Map<String, dynamic>> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourts();
  }

  Future<void> _fetchCourts() async {
    final courts = await _bookingService.getAllCourts();
    if (mounted) {
      setState(() {
        _courts = courts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Main Content (Map or List)
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : (_isMapView ? _buildMapView() : _buildListView()),

          // 2. Floating Header & Toggle
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(
                  icon: Icons.refresh,
                  label: "Refresh",
                  onTap: _fetchCourts,
                ),
                // Toggle Switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _buildToggleBtn("Map", true),
                      _buildToggleBtn("List", false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildMapView() {
    // Placeholder Map logic (In a real app, use Google Maps widget here)
    // For now, we display markers visually on a static background
    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://placehold.co/800x1200/png?text=Map+View"), // Placeholder
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: Stack(
          children: _courts.map((court) {
            // Use real lat/lng to position loosely on screen for demo
            // In real Google Map, you pass LatLng directly
            return Positioned(
              // Mock positioning calculation for demo purposes:
              top: (court['latitude'] != null ? (court['latitude'] % 10) * 80 : 300).toDouble(),
              left: (court['longitude'] != null ? (court['longitude'] % 10) * 40 : 100).toDouble(),
              child: GestureDetector(
                onTap: () => _showCourtPreview(court),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                      ),
                      child: const Icon(Icons.sports_tennis, color: Colors.white, size: 20),
                    ),
                    Container(height: 10, width: 2, color: Colors.black54)
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_courts.isEmpty) {
      return const Center(child: Text("No courts available yet."));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 120),
      itemCount: _courts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: _courts[index])),
          ),
          child: _buildCourtPreviewCard(_courts[index]),
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
          child: _buildCourtPreviewCard(court),
        ),
      )
    );
  }

  Widget _buildCourtPreviewCard(Map<String, dynamic> court) {
    String image = (court['images'] as List?)?.isNotEmpty == true 
        ? court['images'][0] 
        : "https://via.placeholder.com/150";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              image, 
              width: 90, height: 90, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[300]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(court['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(court['location'], style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
                const SizedBox(height: 8),
                Text("LKR ${court['pricePerHour']}/hr", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
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

  Widget _buildGlassButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}