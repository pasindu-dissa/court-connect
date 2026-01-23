import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkTheme = false;
  final TextEditingController _nameController = TextEditingController(text: "Alex Johnson");
  final TextEditingController _emailController = TextEditingController(text: "alex.johnson@example.com");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Profile Image with Edit Badge
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // 2. Edit Details Section
            _buildSectionHeader("Personal Details"),
            const SizedBox(height: 16),
            _buildTextField("Full Name", _nameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField("Email", _emailController, Icons.email_outlined),

            const SizedBox(height: 32),

            // 3. Settings Section
            _buildSectionHeader("Settings"),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // Theme Toggle
                  SwitchListTile(
                    activeColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600)),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.dark_mode_rounded, color: Colors.purple),
                    ),
                    value: _isDarkTheme,
                    onChanged: (val) {
                      setState(() => _isDarkTheme = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Theme switched! (Demo Only)")),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  // About App
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.info_outline_rounded, color: Colors.blue),
                    ),
                    title: const Text("About App", style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Court Connect",
                        applicationVersion: "1.0.0",
                        applicationLegalese: "© 2026 Court Connect Inc.",
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Sign Out Logic
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.error, width: 1),
                ),
                child: const Text("Sign Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}