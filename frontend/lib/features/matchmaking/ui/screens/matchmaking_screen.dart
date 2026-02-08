import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/opponent_card.dart';
import '../widgets/match_card.dart';
import '../widgets/interactive_map.dart'; 
import '../widgets/matchmaking_filters_modal.dart';
import 'create_team_screen.dart';
import 'create_match_screen.dart'; // Import New Screen
import 'match_details_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = false;
  bool _isMapView = false;
  bool _isSearchVisible = false;
  String _searchQuery = "";
  
  // Data State with Mock Data
  List<Map<String, dynamic>> _matches = [
    {
      "id": "m1", "name": "Morning Tennis", "sport": "Tennis", "courtName": "Royal Arena", "location": "Cinnamon Gardens",
      "time": "10:00 AM", "skill": "Intermediate", "fee": 500.0, "currentPlayers": 1, "maxPlayers": 2,
      "lat": 6.9147, "lng": 79.8731, "image": "https://images.unsplash.com/photo-1626224583764-847890e058f5?q=80&w=200"
    },
    {
      "id": "m2", "name": "3v3 Hoops", "sport": "Basketball", "courtName": "Urban Hoops", "location": "Kollupitiya",
      "time": "04:30 PM", "skill": "Pro", "fee": 200.0, "currentPlayers": 3, "maxPlayers": 6,
      "lat": 6.9171, "lng": 79.8512, "image": "https://images.unsplash.com/photo-1546519638-68e109498ee2?q=80&w=200"
    },
    {
      "id": "m3", "name": "Futsal Night", "sport": "Futsal", "courtName": "City Club", "location": "Bambalapitiya",
      "time": "07:00 PM", "skill": "All Levels", "fee": 300.0, "currentPlayers": 8, "maxPlayers": 10,
      "lat": 6.8967, "lng": 79.8562, "image": "https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=200"
    },
    {
      "id": "m4", "name": "Weekend Cricket", "sport": "Cricket", "courtName": "NCC Grounds", "location": "Maitland Place",
      "time": "09:00 AM", "skill": "Intermediate", "fee": 100.0, "currentPlayers": 18, "maxPlayers": 22,
      "lat": 6.9061, "lng": 79.8696, "image": "https://images.unsplash.com/photo-1531415074968-036ba1b575da?q=80&w=200"
    },
  ];

  final List<Map<String, dynamic>> _opponents = [
    {"type": "player", "name": "Sarah J.", "image": "https://i.pravatar.cc/150?u=a", "skill": "Pro", "location": "Colombo 07", "wins": 42, "lat": 6.9200, "lng": 79.8600},
    {"type": "team", "name": "Colombo Kings", "image": "https://placehold.co/150x150/png?text=CK", "skill": "League A", "location": "Havelock", "wins": 12, "lat": 6.8833, "lng": 79.8660},
    {"type": "player", "name": "David P.", "image": "https://i.pravatar.cc/150?u=b", "skill": "Beginner", "location": "Nugegoda", "wins": 5, "lat": 6.8700, "lng": 79.8800},
  ];

  Map<String, dynamic>? _selectedMapItem;
  int _opponentFilterIndex = 0;
  bool _isFiltered = false;
  List<Map<String, dynamic>> _scannedResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initial Map Data
    _scannedResults = List.from(_matches);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _isFiltered = false;
          _selectedMapItem = null;
          // Sync Map Data with Tab
          _scannedResults = _tabController.index == 0 ? List.from(_matches) : List.from(_opponents);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMatchesTab = _tabController.index == 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      
      // Floating Action Button - Only show in List View
      floatingActionButton: !_isMapView ? Padding(
        padding: const EdgeInsets.only(bottom: 100), 
        child: FloatingActionButton.extended(
          onPressed: () async {
              if (isMatchesTab) {
                // Navigate to Create Match and wait for result
                final newMatch = await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const CreateMatchScreen())
                );
                // Add new match to list immediately for visual feedback
                if (newMatch != null) {
                  setState(() {
                    _matches.insert(0, newMatch); // Add to top
                    if (_tabController.index == 0) _scannedResults = List.from(_matches);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match Created Successfully!"), backgroundColor: Colors.green));
                }
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTeamScreen()));
              }
          },
          backgroundColor: AppColors.primary,
          icon: Icon(
            isMatchesTab ? Icons.add_circle_outline : Icons.group_add,
            color: Colors.white
          ),
          label: Text(
            isMatchesTab ? "Host Match" : "Create Team",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [
          Positioned.fill(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : (_isMapView ? _buildMapView() : _buildListView()),
          ),

          // Header
          Positioned(
            top: 50, left: 20, right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                       _buildGlassButton(context, icon: Icons.tune, label: "Filter", onTap: _openFilterModal, isActive: _isFiltered),

                    const Spacer(),
                    
                    if (_tabController.index == 0)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.black.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(30)),
                        child: Row(children: [_buildToggleBtn("List", false), _buildToggleBtn("Map", true)]),
                      ),
                  ],
                ),

                // Search Bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: (_isSearchVisible && !_isMapView) ? 60 : 0,
                  margin: const EdgeInsets.only(top: 10),
                  child: (_isSearchVisible && !_isMapView) ? TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search...", filled: true, fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ) : const SizedBox(),
                ),

                const SizedBox(height: 12),

                // Tabs (Hidden in Map View)
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
                      indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(25)),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [Tab(text: "Matches"), Tab(text: "Opponents")],
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                    ),
                  ),
                
                // Sub Filters
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

          // Map Refresh
          if (_isMapView && _isFiltered)
            Positioned(
              bottom: 180, right: 20, 
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isFiltered = false;
                    _scannedResults = _tabController.index == 0 ? List.from(_matches) : List.from(_opponents);
                  });
                },
                backgroundColor: Colors.white,
                mini: true,
                child: const Icon(Icons.refresh, color: Colors.black),
              ),
            ),

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
            _isFiltered = true;
            // Mock filter logic
            if (_tabController.index == 0) {
               _scannedResults = _matches.where((m) => m['sport'] == filters['sport']).toList();
            }
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
    List<Map<String, dynamic>> currentList = _tabController.index == 0 ? _matches : _opponents;
    
    // Apply filters
    if (_searchQuery.isNotEmpty) {
      currentList = currentList.where((item) => 
        (item['name'] ?? item['courtName']).toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_tabController.index == 1) {
       if (_opponentFilterIndex == 1) currentList = currentList.where((i) => i['type'] == 'player').toList();
       if (_opponentFilterIndex == 2) currentList = currentList.where((i) => i['type'] == 'team').toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 240, 20, 150), // Bottom padding for FAB
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        final item = currentList[index];
        if (_tabController.index == 0) {
          return MatchCard(
            sport: item['sport'] ?? "Sport",
            courtName: item['courtName'] ?? "Unknown Court",
            time: _formatDate(item['time']),
            skill: item['skill'] ?? "All",
            currentPlayers: item['currentPlayers'] ?? 0,
            maxPlayers: item['maxPlayers'] ?? 10,
            fee: (item['fee'] ?? 0).toDouble(),
            onTap: () => _onMatchTap(item),
          );
        } else {
          return OpponentCard(
            name: item['name'] ?? "User",
            image: item['image'] ?? "https://placehold.co/150x150",
            skill: item['skill'] ?? "Unknown",
            location: item['location'] ?? "Unknown",
            wins: item['wins'] ?? 0,
            isTeam: item['type'] == 'team',
          );
        }
      },
    );
  }

  Widget _buildMapView() {
    return InteractiveMap(
      data: _scannedResults, 
      isTeam: _tabController.index == 1,
      onMarkerTap: (item) => setState(() => _selectedMapItem = item),
    );
  }

  Widget _buildPreviewCard(Map<String, dynamic> item) {
    bool isMatch = _tabController.index == 0;
    // Fix: Handle different key names safely
    String title = isMatch ? (item['courtName'] ?? 'Court') : (item['name'] ?? 'User');
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

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "Upcoming";
    return dateStr.toString();
  }
}