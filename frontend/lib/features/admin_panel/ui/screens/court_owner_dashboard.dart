import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/user_provider.dart';
import '../../../home/ui/screens/notifications_screen.dart';
import '../../data/court_service.dart';
import '../../../auth/ui/screens/login_screen.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/avatar_constants.dart';

import 'my_courts_screen.dart';
import 'owner_bookings_screen.dart'; // NEW
import 'owner_revenue_screen.dart'; // NEW
import 'update_results_screen.dart';

class CourtOwnerDashboard extends StatefulWidget {
  const CourtOwnerDashboard({super.key});

  @override
  State<CourtOwnerDashboard> createState() => _CourtOwnerDashboardState();
}

class _CourtOwnerDashboardState extends State<CourtOwnerDashboard> {
  final CourtService _courtService = CourtService();

  bool _isLoadingStats = true;
  int _todaysBookings = 0;
  double _monthlyRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null && user['_id'] != null) {
      try {
        final stats = await _courtService.getDashboardStats(user['_id']);
        if (mounted) {
          setState(() {
            _todaysBookings = stats['todaysBookings'] ?? 0;
            _monthlyRevenue = (stats['monthlyRevenue'] ?? 0).toDouble();
            _isLoadingStats = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Logout',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of CourtConnect?',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await AuthService().signOut();
      userProvider.clearUser();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final user = Provider.of<UserProvider>(context).user;
    final userName = user?['name'] ?? 'Owner';
    final profileImageCandidate = user?['profileImage'];
    final userProfileImage = AvatarConstants.avatarUrl(profileImageCandidate?.toString());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.grey.shade200,
                      backgroundImage: userProfileImage.isNotEmpty
                          ? NetworkImage(userProfileImage)
                          : null,
                      child: userProfileImage.isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade400,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, $userName",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: theme.textTheme.bodyLarge?.color,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Court Manager",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => themeNotifier.value = isDark
                          ? ThemeMode.light
                          : ThemeMode.dark,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          size: 20,
                          color: isDark ? Colors.amber : Colors.indigo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Live Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: "Today's Bookings",
                        value: _isLoadingStats
                            ? "..."
                            : _todaysBookings.toString(),
                        icon: Icons.calendar_today_rounded,
                        gradientColors: [
                          AppColors.primary,
                          const Color(0xFF00E676),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: "Monthly Revenue",
                        value: _isLoadingStats
                            ? "..."
                            : "Rs ${_monthlyRevenue.toStringAsFixed(0)}",
                        icon: Icons.account_balance_wallet_rounded,
                        gradientColors: [
                          Colors.blue.shade600,
                          Colors.blue.shade400,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Management Menu
                Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                _buildManagementTile(
                  context,
                  title: "My Courts",
                  subtitle: "Add, edit, or remove your venues",
                  icon: Icons.stadium_outlined,
                  iconColor: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyCourtsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  context,
                  title: "Bookings & Schedules",
                  subtitle: "View reservations & player details",
                  icon: Icons.edit_calendar_rounded,
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OwnerBookingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  context,
                  title: "Update Results",
                  subtitle: "Award points to users for rankings",
                  icon: Icons.score_rounded,
                  iconColor: Colors.deepPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UpdateResultsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildManagementTile(
                  context,
                  title: "Revenue Analytics",
                  subtitle: "Detailed breakdown of your earnings",
                  icon: Icons.bar_chart_rounded,
                  iconColor: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OwnerRevenueScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Settings
                Text(
                  'Settings & More',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildActionTile(
                        context: context,
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        iconColor: isDark ? Colors.amber : Colors.indigo,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: isDark,
                          onChanged: (val) => themeNotifier.value = val
                              ? ThemeMode.dark
                              : ThemeMode.light,
                          activeColor: AppColors.primary,
                        ),
                        onTap: () => themeNotifier.value = !isDark
                            ? ThemeMode.dark
                            : ThemeMode.light,
                      ),
                      Divider(
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        height: 1,
                        thickness: 1,
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.notifications_none_rounded,
                        iconColor: Colors.orangeAccent,
                        title: 'Notifications',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        height: 1,
                        thickness: 1,
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.help_outline_rounded,
                        iconColor: Colors.blue,
                        title: 'Help Center & Support',
                        onTap: () {},
                      ),
                      Divider(
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        height: 1,
                        thickness: 1,
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.bug_report_outlined,
                        iconColor: Colors.redAccent,
                        title: 'Report a Bug',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: _handleLogout,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Sign out?',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
    );
  }
}
