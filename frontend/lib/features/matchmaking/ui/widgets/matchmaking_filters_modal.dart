import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MatchmakingFiltersModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onScan;

  const MatchmakingFiltersModal({super.key, required this.onScan});

  @override
  State<MatchmakingFiltersModal> createState() =>
      _MatchmakingFiltersModalState();
}

class _MatchmakingFiltersModalState extends State<MatchmakingFiltersModal> {
  String _selectedSport = "All Sports";
  String _selectedSkill = "All Levels";
  String _selectedDuration = "Any Time";
  final TextEditingController _locationController = TextEditingController();

  final List<String> _skills = [
    "Beginner",
    "Intermediate",
    "Pro",
    "All Levels",
  ];
  final List<String> _sports = [
    "All Sports",
    "Tennis",
    "Badminton",
    "Cricket",
    "Basketball",
    "Football",
    "Swimming",
  ];
  final List<String> _durations = [
    "Any Time",
    "Morning",
    "Afternoon",
    "Evening",
    "Night",
  ];

  void _resetFilters() {
    setState(() {
      _selectedSport = "All Sports";
      _selectedSkill = "All Levels";
      _selectedDuration = "Any Time";
      _locationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Reset Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Matches",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Reset"),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 1. Sport Selector
          const Text(
            "Looking for",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _sports.map((sport) {
                final isSelected = _selectedSport == sport;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sport),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedSport = sport),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // 2. Skill Level
          const Text(
            "Skill Level",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _skills.map((skill) {
              final isSelected = _selectedSkill == skill;
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedSkill = skill),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 3. Location & Availability Duration
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Area / Town",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: "e.g. Colombo",
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Availability",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      icon: const Icon(
                        Icons.access_time,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _durations
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedDuration = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onScan({
                  "sport": _selectedSport == "All Sports"
                      ? null
                      : _selectedSport,
                  "skill": _selectedSkill == "All Levels"
                      ? null
                      : _selectedSkill,
                  "timeDuration": _selectedDuration == "Any Time"
                      ? null
                      : _selectedDuration,
                  "location": _locationController.text.isEmpty
                      ? null
                      : _locationController.text,
                });
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Apply Filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
