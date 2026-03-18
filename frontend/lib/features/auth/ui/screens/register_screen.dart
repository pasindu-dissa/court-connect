import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/data/sl_locations.dart';
import '../../../home/ui/main_wrapper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool startOpened; // NEW: Parameter to track if panel should already be up

  const RegisterScreen({super.key, this.startOpened = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  String? _selectedDistrict;
  String? _selectedCity;
  bool _isLoading = false;

  // Animation State
  late bool _isFormVisible;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed value
    _isFormVisible = widget.startOpened;
  }

  Future<void> _registerUser({required String uid, required String email, String? password}) async {
    final userData = {
      "firebaseUid": uid,
      "name": _nameController.text.trim(),
      "email": email,
      "age": int.tryParse(_ageController.text) ?? 0,
      "district": _selectedDistrict,
      "city": _selectedCity,
      "location": "$_selectedCity, $_selectedDistrict", 
      "password": password ?? "google_auth_user",
    };

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

  void _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final credential = await _auth.signUp(_emailController.text.trim(), _passController.text.trim());
      await _registerUser(uid: credential.user!.uid, email: _emailController.text.trim(), password: "hashed_by_firebase");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in your profile details first!"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await _auth.signInWithGoogle();
      if (credential.user != null) {
        await _registerUser(uid: credential.user!.uid, email: credential.user!.email!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign Up Failed: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double panelHeight = size.height * 0.85; 

    return Scaffold(
      backgroundColor: Colors.black, 
      resizeToAvoidBottomInset: false, 
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < -10 && !_isFormVisible) {
            setState(() => _isFormVisible = true);
          } else if (details.delta.dy > 10 && _isFormVisible) {
            setState(() => _isFormVisible = false);
            FocusScope.of(context).unfocus();
          }
        },
        child: Stack(
          children: [
            // --- 1. Immersive Background Image ---
            Positioned.fill(
              child: Image.asset(
                "assets/images/CourtConnect_BG.png",
                fit: BoxFit.cover,
              ),
            ),
            
            // --- 2. Gradient Overlay ---
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isFormVisible ? 0.9 : 0.4,
                duration: const Duration(milliseconds: 600),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black26, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.3, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // --- 3. Bouncing "Swipe Up" Prompt ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.fastLinearToSlowEaseIn,
              bottom: _isFormVisible ? size.height : 60,
              left: 0, right: 0,
              child: const _BouncingPrompt(text: "Swipe up to register"),
            ),

            // --- 4. The Slide-Up Form Panel ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.fastLinearToSlowEaseIn,
              bottom: _isFormVisible ? 0 : -panelHeight,
              left: 0, right: 0,
              height: panelHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, -5))],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 32, right: 32, top: 20, 
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 50, height: 5,
                            decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Text("Create Profile", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text("Let's get you set up to hit the courts.", style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                        const SizedBox(height: 24),
                        
                        // Personal Details
                        _buildModernTextField(controller: _nameController, label: "Full Name", icon: Icons.person_rounded, isDark: isDark, validator: (val) => val!.isEmpty ? "Required" : null),
                        const SizedBox(height: 16),
                        _buildModernTextField(controller: _ageController, label: "Age", icon: Icons.cake_rounded, isDark: isDark, isNumber: true, validator: (val) => val!.isEmpty ? "Required" : null),
                        const SizedBox(height: 16),
                        
                        // Dropdowns
                        DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          dropdownColor: Theme.of(context).cardColor,
                          decoration: _dropdownDecoration("District", Icons.map_rounded, isDark),
                          items: SLLocations.districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)))).toList(),
                          onChanged: (val) => setState(() { _selectedDistrict = val; _selectedCity = null; }),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          dropdownColor: Theme.of(context).cardColor,
                          decoration: _dropdownDecoration("City / Area", Icons.location_city_rounded, isDark),
                          items: _selectedDistrict == null ? [] : SLLocations.districtCities[_selectedDistrict]!.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)))).toList(),
                          onChanged: (val) => setState(() => _selectedCity = val),
                          validator: (val) => val == null ? "Required" : null,
                        ),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),

                        // Security Details
                        Text("Secure Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(height: 16),
                        _buildModernTextField(controller: _emailController, label: "Email Address", icon: Icons.email_rounded, isDark: isDark, validator: (val) => null),
                        const SizedBox(height: 16),
                        _buildModernTextField(controller: _passController, label: "Password", icon: Icons.lock_rounded, isObscure: true, isDark: isDark),
                        const SizedBox(height: 24),

                        // Buttons
                        SizedBox(
                          height: 55,
                          width: double.infinity * 0.5,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleEmailSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), elevation: 0,
                            ),
                            child: _isLoading 
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                              : const Text("Register with Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontWeight: FontWeight.bold))),
                            Expanded(child: Divider(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _handleGoogleSignUp,
                            icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png', height: 24),
                            label: Text("Register using Google", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                            TextButton(
                              onPressed: () {
                                // NEW: Pass startOpened: true to keep the panel up!
                                Navigator.pushReplacement(context, PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(startOpened: true),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ));
                              },
                              child: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({required TextEditingController controller, required String label, required IconData icon, bool isObscure = false, bool isNumber = false, required bool isDark, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, obscureText: isObscure, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true, fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: validator,
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label, labelStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      filled: true, fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}

class _BouncingPrompt extends StatefulWidget {
  final String text;
  const _BouncingPrompt({required this.text});

  @override
  State<_BouncingPrompt> createState() => _BouncingPromptState();
}

class _BouncingPromptState extends State<_BouncingPrompt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.keyboard_double_arrow_up_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              Text(widget.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ],
          ),
        );
      }
    );
  }
}