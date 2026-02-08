import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/opponent_card.dart';
import '../widgets/match_card.dart'; // New Match Card
import '../widgets/interactive_map.dart'; 
import '../widgets/matchmaking_filters_modal.dart';
import 'create_team_screen.dart';
import 'match_details_screen.dart'; // New Details Screen

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
  
  // Opponent Sub-Filter (0=All, 1=Players, 2=Teams)
  int _opponentFilterIndex = 0;
  
  // Map State
  bool _isFiltered = false;
  List<Map<String, dynamic>> _scannedResults = [];
  // Selected item for map preview
  Map<String, dynamic>? _selectedMapItem;

  // --- MOCK DATA ---

  // 1. Matches (Tab 0)
  // Added "name" field to prevent Map crash (InteractiveMap expects 'name' for Marker ID)
  final List<Map<String, dynamic>> _mockMatches = [
    {
      "id": "m1", "name": "Royal Arena Match", "sport": "Tennis", "court": "Royal Arena", "location": "Cinnamon Gardens",
      "time": "10:00 AM", "skill": "Intermediate", "fee": 500.0, "current": 1, "max": 2,
      "lat": 6.9147, "lng": 79.8731, "image": "https://placehold.co/100x100"
    },
    {
      "id": "m2", "name": "Urban Hoops Match", "sport": "Basketball", "court": "Urban Hoops", "location": "Kollupitiya",
      "time": "04:30 PM", "skill": "Pro", "fee": 200.0, "current": 3, "max": 10,
      "lat": 6.9171, "lng": 79.8512, "image": "https://placehold.co/100x100"
    },
    {
      "id": "m3", "name": "City Club Match", "sport": "Futsal", "court": "City Club", "location": "Bambalapitiya",
      "time": "06:00 PM", "skill": "All Levels", "fee": 300.0, "current": 8, "max": 10,
      "lat": 6.8967, "lng": 79.8562, "image": "https://placehold.co/100x100"
    },
  ];

  // 2. Opponents (Tab 1) - Mixed Players & Teams
  final List<Map<String, dynamic>> _mockOpponents = [
    {"type": "player", "name": "Sarah J.", "image": "https://i.pravatar.cc/150?u=a", "skill": "Pro", "location": "Colombo 07", "wins": 42, "lat": 6.9200, "lng": 79.8600},
    {"type": "team", "name": "Colombo Kings", "image": "https://placehold.co/150x150/png?text=CK", "skill": "League A", "location": "Havelock", "wins": 12, "lat": 6.8833, "lng": 79.8660},
    {"type": "player", "name": "David P.", "image": "https://i.pravatar.cc/150?u=b", "skill": "Beginner", "location": "Nugegoda", "wins": 5, "lat": 6.8700, "lng": 79.8800},
    {"type": "team", "name": "Hoops Squad", "image": "https://placehold.co/150x150/png?text=HS", "skill": "League B", "location": "Wellawatte", "wins": 8, "lat": 6.8742, "lng": 79.8606},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize map data with Matches (default tab)
    _scannedResults = List.from(_mockMatches);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Switch map data based on tab
          _isFiltered = false; // Reset filter on tab switch
          _scannedResults = _tabController.index == 0 ? List.from(_mockMatches) : List.from(_mockOpponents);
          _selectedMapItem = null; // Clear selection when switching tabs
        });
      }
    });
  }

  // Logic to filter the list based on Tab and Search
  List<Map<String, dynamic>> get _currentListData {
    List<Map<String, dynamic>> data;
    
    if (_tabController.index == 0) {
      data = _mockMatches;
    } else {
      // Filter Opponents (All / Players / Teams)
      if (_opponentFilterIndex == 0) {
        data = _mockOpponents;
      } else if (_opponentFilterIndex == 1) {
        data = _mockOpponents.where((i) => i['type'] == 'player').toList();
      } else {
        data = _mockOpponents.where((i) => i['type'] == 'team').toList();
      }
    }

    if (_searchQuery.isEmpty) {
      return data;
    }
    return data.where((item) => 
      (item['name']?.toString().toLowerCase() ?? item['court']?.toString().toLowerCase() ?? "").contains(_searchQuery.toLowerCase()) ||
      (item['location']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMatchesTab = _tabController.index == 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
            if (!_isMapView) {
              if (isMatchesTab) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Create Match feature coming soon!")));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTeamScreen()));
              }
            } else {
              _openFilterModal();
            }
        },
        backgroundColor: AppColors.primary,
        icon: Icon(
          !_isMapView ? (isMatchesTab ? Icons.sports_tennis : Icons.group_add) : Icons.tune,
          color: Colors.white
        ),
        label: Text(
          !_isMapView ? (isMatchesTab ? "Host Match" : "Create Team") : "Filter Area",
          style: const TextStyle(color: Colors.white)
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [
          // 1. Content View
          Positioned.fill(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),

          // 2. Floating Header
          Positioned(
            top: 50, left: 20, right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Button: Search (List Mode) or Filter (Map Mode)
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
                      // Map Mode: Always show Filter button for custom scan
                      _buildGlassButton(
                        context,
                        icon: Icons.tune,
                        label: "Filter",
                        onTap: _openFilterModal,
                        isActive: _isFiltered
                      ),

                    const Spacer(),
                    
                    // Right Button: Map/List Toggle (Only show in Matches Tab)
                    if (_tabController.index == 0)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.black.withValues(alpha: 0.8),
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

                // Search Bar (Only in List View)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: (_isSearchVisible && !_isMapView) ? 60 : 0,
                  margin: const EdgeInsets.only(top: 10),
                  child: (_isSearchVisible && !_isMapView) ? TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search...",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ) : const SizedBox(),
                ),

                const SizedBox(height: 12),

                // Main Tabs (Matches vs Opponents)
                // Hide Tabs when in Map View
                if (!_isMapView)
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (index) => setState(() {}),
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [Tab(text: "Matches"), Tab(text: "Opponents")],
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                    ),
                  ),
                
                // Opponent Sub-Filters (Only visible in Opponents Tab and List View)
                if (!isMatchesTab && !_isMapView) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSubFilterBtn("All", 0),
                      const SizedBox(width: 10),
                      _buildSubFilterBtn("Players", 1),
                      const SizedBox(width: 10),
                      _buildSubFilterBtn("Teams", 2),
                    ],
                  ),
                ],
              ],
            ),
          ),
             
             // Reset/Clear Filter Button (When map is filtered)
             if (_isMapView && _isFiltered)
              Positioned(
                bottom: 120, right: 20,
                child: FloatingActionButton(
                  onPressed: () => setState(() { 
                    _isFiltered = false; 
                    _scannedResults = List.from(_mockMatches); 
                  }),
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.refresh, color: Colors.black),
                ),
              ),
          
          // 3. Bottom Preview Card (Map Mode Only)
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
            // _activeFilters = filters; // Unused in this version
            _scannedResults = List.from(_mockMatches); // Apply filter logic here
            _isFiltered = true;
          });
        },
      ),
    );
  }

  void _onMatchTap(Map<String, dynamic> match) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailsScreen(matchData: match)));
  }

  // --- WIDGETS ---

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 240, 20, 100),
      itemCount: _currentListData.length,
      itemBuilder: (context, index) {
        final item = _currentListData[index];
        
        if (_tabController.index == 0) {
          return MatchCard(
            sport: item['sport'],
            courtName: item['court'],
            time: item['time'],
            skill: item['skill'],
            currentPlayers: item['current'],
            maxPlayers: item['max'],
            fee: item['fee'],
            onTap: () => _onMatchTap(item),
          );
        } else {
          bool isTeam = item['type'] == 'team';
          return OpponentCard(
            name: item['name'],
            image: item['image'],
            skill: item['skill'],
            location: item['location'],
            wins: item['wins'],
            isTeam: isTeam,
          );
        }
      },
    );
  }

  Widget _buildMapView() {
    return InteractiveMap(
      data: _scannedResults, 
      isTeam: false, // Maps are only for matches now, so pins are generic/sport
      onMarkerTap: (item) {
         setState(() {
           _selectedMapItem = item;
         });
      },
    );
  }

  Widget _buildPreviewCard(Map<String, dynamic> item) {
    bool isMatch = _tabController.index == 0;
    // Fix: Handle different key names safely
    String title = isMatch ? (item['court'] ?? 'Unknown Court') : (item['name'] ?? 'Unknown');
    String subtitle = isMatch ? "${item['sport']} • ${item['time']}" : "${item['skill']} • ${item['location']}";
    bool isTeam = !isMatch && item['type'] == 'team';
    
    return GestureDetector(
      onTap: () {
        if (isMatch) {
          _onMatchTap(item);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, 
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))]
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(item['image'] ?? '')),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            if (isTeam) const Icon(Icons.shield, color: Colors.blue, size: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isMatch ? Icons.arrow_forward : (isTeam ? Icons.group_add : Icons.send), 
                color: AppColors.primary, 
                size: 20
              ),
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
          color: isActive ? AppColors.primary : Theme.of(context).cardColor.withValues(alpha: 0.9), 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: isActive ? Colors.white : Theme.of(context).iconTheme.color), 
          const SizedBox(width: 8), 
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color))
        ]),
      ),
    );
  }

  Widget _buildSubFilterBtn(String label, int index) {
    bool isSelected = _opponentFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _opponentFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12
          ),
        ),
      ),
    );
  }
}