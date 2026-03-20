import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';
import '../models/booking_model.dart';
import '../../../../core/constants/api_constants.dart';

class ProfileService {
  static const String baseUrl = '${ApiConstants.baseUrl}/users/profile';

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

  // PUT /api/users/profile/image
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final token = await _getToken();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/image'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          imageFile.path,
        ),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['profileImage'] as String;
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // GET /api/bookings/user/:userId
  Future<List<BookingModel>> fetchUserBookings(String userId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bookings/user/$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((b) => BookingModel.fromJson(b)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        throw Exception('Failed to fetch bookings: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // DELETE /api/users/profile
  Future<void> deleteAccount() async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse(baseUrl),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        throw Exception('Failed to delete account: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}