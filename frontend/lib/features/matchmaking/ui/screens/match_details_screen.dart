import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MatchDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const MatchDetailsScreen({super.key, required this.matchData});

  @override
  Widget build(BuildContext context) {
    // Mock court image
    final String image = "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=800";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(image, fit: BoxFit.cover),
              title: Text(matchData['court'], style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Row(
                    children: [
                      Chip(label: Text(matchData['sport']), backgroundColor: Colors.blue.withOpacity(0.1)),
                      const SizedBox(width: 10),
                      Chip(label: Text(matchData['skill']), backgroundColor: Colors.orange.withOpacity(0.1)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Grid
                  _buildInfoRow(Icons.calendar_today, "Date & Time", matchData['time']),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on, "Location", matchData['location']),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.monetization_on, "Entry Fee", "LKR ${matchData['fee']} per person"),
                  
                  const SizedBox(height: 30),
                  
                  // Players Section
                  Text(
                    "Players (${matchData['current']}/${matchData['max']})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: matchData['current'],
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$index"),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // 3. Join Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0,-5))]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Sent to Host!")));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Request to Join Match"),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        )
      ],
    );
  }
}