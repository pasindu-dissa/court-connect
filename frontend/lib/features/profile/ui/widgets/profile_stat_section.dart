import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import 'stat_card.dart';

class ProfileStatSection extends StatelessWidget {
  final Stats stats;

  const ProfileStatSection({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                icon: Icons.sports_tennis,
                value: stats.matchesPlayed.toString(),
                label: 'Matches Played',
              ),
              StatCard(
                icon: Icons.emoji_events,
                value: stats.winLossRatio,
                label: 'Win / Loss',
              ),
              StatCard(
                icon: Icons.star,
                value: stats.points.toString(),
                label: 'Points',
              ),
              StatCard(
                icon: Icons.trending_up,
                value: stats.wins.toString(),
                label: 'Total Wins',
              ),
            ],
          ),
        ],
      ),
    );
  }
}