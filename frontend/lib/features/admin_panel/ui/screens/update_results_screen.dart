import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/user_provider.dart';
import '../../../../core/constants/avatar_constants.dart';

class UpdateResultsScreen extends StatefulWidget {
  const UpdateResultsScreen({super.key});

  @override
  State<UpdateResultsScreen> createState() => _UpdateResultsScreenState();
}

class _UpdateResultsScreenState extends State<UpdateResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Assume the owner manages "Central Stadium" for now, or fetch dynamically in production
  String _selectedSport = 'badminton';
  final List<String> _sports = ['badminton', 'tennis', 'basketball', 'football'];

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final token = user?['token'] ?? '';
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/search?q=$query'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _awardPoint(String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final token = user?['token'] ?? '';

      // Hardcode default courtId or get somehow (requires court selector implementation)
      // We will assume "60c72b2f9b1e8a001c8e4a9e" as dummy, or prompt owner to select
      // But let's retrieve courts? This is just MVP. Let's pass a dummy CourtId.
      final dummyCourtId = "60b9b3b3b4g5d6e7f8a9b0c1";

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/leaderboard/award-point'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'sportType': _selectedSport,
          'courtId': dummyCourtId, // To be replaced with actual owner's court
        }),
      );

      Navigator.pop(context); // close loader

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Point awarded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to award point: ${response.body}')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      debugPrint('Award point error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error adding point.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sport Selector
            DropdownButton<String>(
              value: _selectedSport,
              isExpanded: true,
              items: _sports.map((sport) => DropdownMenuItem(value: sport, child: Text(sport.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedSport = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search user by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchUsers('');
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _searchUsers,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final u = _searchResults[index];
                      final avatar = AvatarConstants.avatarUrl(u['profileImage']);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                          child: avatar.isEmpty ? const Icon(Icons.person) : null,
                        ),
                        title: Text(u['name'] ?? 'Unknown User'),
                        subtitle: Text(u['email'] ?? ''),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _awardPoint(u['_id'] ?? u['id']),
                          icon: const Icon(Icons.add),
                          label: const Text('1 Point'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
