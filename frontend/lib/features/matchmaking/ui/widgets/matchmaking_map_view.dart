import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MatchmakingMapView extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isTeam;

  const MatchmakingMapView({super.key, required this.data, required this.isTeam});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Full Screen Map Background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://placehold.co/800x1200/png?text=Interactive+Map"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // 2. Radar Pulse Effect (Center of Screen)
        Center(
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
              gradient: RadialGradient(
                colors: [AppColors.primary.withOpacity(0.05), Colors.transparent],
              ),
            ),
          ),
        ),

        // 3. User Pins (Scattered Mock Positioning)
        ...List.generate(data.length, (index) {
          final item = data[index];
          // Mock positions based on index
          final top = 150.0 + (index * 100) + (index % 2 == 0 ? 50 : -50);
          final left = 50.0 + (index * 80) + (index % 2 == 0 ? 100 : 0);

          return Positioned(
            top: top,
            left: left,
            child: _buildMapPin(context, item),
          );
        }),
      ],
    );
  }

  Widget _buildMapPin(BuildContext context, Map<String, dynamic> item) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(item['image']),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['name'].toString().split(' ')[0], // First name only
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Icon(
                isTeam ? Icons.shield : Icons.sports_tennis, 
                color: AppColors.accent, 
                size: 10
              ),
            ],
          ),
        ),
      ],
    );
  }
}