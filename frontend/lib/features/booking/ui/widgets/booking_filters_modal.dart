import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BookingFiltersModal extends StatefulWidget {
  final Function(String?) onApply;
  const BookingFiltersModal({super.key, required this.onApply});

  @override
  State<BookingFiltersModal> createState() => _BookingFiltersModalState();
}

class _BookingFiltersModalState extends State<BookingFiltersModal> {
  String? _selectedSport;
  final List<String> _sports = ["All", "Badminton", "Tennis", "Basketball", "Futsal", "Cricket", "Swimming"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filter Courts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text("Select Sport", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _sports.map((sport) {
              bool isSelected = _selectedSport == sport || (sport == "All" && _selectedSport == null);
              return ChoiceChip(
                label: Text(sport),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedSport = sport == "All" ? null : sport),
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.black),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedSport);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text("Apply Filters"),
            ),
          )
        ],
      ),
    );
  }
}