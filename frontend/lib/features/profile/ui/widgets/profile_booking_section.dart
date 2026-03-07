import 'package:flutter/material.dart';
import '../../data/models/booking_model.dart';
import 'booking_card.dart';

class ProfileBookingSection extends StatelessWidget {
  final List<BookingModel> bookings;

  const ProfileBookingSection({
    Key? key,
    required this.bookings,
  }) : super(key: key);

  static const List<Color> _cardColors = [
    Color(0xFF0F766E),
    Color(0xFF0369A1),
    Color(0xFF7C3AED),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Empty state
          bookings.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No upcoming bookings',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              // Horizontal scroll list
              : SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return BookingCard(
                        date: booking.formattedDate,
                        courtInfo: booking.courtInfo,
                        imageUrl: booking.imageUrl,
                        backgroundColor:
                            _cardColors[index % _cardColors.length],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}