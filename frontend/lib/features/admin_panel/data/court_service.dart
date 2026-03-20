import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class CourtService {
  // 1. Add a new court
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

  // 2. Get courts by owner ID
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

  // 3. NEW: Get Quick Dashboard Stats (Today's Bookings & Monthly Revenue)
  Future<Map<String, dynamic>> getDashboardStats(String ownerId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/courts/owner/$ownerId/stats"),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"todaysBookings": 0, "monthlyRevenue": 0};
    } catch (e) {
      return {"todaysBookings": 0, "monthlyRevenue": 0};
    }
  }

  // 4. NEW: Get All Bookings for Owner
  Future<List<Map<String, dynamic>>> getOwnerBookings(String ownerId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/courts/owner/$ownerId/bookings"),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 5. NEW: Get Detailed Revenue Breakdown
  Future<Map<String, dynamic>> getOwnerRevenue(String ownerId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/courts/owner/$ownerId/revenue"),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"totalRevenue": 0, "breakdown": []};
    } catch (e) {
      return {"totalRevenue": 0, "breakdown": []};
    }
  }
}