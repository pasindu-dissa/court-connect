import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class MatchmakingService {
  
  // 1. Fetch Matches (For Matches Tab)
  Future<List<Map<String, dynamic>>> getMatches({String? sport, String? location}) async {
    try {
      // Build Query Parameters
      String query = "";
      if (sport != null && sport != "All") query += "?sport=$sport";
      if (location != null && location.isNotEmpty) {
        query += (query.isEmpty ? "?" : "&") + "location=$location";
      }

      final response = await http.get(Uri.parse("${ApiConstants.matches}$query"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception("Failed to load matches");
      }
    } catch (e) {
      print("Error fetching matches: $e");
      return []; // Return empty list on error to prevent crash
    }
  }

  // 2. Scan Opponents (For Opponents Tab)
  Future<List<Map<String, dynamic>>> scanOpponents({
    required String sport,
    required String location,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.opponents),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sport": sport,
          "location": location,
          "userId": userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = data['opponents'];
        return list.map((item) => item as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error scanning opponents: $e");
      return [];
    }
  }
}