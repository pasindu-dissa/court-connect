import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class MatchmakingService {
  Future<List<Map<String, dynamic>>> getMatches() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.matches));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching matches: $e");
      return [];
    }
  }

  Future<bool> createMatch(Map<String, dynamic> matchData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.matches),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(matchData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error creating match: $e");
      return false;
    }
  }

  Future<bool> updateMatch(String matchId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.matches}/$matchId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updates),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating match: $e");
      return false;
    }
  }

  // --- NEW: Join Flow ---
  Future<bool> requestJoinMatch(String matchId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.matches}/$matchId/request-join"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error requesting to join match: $e");
      return false;
    }
  }

  Future<bool> approvePlayer(String matchId, String playerId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.matches}/$matchId/approve"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"playerId": playerId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectPlayer(String matchId, String playerId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.matches}/$matchId/reject"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"playerId": playerId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getOpponents() async {
    try {
      final response = await http.get(Uri.parse("${ApiConstants.matches}/opponents"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) {
          return {
            "type": "player",
            "name": e['name'] ?? "Player",
            "image": e['profileImage'] ?? "https://i.pravatar.cc/150",
            "skill": e['skills']?.isNotEmpty == true ? e['skills'][0]['level'] : "Beginner",
            "location": e['district'] ?? e['location'] ?? "Unknown",
            "wins": e['stats']?['wins'] ?? 0,
            "lat": 6.9271,
            "lng": 79.8612,
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching opponents: $e");
      return [];
    }
  }
}