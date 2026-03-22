import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/constants/api_constants.dart';
import 'featured_challenge_screen.dart';
import 'new_badge_screen.dart';
import 'streak_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  final VoidCallback? onLocationTapped;

  const LeaderboardScreen({super.key, this.onLocationTapped});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedSport = 'all';
  String _selectedCourt = 'all';

  final List<String> _sports = ['all', 'badminton', 'tennis', 'basketball', 'football'];
  List<Map<String, dynamic>> _courts = [{'id': 'all', 'name': 'ALL COURTS'}];
  
  Future<Map<String, dynamic>>? _userStatsFuture;

  @override
  void initState() {
    super.initState();
    _fetchCourts();
    _userStatsFuture = _fetchUserStats();
  }

  Future<void> _fetchCourts() async {
    try {
      final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/courts"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _courts = [
              {'id': 'all', 'name': 'ALL COURTS'},
              ...data.map((c) => {'id': c['_id'].toString(), 'name': c['name'].toString().toUpperCase()})
            ];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching courts: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchUserStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {'rank': '-', 'score': 0, 'streak': 0};
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/leaderboard/my-stats?sportType=$_selectedSport&courtId=$_selectedCourt"),
        headers: { 'Authorization': 'Bearer $token' }
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      debugPrint("Error fetching user stats: $e");
    }
    return {'rank': '-', 'score': 0, 'streak': 0};
  }

  Future<List<dynamic>> _fetchLeaderboard() async {
    try {
      final response = await http.get(
        // Use the new top-players endpoint supporting dynamic filtering
        Uri.parse("${ApiConstants.baseUrl}/leaderboard/top-players?sportType=$_selectedSport&courtId=$_selectedCourt"),
      );
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return data is List
            ? data
            : (data is Map && data.containsKey('data') ? data['data'] : []);
      }
    } catch (e) {
      debugPrint("Error fetching leaderboard: \$e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF5F6F8),
        elevation: 0,
        automaticallyImplyLeading:
            false, // Hide back button since it's a bottom nav tab
        title: Text(
          'Leaderboard',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _userStatsFuture,
            builder: (context, snapshot) {
              final streak = snapshot.data?['streak'] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$streak',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('🔥', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _userStatsFuture,
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {'rank': '-', 'score': 0, 'streak': 0};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Top Stats Row ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Your Rank',
                            stats['rank'].toString(),
                            Icons.trending_up,
                            'Overall',
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Your Rating',
                            stats['score'].toString(),
                            null,
                            'Points',
                            Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // --- Current Streak Card ---
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                StreakScreen(currentStreak: stats['streak']),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                                  var begin = const Offset(0.0, 1.0);
                                  var end = Offset.zero;
                                  var curve = Curves.easeOutCubic;
                                  var tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Theme.of(context).cardColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Streak',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${stats['streak']} Weeks',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF1A202C),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.deepOrange,
                                  size: 40,
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),

            // --- Challenges & Badges Section ---
            Text(
              'Challenges & Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ChallengeCardWidget(
                    color: Colors.orange,
                    icon: Icons.emoji_events,
                    title: 'Featured Challenge',
                    subtitle: 'Win 5 games this week',
                    onViewPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeaturedChallengeScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ChallengeCardWidget(
                    color: const Color(0xFF74A5FF),
                    icon: Icons.wine_bar,
                    title: 'New Badge Unlocked',
                    subtitle: 'The Rival',
                    isCircleIcon: true,
                    onViewPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const NewBadgeScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                var begin = const Offset(0.0, 1.0);
                                var end = Offset.zero;
                                var curve = Curves.easeOutCubic;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // --- Top Players Section ---
            Text(
              'Top Players',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSport,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: isDark ? Theme.of(context).cardColor : Colors.white,
                    ),
                    dropdownColor: isDark ? Theme.of(context).cardColor : Colors.white,
                    items: _sports.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase(), style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black)))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedSport = v!;
                        _userStatsFuture = _fetchUserStats();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCourt,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: isDark ? Theme.of(context).cardColor : Colors.white,
                    ),
                    dropdownColor: isDark ? Theme.of(context).cardColor : Colors.white,
                    items: _courts.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'].toString(), style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black)))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCourt = v!;
                        _userStatsFuture = _fetchUserStats();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            FutureBuilder<List<dynamic>>(
              future: _fetchLeaderboard(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text("No players found on the leaderboard.", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  );
                }

                final topPlayers = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topPlayers.length,
                  itemBuilder: (context, index) {
                    final player = topPlayers[index];
                    final name = player['user']?['name'] ?? player['teamName'] ?? player['name'] ?? 'Unknown';
                    final score = player['points'] ?? player['score'] ?? 0;
                    final status = player['status'] ?? 'hot';

                    return _buildPlayerCard(index + 1, name, score, status);
                  },
                );
              },
            ),
            const SizedBox(height: 80), // Padding for the FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new match tapped!')),
          );
        },
        backgroundColor: const Color(
          0xFF65C4B0,
        ), // Match the Teal FAB from Figma
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  // --- Helper Widget: Top Stat Cards ---
  Widget _buildStatCard(
    String title,
    String value,
    IconData? icon,
    String bottomText,
    Color bottomTextColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              if (icon != null) Icon(icon, color: bottomTextColor, size: 18),
              if (icon != null) const SizedBox(width: 5),
              Text(
                bottomText,
                style: TextStyle(
                  color: bottomTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Challenge Cards ---
  // --- Helper Widget: Player List Items ---
  Widget _buildPlayerCard(int rank, String name, int score, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    IconData trailingIcon;
    Color trailingColor;

    if (status == 'hot') {
      trailingIcon = Icons.local_fire_department;
      trailingColor = Colors.deepOrange;
    } else if (status == 'up') {
      trailingIcon = Icons.trending_up;
      trailingColor = Colors.green;
    } else {
      trailingIcon = Icons.trending_down;
      trailingColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
          child: const Icon(
            Icons.person,
            color: Colors.white,
          ), // Replace with NetworkImage in production
        ),
        title: Text(
          '$rank. $name',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black),
        ),
        subtitle: Text(
          '$score Points',
          style: const TextStyle(color: Colors.blueGrey),
        ),
        trailing: CircleAvatar(
          backgroundColor: trailingColor,
          radius: 15,
          child: Icon(trailingIcon, color: Colors.white, size: 18),
        ),
        onTap: () {
          // Add interaction when a user is tapped
        },
      ),
    );
  }
}

class ChallengeCardWidget extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCircleIcon;
  final VoidCallback? onViewPressed;

  const ChallengeCardWidget({
    Key? key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isCircleIcon = false,
    this.onViewPressed,
  }) : super(key: key);

  @override
  State<ChallengeCardWidget> createState() => _ChallengeCardWidgetState();
}

class _ChallengeCardWidgetState extends State<ChallengeCardWidget> {
  final GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: widget.isCircleIcon
                        ? CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Icon(widget.icon, size: 40, color: Colors.grey),
                          )
                        : Icon(widget.icon, size: 70, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF145348,
                            ), // Dark green button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: widget.onViewPressed ?? () {},
                          child: const Text(
                            'View',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () async {
                  try {
                    RenderRepaintBoundary boundary = _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                    if (byteData != null) {
                      final buffer = byteData.buffer;
                      final tempDir = await getTemporaryDirectory();
                      final file = await File('${tempDir.path}/challenge_screenshot.png').create();
                      await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
                      
                      await Share.shareXFiles(
                        [XFile(file.path)], 
                        text: 'I just earned the \\\'${widget.subtitle}\\\' badge on CourtConnect! Think you can beat my score?'
                      );
                    }
                  } catch (e) {
                    debugPrint("Screenshot failed: $e");
                    Share.share('I just earned the \\\'${widget.subtitle}\\\' badge on CourtConnect! Think you can beat my score?');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
