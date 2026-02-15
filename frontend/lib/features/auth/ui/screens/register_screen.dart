import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/ui/main_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleSignUp() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final credential = await _auth.signUp(_emailController.text.trim(), _passController.text.trim());
      
      // In a real app, you'd verify if the user exists in your MongoDB first
      // or handle the "create user" logic on the backend triggered by Firebase Auth triggers.
      // For this demo, we'll try to create it manually.
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firebaseUid": credential.user!.uid,
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": "hashed_by_firebase_unused_here" 
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) { // 200 if already exists but just signed in
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const MainWrapper()),
          );
        }
      } else {
        // Fallback: If backend fails, maybe let them in but show error? 
        // Or strictly fail. Let's fail for now to ensure data consistency.
        throw "Failed to create profile on server: ${response.body}";
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _auth.signInWithGoogle();
      
      // Check if user exists in MongoDB, if not create them
      // (Simplified logic: always try to create, backend should handle duplicates gracefully)
      final user = credential.user;
      if (user != null) {
         await http.post(
          Uri.parse("${ApiConstants.baseUrl}/users"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "firebaseUid": user.uid,
            "name": user.displayName ?? "User",
            "email": user.email,
            "password": "google_auth_user"
          }),
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const MainWrapper()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign Up Failed: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Join the CourtConnect community", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            
            // Sign Up Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 16),
            
            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OR", style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            
            const SizedBox(height: 16),

            // Google Button
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignUp,
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                  height: 24,
                ),
                label: const Text("Sign up with Google"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}