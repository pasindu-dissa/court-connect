import 'package:flutter/material.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.percent,
    required this.color,
  });

  final IconData icon;
  final String label;

  /// e.g. "48 / 60 min"
  final String sublabel;

  /// 0–100
  final int percent;

  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE0E0E0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Circular progress placeholder ──────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 7),
            ),
            child: Center(child: Icon(icon, color: color, size: 28)),
          ),

          const SizedBox(height: 12),

          // ── Label ──────────────────────────────────────────────────
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),

          // ── Sub-label ──────────────────────────────────────────────
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
