import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CourtCard extends StatelessWidget {
  final Map<String, dynamic> court;
  final VoidCallback onTap;

  const CourtCard({super.key, required this.court, required this.onTap});

  // Helper method to get correct icon for each sport
  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'tennis': return Icons.sports_baseball_outlined;
      case 'basketball': return Icons.sports_basketball;
      case 'football': return Icons.sports_soccer;
      case 'cricket': return Icons.sports_cricket;
      case 'swimming': return Icons.pool;
      case 'badminton': return Icons.sports_tennis; // Uses tennis racket as fallback
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    String image = (court['images'] as List?)?.isNotEmpty == true ? court['images'][0] : "https://via.placeholder.com/150";
    
    // Handle both old 'sport' string and new 'sports' array formats gracefully
    List<dynamic> sports = court['sports'] ?? [];
    if (sports.isEmpty && court['sport'] != null) {
      sports = [court['sport']];
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))]
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16), 
              child: Image.network(image, width: 90, height: 90, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[300]))
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(court['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(court['location'], style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
                  const SizedBox(height: 8),
                  Text("LKR ${court['pricePerHour']}/hr", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),                
                  const SizedBox(height: 3),
                  // Sports Icons Row (Max 3 icons to prevent overflow)
                  Row(
                    children: sports.take(5).map((s) => 
                    Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(_getSportIcon(s.toString()), size: 16, color: Colors.blueAccent),
                      ),
                    ).toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}