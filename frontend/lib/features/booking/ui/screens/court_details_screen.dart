import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_provider.dart';
import '../../data/booking_service.dart';
import '../../../matchmaking/data/matchmaking_service.dart';
import 'directions_map_screen.dart';

class CourtDetailsScreen extends StatefulWidget {
  final dynamic court; 
  final Map<String, dynamic>? pendingMatchData;

  const CourtDetailsScreen({super.key, required this.court, this.pendingMatchData});

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen> {
  final BookingService _bookingService = BookingService();
  final MatchmakingService _matchmakingService = MatchmakingService();
  
  DateTime _selectedDate = DateTime.now();
  Set<String> _selectedTimeSlots = {}; 
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

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'tennis': return Icons.sports_tennis;
      case 'basketball': return Icons.sports_basketball;
      case 'football':
      case 'futsal': return Icons.sports_soccer;
      case 'cricket': return Icons.sports_cricket;
      case 'swimming': return Icons.pool;
      case 'badminton': return Icons.sports_tennis; 
      default: return Icons.sports;
    }
  }

  Future<void> _fetchBookedSlots() async {
    setState(() => _isLoadingSlots = true);
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final bookings = await _bookingService.getBookedSlots(widget.court['_id'], dateStr);
    setState(() {
      _bookedSlots = bookings;
      _isLoadingSlots = false;
      // Remove any slots that might now be invalid due to date change
      _selectedTimeSlots.clear(); 
    });
  }

  // --- NEW: Check if slot time has passed ---
  bool _isSlotPassed(String slotTime) {
    final now = DateTime.now();
    
    // 1. If it's a future day, nothing is passed
    if (_selectedDate.year > now.year ||
        (_selectedDate.year == now.year && _selectedDate.month > now.month) ||
        (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day > now.day)) {
      return false; 
    }
    
    // 2. If it's a past day, everything is passed
    if (_selectedDate.year < now.year ||
        (_selectedDate.year == now.year && _selectedDate.month < now.month) ||
        (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day < now.day)) {
      return true; 
    }

    // 3. It's today. Compare the exact hour
    final parts = slotTime.split(' ');
    final timeParts = parts[0].split(':');
    int slotHour = int.parse(timeParts[0]);
    final isPM = parts[1] == 'PM';

    if (slotHour == 12 && !isPM) slotHour = 0;
    if (slotHour != 12 && isPM) slotHour += 12;

    if (now.hour > slotHour) return true;
    if (now.hour == slotHour && now.minute > 0) return true; // Assuming slots are on the hour
    return false;
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
    
    for (String slot in _selectedTimeSlots) {
      final bookingData = {
        "courtId": widget.court['_id'],
        "userId": user['_id'],
        "date": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "startTime": slot,
        "totalPrice": widget.court['pricePerHour'],
      };
      final success = await _bookingService.createBooking(bookingData);
      if (!success) allSuccess = false;
    }

    bool matchPublished = false;
    if (allSuccess && widget.pendingMatchData != null) {
      final matchData = Map<String, dynamic>.from(widget.pendingMatchData!);
      matchData['hostId'] = user['_id'];
      matchData['date'] = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final sortedSlots = _selectedTimeSlots.toList()..sort();
      matchData['time'] = sortedSlots.join(", "); 
      
      matchPublished = await _matchmakingService.createMatch(matchData);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (allSuccess) {
        _showSuccessDialog(matchPublished);
        _fetchBookedSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Some slots failed to book. Please refresh.")));
        _fetchBookedSlots();
      }
    }
  }

  void _showSuccessDialog(bool matchPublished) {
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
            Text(matchPublished ? "Match Published!" : "Booking Confirmed!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(matchPublished 
              ? "Your match is live and the court is booked for ${_selectedTimeSlots.length} slot(s)."
              : "${_selectedTimeSlots.length} slot(s) reserved on ${DateFormat('MMM dd').format(_selectedDate)}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context, true); 
                if (widget.pendingMatchData != null) {
                  Navigator.pop(context, true); 
                }
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
    final bool isHosting = widget.pendingMatchData != null;

    List<dynamic> sportsList = widget.court['sports'] ?? [];
    if (sportsList.isEmpty && widget.court['sport'] != null) {
      sportsList = [widget.court['sport']];
    }

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
                  title: Text(widget.court['name'], style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18)),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isHosting)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(child: Text("Select the date and time slots for your Match. Booking this court will automatically publish your match.", style: TextStyle(color: Colors.blue, fontSize: 13))),
                            ],
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
                                    SizedBox(width: 2),
                                    Text(widget.court['location'], style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey[500] : Colors.grey[700]), maxLines: 2),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Row(children: [Icon(Icons.star, color: Colors.amber, size: 18), Text(" 4.5 (100+ Reviews)")]),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DirectionsMapScreen(court: widget.court))),
                            icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.directions, color: Colors.blue)),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      const Text("Available Sports", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: sportsList.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getSportIcon(s.toString()), size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(s.toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),
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
                                decoration: BoxDecoration(color: isSelected ? AppColors.primary : cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade300)),
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
                              bool isPassed = _isSlotPassed(slot);
                              bool isBooked = _bookedSlots.contains(slot);
                              bool isUnavailable = isPassed || isBooked;
                              bool isSelected = _selectedTimeSlots.contains(slot);
                              
                              return GestureDetector(
                                onTap: isUnavailable ? null : () => _toggleSlot(slot),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    // Make passed slots slightly lighter than booked slots for visual distinction
                                    color: isUnavailable 
                                      ? (isDark ? Colors.white10 : (isPassed ? Colors.grey[100] : Colors.grey[200])) 
                                      : (isSelected ? AppColors.primary : cardColor),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSelected ? AppColors.primary : (isDark ? Colors.transparent : Colors.grey.shade300))
                                  ),
                                  child: Text(
                                    slot, 
                                    style: TextStyle(
                                      color: isUnavailable ? Colors.grey : (isSelected ? Colors.white : textColor), 
                                      decoration: isBooked ? TextDecoration.lineThrough : null, // Strikethrough ONLY for booked, passed is just greyed out
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
                        : Text(isHosting ? "Book & Publish Match" : "Book ${_selectedTimeSlots.length} Slot(s)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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