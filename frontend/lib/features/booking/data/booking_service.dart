import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class BookingService {
  // Fetch all courts (Players View)
  Future<List<Map<String, dynamic>>> getAllCourts() async {
    try {
      final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/courts"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching courts: $e");
      return [];
    }
  }
}