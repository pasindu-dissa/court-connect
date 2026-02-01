import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/mock_data.dart';
import 'court_details_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isMapView = true;
  bool _isSearchVisible = false;
  CourtModel? _selectedCourt;
  
  // Filtering Logic
  List<SportType> _selectedFilters = [];
  String _searchQuery = "";

  // Get Filtered List
  List<CourtModel> get _filteredCourts {
    return mockCourts.where((court) {
      final matchesSearch = court.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            court.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilters.isEmpty || _selectedFilters.contains(court.sportType);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Main View (Map or List)
          _isMapView ? _buildMapView() : _buildListView(),

          // 2. Header (Filters, Search Toggle, Mode Toggle)
          Positioned(
            top: 60, left: 20, right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Filter Button
                    _buildGlassButton(
                      context,
                      icon: Icons.tune_rounded, 
                      label: "Filter", 
                      isActive: _selectedFilters.isNotEmpty,
                      onTap: _showFilterBottomSheet
                    ),
                    
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
                      }
                    ),

                    const Spacer(),

                    // Map/List Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.black.withOpacity(0.8), 
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: Row(children: [_buildToggleBtn("Map", true), _buildToggleBtn("List", false)]),
                    ),
                  ],
                ),
                
                // Search Bar (Animated)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearchVisible ? 60 : 0,
                  margin: const EdgeInsets.only(top: 10),
                  child: _isSearchVisible ? TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    decoration: InputDecoration(
                      hintText: "Search courts...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      isDense: true,
                    ),
                  ) : const SizedBox(),
                ),
              ],
            ),
          ),

          // 3. Bottom Preview Card (Map Only)
          if (_isMapView && _selectedCourt != null)
            Positioned(
              bottom: 110, left: 20, right: 20,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: _selectedCourt!))),
                child: _buildCourtPreviewCard(_selectedCourt!),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildMapView() {
    return GestureDetector(
      onTap: () => setState(() => _selectedCourt = null),
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
                onTap: () => setState(() => _selectedCourt = court),
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
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 150, 20, 120), // Extra top padding for search bar
      itemCount: _filteredCourts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: _filteredCourts[index]))),
          child: _buildCourtPreviewCard(_filteredCourts[index]),
        );
      },
    );
  }

  Widget _buildCourtPreviewCard(CourtModel court) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(court.image, width: 90, height: 90, fit: BoxFit.cover, 
              errorBuilder: (context, error, stackTrace) => Container(width: 90, height: 90, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _getStatusColor(court.status).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(court.status, style: TextStyle(color: _getStatusColor(court.status), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                    Text(court.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(court.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.titleLarge?.color)),
                Text(court.address, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text("LKR ${court.price}/hr", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildGlassButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Theme.of(context).cardColor.withOpacity(0.95), 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: isActive ? Colors.white : Theme.of(context).iconTheme.color), 
          const SizedBox(width: 8), 
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color))
        ]),
      ),
    );
  }

  IconData _getSportIcon(SportType type) {
    switch (type) {
      case SportType.badminton: return Icons.sports_tennis; // Closest for badminton
      case SportType.basketball: return Icons.sports_basketball;
      case SportType.football: return Icons.sports_soccer;
      case SportType.tennis: return Icons.sports_tennis;
      case SportType.cricket: return Icons.sports_cricket;
      case SportType.swimming: return Icons.pool;
    }
  }

  Color _getStatusColor(String status) {
    if (status == "Available") return Colors.green;
    if (status == "Busy") return Colors.red;
    return Colors.orange;
  }
}