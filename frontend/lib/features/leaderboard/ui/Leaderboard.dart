import 'package:flutter/material.dart';
import 'shared_data.dart'; // This connects your UI to the shared database!

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

 @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}
class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // The local dummy data list was removed from here.

  @override
  Widget build(BuildContext context) {
    // Read the latest data directly from the shared global list
    final topPlayers = CourtDatabase.players;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Light grey background from Figma
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Back ')),
            );
          },
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Bambalapitiya',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Stats Row ---
            Row(
              children: [
                Expanded(child: _buildStatCard('Your Rank in the team', '#3', Icons.trending_up, '+1', Colors.green)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard('Your Rating', '1580', null, 'Points', Colors.grey)),
              ],
            ),
            const SizedBox(height: 15),

            // --- Current Streak Card ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Current Streak', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('5 Wins', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A202C))),
                    ],
                  ),
                  const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- Challenges & Badges Section ---
            const Text('Challenges & Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildChallengeCard(
                    color: Colors.orange,
                    icon: Icons.emoji_events,
                    title: 'Featured Challenge',
                    subtitle: 'Win 5 games this week',
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildChallengeCard(
                    color: const Color(0xFF74A5FF),
                    icon: Icons.wine_bar, 
                    title: 'New Badge Unlocked',
                    subtitle: 'The Rival',
                    isCircleIcon: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // --- Top Players Section ---
            const Text('Top Players', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disables inner scroll so the whole page scrolls smoothly
              itemCount: topPlayers.length,
              itemBuilder: (context, index) {
                final player = topPlayers[index];
                // Pass 'score' instead of 'elo' to match our shared database structure
                return _buildPlayerCard(index + 1, player['name'], player['score'], player['status']);
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
        backgroundColor: const Color(0xFF65C4B0), // Match the Teal FAB from Figma
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  // --- Helper Widget: Top Stat Cards ---
  Widget _buildStatCard(String title, String value, IconData? icon, String bottomText, Color bottomTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A202C))),
          const SizedBox(height: 5),
          Row(
            children: [
              if (icon != null) Icon(icon, color: bottomTextColor, size: 18),
              if (icon != null) const SizedBox(width: 5),
              Text(bottomText, style: TextStyle(color: bottomTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
// --- Helper Widget: Challenge Cards ---
  Widget _buildChallengeCard({required Color color, required IconData icon, required String title, required String subtitle, bool isCircleIcon = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Center(
              child: isCircleIcon
                  ? CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(icon, size: 40, color: Colors.grey))
                  : Icon(icon, size: 70, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF145348), // Dark green button
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {},
                    child: const Text('View', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


        },
      ),
    );
  }
}