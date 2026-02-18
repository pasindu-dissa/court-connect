import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_provider.dart';
import '../../data/booking_service.dart';
import 'directions_map_screen.dart';

class CourtDetailsScreen extends StatefulWidget {
  final dynamic court; 
  const CourtDetailsScreen({super.key, required this.court});

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen> {
  final BookingService _bookingService = BookingService();
  
  DateTime _selectedDate = DateTime.now();
  Set<String> _selectedTimeSlots = {}; // Changed to Set for multiple
  bool _isSubmitting = false;
  List<String> _bookedSlots = [];
  bool _isLoadingSlots = false;

  final List<String> _allSlots = List.generate(17, (index) {
    int hour = index + 6;
    String suffix = hour >= 12 ? "PM" : "AM";
    int displayHour = hour > 12 ? hour - 12 : hour;
    return "${displayHour.toString().padLeft(2, '0')}:00 $suffix";
  });

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  Future<void> _fetchBookedSlots() async {
    setState(() => _isLoadingSlots = true);
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final bookings = await _bookingService.getBookedSlots(widget.court['_id'], dateStr);
    setState(() {
      _bookedSlots = bookings;
      _isLoadingSlots = false;
      _selectedTimeSlots.clear(); // Reset selection on date change
    });
  }

  void _toggleSlot(String slot) {
    setState(() {
      if (_selectedTimeSlots.contains(slot)) {
        _selectedTimeSlots.remove(slot);
      } else {
        _selectedTimeSlots.add(slot);
      }
    });
  }

  Future<void> _confirmBooking() async {
    if (_selectedTimeSlots.isEmpty) return;
    
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to book")));
      return;
    }

    setState(() => _isSubmitting = true);

    bool allSuccess = true;
    
    // Create a booking for EACH selected slot
    for (String slot in _selectedTimeSlots) {
      final bookingData = {
        "courtId": widget.court['_id'],
        "userId": user['_id'],
        "date": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "startTime": slot,
        "totalPrice": widget.court['pricePerHour'], // Price per hour (slot)
      };

      final success = await _bookingService.createBooking(bookingData);
      if (!success) allSuccess = false;
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (allSuccess) {
        _showSuccessDialog();
        _fetchBookedSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Some slots failed to book. Please refresh.")));
        _fetchBookedSlots();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text("Booking Confirmed!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("${_selectedTimeSlots.length} slot(s) reserved on ${DateFormat('MMM dd').format(_selectedDate)}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Done"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String image = (widget.court['images'] as List?)?.isNotEmpty == true ? widget.court['images'][0] : "";
    double price = (widget.court['pricePerHour'] as num).toDouble();
    double totalPrice = price * _selectedTimeSlots.length;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250, pinned: true, backgroundColor: AppColors.primary,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(image, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey)),
                  title: Text(widget.court['name'], style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.court['location'], style: TextStyle(color: Colors.grey[600]), maxLines: 2),
                                const SizedBox(height: 4),
                                const Row(children: [Icon(Icons.star, color: Colors.amber, size: 18), Text(" 4.5 (100+ Reviews)")]),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => DirectionsMapScreen(court: widget.court)));
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.directions, color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 14,
                          itemBuilder: (context, index) {
                            final date = DateTime.now().add(Duration(days: index));
                            final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                            return GestureDetector(
                              onTap: () { setState(() => _selectedDate = date); _fetchBookedSlots(); },
                              child: Container(
                                width: 60, margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade300)
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(DateFormat('MMM').format(date), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey)),
                                  Text(date.day.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textColor)),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text("Available Slots", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                      const SizedBox(height: 12),
                      _isLoadingSlots 
                        ? const Center(child: CircularProgressIndicator()) 
                        : Wrap(
                            spacing: 10, runSpacing: 10,
                            children: _allSlots.map((slot) {
                              bool isBooked = _bookedSlots.contains(slot);
                              bool isSelected = _selectedTimeSlots.contains(slot);
                              return GestureDetector(
                                onTap: isBooked ? null : () => _toggleSlot(slot),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isBooked 
                                      ? (isDark ? Colors.white10 : Colors.grey[200]) 
                                      : (isSelected ? AppColors.primary : cardColor),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSelected ? AppColors.primary : (isDark ? Colors.transparent : Colors.grey.shade300))
                                  ),
                                  child: Text(
                                    slot, 
                                    style: TextStyle(
                                      color: isBooked 
                                        ? Colors.grey 
                                        : (isSelected ? Colors.white : textColor),
                                      decoration: isBooked ? TextDecoration.lineThrough : null,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                    )
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardColor, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Total Price", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("LKR ${totalPrice.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedTimeSlots.isEmpty || _isSubmitting ? null : _confirmBooking,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: AppColors.primary),
                      child: _isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Book ${_selectedTimeSlots.length} Slot(s)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}