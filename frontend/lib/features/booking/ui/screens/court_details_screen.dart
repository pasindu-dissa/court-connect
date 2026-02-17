import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../core/constants/app_colors.dart';

class CourtDetailsScreen extends StatefulWidget {
  final dynamic court; 
  const CourtDetailsScreen({super.key, required this.court});

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen> {
  int _selectedDateIndex = 0;
  int _selectedTimeSlot = -1;

  final List<Map<String, dynamic>> _timeSlots = [
    {"time": "06:00 AM", "status": 0}, {"time": "06:30 AM", "status": 1},
    {"time": "07:00 AM", "status": 0}, {"time": "07:30 AM", "status": 2},
    {"time": "08:00 AM", "status": 0}, {"time": "08:30 AM", "status": 0},
    {"time": "09:00 AM", "status": 1}, {"time": "04:00 PM", "status": 0},
  ];

  Future<void> _launchMaps() async {
    double? lat;
    double? lng;
    String? url;

    // Support both API Map data and old Mock Object
    if (widget.court is Map) {
      lat = (widget.court['latitude'] as num?)?.toDouble();
      lng = (widget.court['longitude'] as num?)?.toDouble();
      url = widget.court['googleMapsLink'];
    } else {
      // Mock Object fallback
      lat = 6.9271;
      lng = 79.8612;
    }

    // Prioritize Direct Link -> Then Coordinates -> Then Search Query
    String googleUrl;
    if (url != null && url.isNotEmpty) {
      googleUrl = url;
    } else if (lat != null && lng != null) {
      googleUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    } else {
      // Fallback search by name
      String name = widget.court is Map ? widget.court['name'] : widget.court.name;
      googleUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name)}";
    }
    
    try {
      if (await canLaunchUrlString(googleUrl)) {
        await launchUrlString(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open maps")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    // Extract Data
    String name = widget.court is Map ? widget.court['name'] : widget.court.name;
    String image = widget.court is Map 
        ? (widget.court['images'] != null && (widget.court['images'] as List).isNotEmpty ? widget.court['images'][0] : "") 
        : widget.court.image;
    String address = widget.court is Map ? widget.court['location'] : widget.court.address;
    double price = widget.court is Map ? (widget.court['pricePerHour'] as num).toDouble() : (widget.court.price as num).toDouble();
    double rating = widget.court is Map ? 4.5 : widget.court.rating; 

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250, pinned: true, backgroundColor: AppColors.primary,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(image, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey)),
                      Container(color: Colors.black.withOpacity(0.3)),
                    ],
                  ),
                  title: Text(name, style: const TextStyle(fontSize: 16, color: Colors.white)),
                  centerTitle: false,
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
                                Text(address, style: TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text("$rating (120+ Reviews)", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Directions Button
                          IconButton(
                            onPressed: _launchMaps,
                            tooltip: "Get Directions",
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.directions, color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text("LKR $price / hour", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),

                      const SizedBox(height: 30),
                      Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                      const SizedBox(height: 12),
                      // ... (Date/Time pickers remain same)
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal, itemCount: 7,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedDateIndex == index;
                            final now = DateTime.now().add(Duration(days: index));
                            return GestureDetector(
                              onTap: () => setState(() => _selectedDateIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 60, margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : cardColor, 
                                  borderRadius: BorderRadius.circular(16), 
                                  border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200)
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(_getMonth(now.month), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                                  Text(now.day.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textColor)),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text("Available Slots (30 min)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12, runSpacing: 12,
                        children: List.generate(_timeSlots.length, (index) {
                          final slot = _timeSlots[index];
                          final isBooked = slot['status'] == 1;
                          final isSelected = _selectedTimeSlot == index;
                          return GestureDetector(
                            onTap: isBooked ? null : () => setState(() => _selectedTimeSlot = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isBooked ? (isDark ? Colors.white10 : Colors.grey.shade200) : (isSelected ? AppColors.primary : cardColor), 
                                borderRadius: BorderRadius.circular(12), 
                                border: Border.all(color: isSelected ? AppColors.primary : (isDark ? Colors.transparent : Colors.grey.shade300))
                              ),
                              child: Text(
                                slot['time'], 
                                style: TextStyle(
                                  color: isBooked ? Colors.grey : (isSelected ? Colors.white : textColor), 
                                  fontWeight: FontWeight.w600
                                )
                              ),
                            ),
                          );
                        }),
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
              decoration: BoxDecoration(
                color: cardColor, 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: ElevatedButton(
                onPressed: _selectedTimeSlot == -1 ? null : () {},
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: AppColors.primary),
                child: const Text("Confirm Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getMonth(int month) => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][month - 1];
}