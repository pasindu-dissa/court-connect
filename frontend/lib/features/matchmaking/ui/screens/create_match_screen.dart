import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../booking/data/booking_service.dart';
import '../../../booking/ui/screens/court_details_screen.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();

  List<Map<String, dynamic>> _courts = [];
  bool _isLoadingCourts = true;

  // Form State
  Map<String, dynamic>? _selectedCourt;
  String? _selectedSport;
  String _selectedSkill = "All Levels";
  int _maxPlayers = 4;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourts();
  }

  Future<void> _fetchCourts() async {
    final courts = await _bookingService.getAllCourts();
    if (mounted) {
      setState(() {
        _courts = courts;
        _isLoadingCourts = false;
      });
    }
  }

  void _proceedToBook() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourt == null || _selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a court and sport.")),
      );
      return;
    }

    double courtPrice = (_selectedCourt!['pricePerHour'] as num).toDouble();
    double calculatedFee = courtPrice / _maxPlayers;

    // Prepare partial match data to send to the Booking Screen
    final Map<String, dynamic> pendingMatchData = {
      "title": _titleController.text.trim(),
      "sport": _selectedSport,
      "courtName": _selectedCourt!['name'],
      "location": _selectedCourt!['location'],
      "skill": _selectedSkill,
      "fee": calculatedFee,
      "maxPlayers": _maxPlayers,
      "currentPlayers": 1, // Host is the first player
      "latitude": _selectedCourt!['latitude'],
      "longitude": _selectedCourt!['longitude'],
      "image": (_selectedCourt!['images'] as List?)?.isNotEmpty == true
          ? _selectedCourt!['images'][0]
          : "",
    };

    // Navigate to Court Details for actual booking
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourtDetailsScreen(
          court: _selectedCourt!,
          pendingMatchData: pendingMatchData, // Pass metadata
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double courtPrice = _selectedCourt != null
        ? (_selectedCourt!['pricePerHour'] as num).toDouble()
        : 0.0;
    double calculatedFee = _maxPlayers > 0 ? courtPrice / _maxPlayers : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Host a Match",
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoadingCourts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Basic Details ---
                    Text(
                      "Match Title",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: "e.g., Weekend Friendly Doubles",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 24),

                    // --- 2. Court Selection ---
                    Text(
                      "Select Court (Where you will play)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: const Text(
                        "Choose a registered court",
                        style: TextStyle(color: Colors.grey),
                      ),
                      value: _selectedCourt,
                      items: _courts.map((court) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: court,
                          child: Text(
                            "${court['name']} - LKR ${court['pricePerHour']}/hr",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCourt = val;
                          _selectedSport =
                              null; // Reset sport when court changes
                        });
                      },
                      validator: (val) => val == null ? "Required" : null,
                    ),
                    const SizedBox(height: 24),

                    // --- 3. Sport (Filtered by Court) ---
                    Text(
                      "Sport",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: const Text(
                        "Select Sport",
                        style: TextStyle(color: Colors.grey),
                      ),
                      value: _selectedSport,
                      items:
                          (_selectedCourt != null &&
                              _selectedCourt!['sports'] != null)
                          ? (_selectedCourt!['sports'] as List)
                                .map(
                                  (s) => DropdownMenuItem<String>(
                                    value: s.toString(),
                                    child: Text(s.toString()),
                                  ),
                                )
                                .toList()
                          : [],
                      onChanged: _selectedCourt == null
                          ? null
                          : (val) => setState(() => _selectedSport = val),
                      validator: (val) => val == null ? "Required" : null,
                    ),
                    const SizedBox(height: 24),

                    // --- 4. Skill Level ---
                    Text(
                      "Skill Level Required",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSkill,
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ["Beginner", "Intermediate", "Pro", "All Levels"]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedSkill = val!),
                    ),
                    const SizedBox(height: 24),

                    // --- 5. Players & Fee Auto-Calculation ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Players (including you)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          _maxPlayers.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _maxPlayers.toDouble(),
                      min: 2,
                      max: 22,
                      divisions: 20,
                      activeColor: AppColors.primary,
                      inactiveColor: isDark
                          ? Colors.white24
                          : Colors.grey.shade300,
                      onChanged: (val) =>
                          setState(() => _maxPlayers = val.toInt()),
                    ),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Hourly Fee per Person",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                "Court Price ÷ Total Players",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "LKR ${calculatedFee.toStringAsFixed(0)}/hr",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Cancellation Policy Note (Adapted for Dark Mode)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.orange.withValues(alpha: 0.3)
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: isDark
                                ? Colors.orange.shade300
                                : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Cancellation Policy: Bookings and matches cannot be refunded if cancelled within the last 12 hours before the start time.",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.orange.shade200
                                    : Colors.orange.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _proceedToBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Proceed to Book Court",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
