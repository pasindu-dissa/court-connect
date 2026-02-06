import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/opponent_card.dart';
import 'create_team_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMapView = true;
  bool _isSearchVisible = false;
  String _searchQuery = "";
  String _selectedSport = "Tennis";
  Map<String, dynamic>? _selectedMapItem;

  // Mock Data with Coordinates for Map
  final List<Map<String, dynamic>> _mockPlayers = [
    {"name": "Sarah Jenkins", "image": "https://i.pravatar.cc/150?u=a042581f4e29026024d", "skill": "Pro", "location": "Colombo 07", "wins": 42, "top": 0.35, "left": 0.25},
    {"name": "David Perera", "image": "https://i.pravatar.cc/150?u=a042581f4e29026704d", "skill": "Intermediate", "location": "Nugegoda", "wins": 15, "top": 0.45, "left": 0.65},
    {"name": "Kamal De Silva", "image": "https://i.pravatar.cc/150?u=a04258114e29026302d", "skill": "Beginner", "location": "Colombo 03", "wins": 3, "top": 0.60, "left": 0.30},
    {"name": "Jenny Doe", "image": "https://i.pravatar.cc/150?u=jenny", "skill": "Pro", "location": "Dehiwala", "wins": 28, "top": 0.25, "left": 0.75},
  ];

  final List<Map<String, dynamic>> _mockTeams = [
    {"name": "Colombo Kings", "image": "https://placehold.co/150x150/png?text=CK", "skill": "League A", "location": "Colombo", "wins": 12, "top": 0.40, "left": 0.40},
    {"name": "Badminton Blasters", "image": "https://placehold.co/150x150/png?text=BB", "skill": "Casual", "location": "Kotte", "wins": 5, "top": 0.55, "left": 0.20},
    {"name": "Hoops Squad", "image": "https://placehold.co/150x150/png?text=HS", "skill": "League B", "location": "Bambalapitiya", "wins": 8, "top": 0.70, "left": 0.60},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedMapItem = null); // Clear selection on tab change
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to filter data based on Search
  List<Map<String, dynamic>> get _currentData {
    final rawData = _tabController.index == 0 ? _mockPlayers : _mockTeams;
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
      floatingActionButton: _tabController.index == 1 ? FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTeamScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      body: Stack(
        children: [
          // 1. Main View (Map or List)
          _isMapView ? _buildMapView() : _buildListView(),

          // 2. Floating Header (Filters, Search, Tabs)
          Positioned(
            top: 50, left: 20, right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Filter, Search, Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(
                      context,
                      icon: _isSearchVisible ? Icons.close : Icons.search,
                      label: _isSearchVisible ? "Close" : "Search",
                      onTap: () => setState(() {
                        _isSearchVisible = !_isSearchVisible;
                        if (!_isSearchVisible) _searchQuery = "";
                      }),
                      isActive: _isSearchVisible
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.black.withOpacity(0.8),
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
                
                // Animated Search Bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearchVisible ? 60 : 0,
                  margin: const EdgeInsets.only(top: 10),
                  child: _isSearchVisible ? TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    decoration: InputDecoration(
                      hintText: "Search name or location...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ) : const SizedBox(),
                ),

                const SizedBox(height: 12),

                // Tabs (Segmented Control Style)
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
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [Tab(text: "Opponents"), Tab(text: "Teams")],
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),

                const SizedBox(height: 12),

                // Sport Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["Tennis", "Badminton", "Cricket", "Basketball", "Football"].map((sport) {
                      final isSelected = _selectedSport == sport;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSport = sport),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Theme.of(context).cardColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
                            ),
                            child: Text(
                              sport,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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

  // --- WIDGETS ---

  Widget _buildMapView() {
    return GestureDetector(
      onTap: () => setState(() => _selectedMapItem = null),
      child: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://placehold.co/800x1200/png?text=Map+Scan"), 
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: Stack(
          children: _currentData.map((item) {
            return Positioned(
              top: MediaQuery.of(context).size.height * (item['top'] as double),
              left: MediaQuery.of(context).size.width * (item['left'] as double),
              child: GestureDetector(
                onTap: () => setState(() => _selectedMapItem = item),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        shape: BoxShape.circle, 
                        border: Border.all(color: AppColors.primary, width: 2), 
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(item['image']),
                      ),
                    ),
                    Container(height: 10, width: 2, color: Colors.black87)
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
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 240, 20, 100), // Top padding for header
      itemCount: _currentData.length,
      itemBuilder: (context, index) {
        final item = _currentData[index];
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
    final isTeam = _tabController.index == 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(item['image'])),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("${item['skill']} • ${item['location']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isTeam ? Icons.group_add : Icons.send, color: AppColors.primary, size: 20),
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