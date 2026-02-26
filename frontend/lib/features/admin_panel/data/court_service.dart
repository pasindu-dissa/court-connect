import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class CourtService {
  // Add a new court
  Future<bool> addCourt(Map<String, dynamic> courtData) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/courts"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(courtData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw "Failed to add court: ${response.body}";
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Get courts by owner ID
  Future<List<Map<String, dynamic>>> getMyCourts(String ownerId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/courts/owner/$ownerId"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw "Failed to load courts";
      }
    } catch (e) {
      print("Error loading courts: $e");
      return [];
    }
  }
}