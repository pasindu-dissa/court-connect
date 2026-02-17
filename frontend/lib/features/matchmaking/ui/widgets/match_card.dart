import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MatchCard extends StatelessWidget {
  final String sport;
  final String courtName;
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
    required this.time,
    required this.skill,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.fee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isFull = currentPlayers >= maxPlayers;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: isFull ? Border.all(color: Colors.red.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            // 1. Time Column
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    time.split(' ')[0], // "10:00"
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    time.split(' ')[1], // "AM"
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(sport, Colors.blue),
                      const SizedBox(width: 6),
                      _buildTag(skill, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Fee: LKR ${fee.toStringAsFixed(0)} / person",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // 3. Slots Indicator
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: currentPlayers / maxPlayers,
                      backgroundColor: Colors.grey.shade200,
                      color: isFull ? Colors.red : AppColors.primary,
                      strokeWidth: 4,
                    ),
                    Text(
                      "$currentPlayers/$maxPlayers",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isFull ? "Full" : "Open",
                  style: TextStyle(
                    fontSize: 10, 
                    color: isFull ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}