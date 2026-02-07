import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/opponent_card.dart';
import '../widgets/interactive_map.dart'; // Using the Real Map Widget
import '../widgets/matchmaking_filters_modal.dart';
import 'create_team_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMapView = false;
  bool _isSearchVisible = false;
  String _searchQuery = "";
  Map<String, dynamic>? _selectedMapItem;
  
  // Map State
  bool _hasScanned = false;
  List<Map<String, dynamic>> _scannedResults = [];
  Map<String, dynamic> _activeFilters = {};

  // Mock Data (Directory)
  final List<Map<String, dynamic>> _allPlayers = [
    {"name": "Sarah Jenkins", "image": "https://i.pravatar.cc/150?u=a", "skill": "Pro", "location": "Cinnamon Gardens", "wins": 42, "lat": 6.9147, "lng": 79.8731},
    {"name": "David Perera", "image": "https://i.pravatar.cc/150?u=b", "skill": "Intermediate", "location": "Kollupitiya", "wins": 15, "lat": 6.9171, "lng": 79.8512},
    {"name": "Kamal De Silva", "image": "https://i.pravatar.cc/150?u=c", "skill": "Beginner", "location": "Bambalapitiya", "wins": 3, "lat": 6.8967, "lng": 79.8562},
    {"name": "Jenny Doe", "image": "https://i.pravatar.cc/150?u=d", "skill": "Pro", "location": "Dehiwala", "wins": 28, "lat": 6.8511, "lng": 79.8659},
  ];

  final List<Map<String, dynamic>> _allTeams = [
    {"name": "Colombo Kings", "image": "https://placehold.co/150x150/png?text=CK", "skill": "League A", "location": "Havelock", "wins": 12, "lat": 6.8833, "lng": 79.8660},
    {"name": "Badminton Blasters", "image": "https://placehold.co/150x150/png?text=BB", "skill": "Casual", "location": "Rajagiriya", "wins": 5, "lat": 6.9096, "lng": 79.8953},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Filter for List View (Directory Search)
  List<Map<String, dynamic>> get _listData {
    final rawData = _tabController.index == 0 ? _allPlayers : _allTeams;
    if (_searchQuery.isEmpty) return rawData;
    return rawData.where((item) => 
      item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      
      // Create Team FAB (Only in List Mode -> Team Tab)
      floatingActionButton: (!_isMapView && _tabController.index == 1) 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTeamScreen())),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Create Team", style: TextStyle(color: Colors.white)),
          ) 
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [
          // 1. Main Content
          _isMapView ? _buildMapView() : _buildListView(),

          // 2. Header (Always Visible)
          Positioned(
            top: 50, left: 20, right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Search Button (Only for List View)
                    if (!_isMapView)
                      _buildGlassButton(
                        context,
                        icon: _isSearchVisible ? Icons.close : Icons.search,
                        label: _isSearchVisible ? "Close" : "Search",
                        onTap: () => setState(() {
                          _isSearchVisible = !_isSearchVisible;
                          if (!_isSearchVisible) _searchQuery = "";
                        }),
                        isActive: _isSearchVisible
                      )
                    else 
                      // Show Filter Summary in Map Mode
                      _hasScanned 
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                            child: Row(children: [
                                const Icon(Icons.radar, color: Colors.greenAccent, size: 16),
                                const SizedBox(width: 8),
                                Text("${_activeFilters['sport']} • ${_activeFilters['location']}", style: const TextStyle(color: Colors.white, fontSize: 12))
                            ]),
                          )
                        : const SizedBox(),

                    const Spacer(),
                    
                    // Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.black.withOpacity(0.8),
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

                // Search Bar (List Mode)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: (_isSearchVisible && !_isMapView) ? 60 : 0,
                  margin: const EdgeInsets.only(top: 10),
                  child: (_isSearchVisible && !_isMapView) ? TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search directory...",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ) : const SizedBox(),
                ),

                const SizedBox(height: 12),
                
                // Tabs (Only for List View switching)
                if (!_isMapView)
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (index) => setState(() {}),
                      indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(25)),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [Tab(text: "Opponents"), Tab(text: "Teams")],
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                  ),
              ],
            ),
          ),

          // 3. Map View Controls
          if (_isMapView && !_hasScanned)
             Positioned.fill(
               child: Container(
                 color: Colors.black.withOpacity(0.4), // Dim background
                 child: Center(
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Icon(Icons.public, size: 60, color: Colors.white),
                       const SizedBox(height: 16),
                       const Text("Find players near you", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 24),
                       ElevatedButton.icon(
                         onPressed: _openFilterModal,
                         icon: const Icon(Icons.radar),
                         label: const Text("Start Radar Scan"),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.primary,
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             ),

          // 4. Reset Scan Button (When map is active)
          if (_isMapView && _hasScanned)
            Positioned(
              bottom: 120, right: 20,
              child: FloatingActionButton(
                onPressed: () => setState(() { _hasScanned = false; _scannedResults = []; _selectedMapItem = null; }),
                backgroundColor: Colors.white,
                mini: true,
                child: const Icon(Icons.refresh, color: Colors.black),
              ),
            ),

          // 5. Bottom Preview Card
          if (_isMapView && _selectedMapItem != null)
            Positioned(
              bottom: 110, left: 20, right: 20,
              child: _buildPreviewCard(_selectedMapItem!),
            ),
        ],
      ),
    );
  }

  // --- LOGIC ---

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MatchmakingFiltersModal(
        onScan: (filters) {
          setState(() {
            _activeFilters = filters;
            // Simulate Finding Players (In real app, call API with filters)
            // We just grab all players/teams for demo
            _scannedResults = [..._allPlayers, ..._allTeams]; 
            _hasScanned = true;
          });
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildMapView() {
    // If not scanned yet, show empty map (or just the background behind the overlay)
    return InteractiveMap(
      data: _scannedResults, // Shows markers only after scan
      isTeam: false, // Map shows mixed pins
      onMarkerTap: (item) => setState(() => _selectedMapItem = item),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 240, 20, 100),
      itemCount: _listData.length,
      itemBuilder: (context, index) {
        final item = _listData[index];
        return OpponentCard(
          name: item['name'],
          image: item['image'],
          skill: item['skill'],
          location: item['location'],
          wins: item['wins'],
          isTeam: _tabController.index == 1,
        );
      },
    );
  }

  Widget _buildPreviewCard(Map<String, dynamic> item) {
    // Determine if item is a team based on having "League" in skill (Mock logic)
    bool isItemTeam = item['skill'].toString().contains("League") || item['skill'].toString().contains("Casual");
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 28, backgroundImage: NetworkImage(item['image'])),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("${item['skill']} • ${item['location']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              if (isItemTeam) const Icon(Icons.shield, color: Colors.blue, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Request Sent! Waiting for acceptance."),
                  backgroundColor: Colors.green,
                ));
                setState(() => _selectedMapItem = null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Send Request"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isMap) {
    final isActive = _isMapView == isMap;
    return GestureDetector(
      onTap: () => setState(() { 
        _isMapView = isMap;
        if (!isMap) {
           _selectedMapItem = null; // Clear map selection when going to list
           _isSearchVisible = false; // Reset search
        }
      }),
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
          color: isActive ? AppColors.primary : Theme.of(context).cardColor.withOpacity(0.9), 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: isActive ? Colors.white : Theme.of(context).iconTheme.color), 
          const SizedBox(width: 8), 
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color))
        ]),
      ),
    );
  }
}