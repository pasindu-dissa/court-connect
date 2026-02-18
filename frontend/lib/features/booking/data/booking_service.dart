import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class BookingService {
  // Fetch courts
  Future<List<Map<String, dynamic>>> getAllCourts() async {
    try {
      final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/courts"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching courts: $e");
      return [];
    }
  }

  // Get booked slots for a specific date
  Future<List<String>> getBookedSlots(String courtId, String date) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/bookings/$courtId?date=$date"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Extract start times (e.g. "10:00 AM")
        return data.map((e) => e['startTime'] as String).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching slots: $e");
      return [];
    }
  }

  // Create booking
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/bookings"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bookingData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error creating booking: $e");
      return false;
    }
  }
}