import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_provider.dart';
import '../../../home/ui/main_wrapper.dart';
import '../../../admin_panel/ui/screens/court_owner_dashboard.dart';
import 'register_screen.dart';
import '../../../../core/services/push_notification_service.dart'; // <-- ADD THIS IMPORT

class LoginScreen extends StatefulWidget {
  final bool startOpened; // NEW: Parameter to track if panel should already be up

  const LoginScreen({super.key, this.startOpened = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  
  // Animation State
  late bool _isFormVisible;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed value so it stays up when navigating from Register
    _isFormVisible = widget.startOpened; 
  }

  Future<void> _checkRoleAndRedirect() async {
    await Provider.of<UserProvider>(context, listen: false).loadUser();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    
    if (mounted) {
      if (user != null && user['role'] == 'court_owner') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CourtOwnerDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapper()));
      }
    }
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await _auth.signIn(_emailController.text.trim(), _passController.text.trim());

      // ✅ ADD THIS LINE: Send token to backend after successful login!
      await PushNotificationService.updateTokenOnBackend();

      await _checkRoleAndRedirect(); 
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithGoogle();

      // ✅ ADD THIS LINE: Send token to backend after successful login!
      await PushNotificationService.updateTokenOnBackend();

      await _checkRoleAndRedirect(); 
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign In Failed: $e"), backgroundColor: Colors.red));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double panelHeight = size.height * 0.80;

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
            
            // --- 2. Gradient Overlay for readability ---
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isFormVisible ? 0.8 : 0.4,
                duration: const Duration(milliseconds: 600),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black12, Colors.black87],
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
              left: 0,
              right: 0,
              child: const _BouncingPrompt(text: "Swipe up to login"),
            ),

            // --- 4. The Slide-Up Form Panel ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.fastLinearToSlowEaseIn,
              bottom: _isFormVisible ? 0 : -panelHeight,
              left: 0,
              right: 0,
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
                      const SizedBox(height: 32),
                      
                      Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      Text("Sign in to continue your journey", style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                      const SizedBox(height: 32),
                      
                      // Modern Text Fields
                      _buildModernTextField(
                        controller: _emailController,
                        label: "Email Address",
                        icon: Icons.email_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildModernTextField(
                        controller: _passController,
                        label: "Password",
                        icon: Icons.lock_rounded,
                        isObscure: true,
                        isDark: isDark,
                      ),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Primary Login Button
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                            : const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.grey.shade300)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontWeight: FontWeight.bold))),
                          Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google Sign In
                      SizedBox(
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleLogin,
                          icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png', height: 24),
                          label: Text("Continue with Google", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                          TextButton(
                            onPressed: () {
                              // NEW: Pass startOpened: true to keep the panel up!
                              Navigator.pushReplacement(context, PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(startOpened: true),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ));
                            },
                            child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
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