import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/avatar_constants.dart';
import '../../../../core/services/user_provider.dart';
import '../../data/court_service.dart';

class UpdateResultsScreen extends StatefulWidget {
  const UpdateResultsScreen({super.key});

  @override
  State<UpdateResultsScreen> createState() => _UpdateResultsScreenState();
}

class _UpdateResultsScreenState extends State<UpdateResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CourtService _courtService = CourtService();

  List<dynamic> _searchResults = [];
  List<Map<String, dynamic>> _myCourts = [];
  String? _selectedCourtId;
  String? _selectedCourtName;
  bool _isLoading = false;
  bool _isLoadingCourts = true;

  String _selectedSport = 'badminton';
  final List<String> _sports = ['badminton', 'tennis', 'basketball', 'football'];

  @override
  void initState() {
    super.initState();
    _loadMyCourts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMyCourts() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final ownerId = user?['_id'] ?? user?['id'];
    if (ownerId == null) {
      setState(() => _isLoadingCourts = false);
      return;
    }

    try {
      final courts = await _courtService.getMyCourts(ownerId);
      if (mounted) {
        setState(() {
          _myCourts = courts;
          if (courts.isNotEmpty) {
            _selectedCourtId = courts.first['_id']?.toString();
            _selectedCourtName = courts.first['name']?.toString();
          }
          _isLoadingCourts = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading courts: $e');
      if (mounted) setState(() => _isLoadingCourts = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/search?q=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() => _searchResults = jsonDecode(response.body));
      } else {
        debugPrint('Search failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _awardPoint(String userId, String userName) async {
    if (_selectedCourtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No court found. Please register a court first.')),
      );
      return;
    }

    // Confirm before awarding
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Award Point'),
        content: Text('Award 1 point to $userName for $_selectedSport at $_selectedCourtName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Award'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/leaderboard/award-point'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'sportType': _selectedSport,
          'courtId': _selectedCourtId,
        }),
      );

      if (!mounted) return;
      Navigator.pop(context); // close loader

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ 1 point awarded to $userName!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${jsonDecode(response.body)['message'] ?? response.body}')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint('Award point error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error awarding point.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCourts) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_myCourts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Update Results')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No courts found.\nPlease register a court first.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Update Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Selector (if owner has multiple courts)
            if (_myCourts.length > 1) ...[
              const Text('Court', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCourtId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _myCourts.map((court) => DropdownMenuItem(
                  value: court['_id']?.toString(),
                  child: Text(court['name']?.toString() ?? 'Unnamed court'),
                )).toList(),
                onChanged: (v) => setState(() {
                  _selectedCourtId = v;
                  _selectedCourtName = _myCourts
                      .firstWhere((c) => c['_id']?.toString() == v, orElse: () => {})['name']
                      ?.toString();
                }),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Show court name as a label when there's only one
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_tennis, color: Colors.deepPurple, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCourtName ?? 'My Court',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Sport Selector
            const Text('Sport', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedSport,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: _sports.map((sport) => DropdownMenuItem(
                value: sport,
                child: Text(sport.toUpperCase()),
              )).toList(),
              onChanged: (v) => setState(() => _selectedSport = v!),
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search player by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchUsers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _searchUsers,
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Search for a player to award points'
                                : 'No players found',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final u = _searchResults[index];
                            final avatar = AvatarConstants.avatarUrl(u['profileImage']);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                  backgroundColor: Colors.deepPurple.shade100,
                                  child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.deepPurple) : null,
                                ),
                                title: Text(
                                  u['name'] ?? 'Unknown User',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(u['email'] ?? ''),
                                trailing: ElevatedButton.icon(
                                  onPressed: () => _awardPoint(
                                    u['_id'] ?? u['id'] ?? '',
                                    u['name'] ?? 'Player',
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('+1 Pt'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
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
