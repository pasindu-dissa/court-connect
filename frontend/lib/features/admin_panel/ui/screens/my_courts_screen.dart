import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_provider.dart';
import '../../data/court_service.dart';
import 'add_court_screen.dart';

class MyCourtsScreen extends StatefulWidget {
  const MyCourtsScreen({super.key});

  @override
  State<MyCourtsScreen> createState() => _MyCourtsScreenState();
}

class _MyCourtsScreenState extends State<MyCourtsScreen> {
  final CourtService _courtService = CourtService();
  List<Map<String, dynamic>> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  void _loadCourts() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null && user['_id'] != null) {
      final courts = await _courtService.getMyCourts(user['_id']);
      setState(() {
        _courts = courts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Courts")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourtScreen()));
          if (result == true) {
            _isLoading = true;
            setState(() {});
            _loadCourts(); // Refresh list
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _courts.isEmpty 
          ? const Center(child: Text("No courts added yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courts.length,
              itemBuilder: (context, index) {
                final court = _courts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          court['images'] != null && (court['images'] as List).isNotEmpty 
                            ? court['images'][0] 
                            : "https://via.placeholder.com/300",
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.image)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(court['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("${court['sport']} • ${court['location']}", style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text("LKR ${court['pricePerHour']}/hr", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}