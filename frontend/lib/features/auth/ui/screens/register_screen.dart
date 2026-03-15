import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/data/sl_locations.dart';
import '../../../home/ui/main_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  
  // Controllers & State
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  String? _selectedDistrict;
  String? _selectedCity;
  bool _isLoading = false;

  // 1. Backend Registration Logic
  Future<void> _registerUser({required String uid, required String email, String? password}) async {
    // 1. Prepare Data
    final userData = {
      "firebaseUid": uid,
      "name": _nameController.text.trim(),
      "email": email,
      "age": int.tryParse(_ageController.text) ?? 0,
      "district": _selectedDistrict,
      "city": _selectedCity,
      "location": "$_selectedCity, $_selectedDistrict", // Combo string for ease
      "password": password ?? "google_auth_user", // Placeholder if Google
    };

    // 2. Call Backend
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const MainWrapper()),
          );
        }
      } else {
        throw "Server Error: ${response.body}";
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // 2. Auth Handlers
  void _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final credential = await _auth.signUp(
        _emailController.text.trim(), 
        _passController.text.trim()
      );
      await _registerUser(
        uid: credential.user!.uid, 
        email: _emailController.text.trim(),
        password: "hashed_by_firebase"
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in your profile details first!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await _auth.signInWithGoogle();
      if (credential.user != null) {
        await _registerUser(
          uid: credential.user!.uid, 
          email: credential.user!.email!
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
      appBar: AppBar(
        title: const Text("Create Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Section 1: Profile Details ---
              const Text(
                "Tell us about yourself",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("These details will be shown on your player profile.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Full Name", Icons.person_outline),
                validator: (val) => val!.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Age", Icons.cake_outlined),
                validator: (val) => val!.isEmpty ? "Age is required" : null,
              ),
              const SizedBox(height: 16),

              // District Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: _inputDecoration("District", Icons.map_outlined),
                items: SLLocations.districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDistrict = val;
                    _selectedCity = null; // Reset city when district changes
                  });
                },
                validator: (val) => val == null ? "Select a district" : null,
              ),
              const SizedBox(height: 16),

              // City Dropdown (Dependent)
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: _inputDecoration("City / Area", Icons.location_city),
                // Load cities based on selected district, or empty if none
                items: _selectedDistrict == null 
                  ? [] 
                  : SLLocations.districtCities[_selectedDistrict]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCity = val),
                validator: (val) => val == null ? "Select a city" : null,
              ),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),

              // --- Section 2: Account Security ---
              const Text(
                "Secure your account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("Email", Icons.email_outlined),
                // Optional validation if they choose Email sign up
                validator: (val) {
                  // Only validate if text is entered (meaning they might want email signup)
                  // Or if google sign up is NOT used. For simplicity, we can validate on button press manually if needed.
                  return null; 
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: _inputDecoration("Password", Icons.lock_outline),
              ),
              const SizedBox(height: 24),

              // Sign Up Button (Email)
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Register with Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 16),
              
              Row(children: [Expanded(child: Divider(color: Colors.grey[300])), const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: Colors.grey))), Expanded(child: Divider(color: Colors.grey[300]))]),
              const SizedBox(height: 16),

              // Google Button
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignUp,
                  icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png', height: 24),
                  label: const Text("Register using Google"),
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
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}