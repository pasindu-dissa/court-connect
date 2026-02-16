import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_provider.dart';
import '../../../auth/ui/screens/login_screen.dart';

class CourtOwnerDashboard extends StatelessWidget {
  const CourtOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: AppColors.primaryDark, // Darker color for Admin feel
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginScreen()), 
                  (route) => false
                );
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user?['profileImage'] ?? "https://i.pravatar.cc/300"),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, ${user?['name']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text("Court Manager", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Dashboard Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAdminCard(Icons.stadium, "My Courts", Colors.blue, () {}),
                  _buildAdminCard(Icons.calendar_month, "Bookings", Colors.orange, () {}),
                  _buildAdminCard(Icons.analytics, "Revenue", Colors.green, () {}),
                  _buildAdminCard(Icons.settings, "Settings", Colors.grey, () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}