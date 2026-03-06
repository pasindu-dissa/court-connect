import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';

class ProfileService {
  // Change IP based on your testing device:
  // Android Emulator  → http://10.0.2.2:5000
  // Physical Device   → http://YOUR_PC_IP:5000
  // iOS Simulator     → http://127.0.0.1:5000
  static const String baseUrl = 'http://10.0.2.2:5000/api/users/profile';

  // Get Firebase JWT token
  Future<String?> _getToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      return token;
    } catch (e) {
      print('Token error: $e');
      return null;
    }
  }

  // Build auth headers
  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /api/users/profile
  
  Future<ProfileModel> fetchProfile() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ProfileModel.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        throw Exception('Failed to fetch profile: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
 
  // PUT /api/users/profile
  
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ProfileModel.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

}