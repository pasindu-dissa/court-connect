import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/api_constants.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  // Fetch user data from backend using Firebase Email/UID
  Future<void> loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Assuming backend has an endpoint to get user by email or firebaseUid
      // If not, we can query by email for now
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/users/me?email=${firebaseUser.email}"),
      );

      if (response.statusCode == 200) {
        _user = jsonDecode(response.body);
      } else {
        print("Failed to load user: ${response.body}");
      }
    } catch (e) {
      print("Error loading user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update local state if user edits profile
  void updateUser(Map<String, dynamic> newData) {
    _user = newData;
    notifyListeners();
  }
  
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}