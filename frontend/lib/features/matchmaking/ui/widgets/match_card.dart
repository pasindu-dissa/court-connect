import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MatchCard extends StatelessWidget {
  final String sport;
  final String courtName;
  final String location; // NEW: Added location
  final String time;
  final String skill;
  final int currentPlayers;
  final int maxPlayers;
  final double fee;
  final VoidCallback onTap;

  const MatchCard({
    super.key,
    required this.sport,
    required this.courtName,
    required this.location, // NEW: Added location
    required this.time,
    required this.skill,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.fee,
    required this.onTap,
  });

  // Helper method to get correct icon for each sport
  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'tennis':
        return Icons.sports_baseball_outlined;
      case 'basketball':
        return Icons.sports_basketball;
      case 'football':
        return Icons.sports_soccer;
      case 'cricket':
        return Icons.sports_cricket;
      case 'swimming':
        return Icons.pool;
      case 'badminton':
        return Icons.sports_tennis; // Uses tennis racket as fallback
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isFull = currentPlayers >= maxPlayers;
    
    // Use red tint if full, otherwise use the primary brand color tint
    final Color baseColor = isFull ? Colors.red : AppColors.primary;
    final IconData sportIcon = _getSportIcon(sport);

    // Safely parse time (e.g., "10:00 AM")
    final timeParts = time.split(' ');
    final String timeMain = timeParts.isNotEmpty ? timeParts[0] : time;
    final String timeAmPm = timeParts.length > 1 ? timeParts[1] : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? baseColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: baseColor.withOpacity(isDark ? 0.3 : 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(isDark ? 0.1 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Large Watermark Icon in the background
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  sportIcon,
                  size: 110,
                  color: baseColor.withOpacity(isDark ? 0.1 : 0.05),
                ),
              ),
              
              // Foreground Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 1. Time Box
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            timeMain,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (timeAmPm.isNotEmpty)
                            Text(
                              timeAmPm,
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.w600,
                                color: baseColor.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 2. Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courtName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800, 
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          
                          // NEW: Location Row
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              _buildTag(sport, Colors.blue, icon: sportIcon),
                              const SizedBox(width: 6),
                              _buildTag(skill, Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Fee: LKR ${fee.toStringAsFixed(0)} / person",
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Slots Indicator
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 45,
                              height: 45,
                              child: CircularProgressIndicator(
                                value: currentPlayers / maxPlayers,
                                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                                color: baseColor,
                                strokeWidth: 4.5,
                              ),
                            ),
                            Text(
                              "$currentPlayers/$maxPlayers",
                              style: TextStyle(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isFull ? "Full" : "Open",
                          style: TextStyle(
                            fontSize: 11, 
                            color: baseColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color, 
              fontSize: 10, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}