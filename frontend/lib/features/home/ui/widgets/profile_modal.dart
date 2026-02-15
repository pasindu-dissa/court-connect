import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_provider.dart';
import '../../../auth/ui/screens/login_screen.dart';

class ProfileModal extends StatelessWidget {
  const ProfileModal({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String name = user?['name'] ?? "Guest";
    final String email = user?['email'] ?? "No Email";
    final String location = user?['location'] ?? "Sri Lanka";
    final String image = user?['profileImage'] ?? "https://i.pravatar.cc/300";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),

          // User Info
          Row(
            children: [
              CircleAvatar(radius: 35, backgroundImage: NetworkImage(image)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                        Text(location, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: AppColors.primary))
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Settings
          _buildSettingsTile(
            context,
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: "Dark Mode",
            trailing: Switch(
              value: isDark,
              activeColor: AppColors.primary,
              onChanged: (val) {
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
          
          _buildSettingsTile(context, icon: Icons.info_outline_rounded, title: "About CourtConnect", trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),

          const SizedBox(height: 30),

          // Sign Out
          TextButton.icon(
            onPressed: () async {
               await AuthService().signOut();
               userProvider.clearUser();
               if (context.mounted) {
                 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
               }
            },
            icon: const Icon(Icons.logout, size: 16, color: AppColors.error),
            label: const Text("Sign Out", style: TextStyle(color: AppColors.error, fontSize: 14)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), backgroundColor: AppColors.error.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]), child: Icon(icon, color: AppColors.primary)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
          trailing,
        ],
      ),
    );
  }
}