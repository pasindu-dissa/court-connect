import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CourtCard extends StatelessWidget {
  final Map<String, dynamic> court;
  final VoidCallback onTap;

  const CourtCard({super.key, required this.court, required this.onTap});

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

    String image = (court['images'] as List?)?.isNotEmpty == true
        ? court['images'][0]
        : "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=300";

    // Handle both old 'sport' string and new 'sports' array formats gracefully
    List<dynamic> sports = court['sports'] ?? [];
    if (sports.isEmpty && court['sport'] != null) {
      sports = [court['sport']];
    }

    // Get the primary sport icon to use as the background watermark
    IconData mainSportIcon = _getSportIcon(
      sports.isNotEmpty ? sports.first.toString() : '',
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withOpacity(isDark ? 0.3 : 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isDark ? 0.1 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Large Watermark Icon in the background (Matches _SportCard style)
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  mainSportIcon,
                  size: 110,
                  color: AppColors.primary.withOpacity(isDark ? 0.1 : 0.05),
                ),
              ),

              // Foreground Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Court Image with its own subtle shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          image,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Court Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  court['location'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "LKR ${court['pricePerHour']}/hr",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Modernized Sports Icons Row (Max 5 icons)
                          Row(
                            children: sports
                                .take(5)
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getSportIcon(s.toString()),
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
