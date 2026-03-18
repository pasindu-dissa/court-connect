import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stat_section.dart';
import '../widgets/profile_info_tile.dart';
import '../widgets/profile_booking_section.dart';
import 'edit_profile_screen.dart';
import '../widgets/profile_health_section.dart';
import '../../../../features/health/ui/widgets/health_analysis_screen.dart';
import '../../../../features/health/data/health_notifier.dart';
import '../../../home/ui/screens/notifications_screen.dart'; // NEW: Imported Notifications Screen

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_provider.dart';
import '../../../auth/ui/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Load health data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthNotifier>().loadAll();
    });
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final profile = await _profileService.fetchProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains('UNAUTHORIZED')) {
        _handleUnauthorized();
      } else {
        setState(() {
          _errorMessage =
              'Failed to load profile. Please try again.\nError: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _handleUnauthorized() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (_profile == null) return;
    final updatedProfile = await Navigator.push<ProfileModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: _profile!),
      ),
    );
    if (updatedProfile != null) {
      setState(() {
        _profile = updatedProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
          ? _buildErrorState()
          : _buildProfileContent(context),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    if (_profile == null) return const SizedBox();

    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: _loadProfile,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(
                profile: _profile!,
                onEditPressed: _navigateToEditProfile,
              ),

              const SizedBox(height: 24),

              // --- Health Section ---
              const ProfileHealthSection(),
              const SizedBox(height: 20),

              // --- View Health Analysis Beautiful Button ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        Color(0xFF00E676),
                      ], // Teal to Vivid Green
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HealthAnalysisScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'View Health Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- Personal Info Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ProfileInfoTile(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: _profile!.phone,
                    ),
                    Divider(
                      color: isDark ? Colors.white10 : Colors.grey[200],
                      height: 24,
                      thickness: 1,
                    ),
                    ProfileInfoTile(
                      icon: Icons.format_quote_rounded,
                      label: 'Bio',
                      value: _profile!.bio,
                    ),
                    Divider(
                      color: isDark ? Colors.white10 : Colors.grey[200],
                      height: 24,
                      thickness: 1,
                    ),
                    ProfileInfoTile(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: _profile!.location,
                    ),
                    Divider(
                      color: isDark ? Colors.white10 : Colors.grey[200],
                      height: 24,
                      thickness: 1,
                    ),
                    ProfileInfoTile(
                      icon: Icons.map_rounded,
                      label: 'District',
                      value: _profile!.district,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- Stats Section ---
              ProfileStatSection(stats: _profile!.stats),
              const SizedBox(height: 32),

              // --- Bookings Section ---
              ProfileBookingSection(bookings: const []),
              const SizedBox(height: 40),

              // --- NEW: Settings & More Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings & More',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                            color: Colors.black.withOpacity(
                              isDark ? 0.2 : 0.04,
                            ),
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
                              onChanged: (value) {
                                themeNotifier.value = value
                                    ? ThemeMode.dark
                                    : ThemeMode.light;
                              },
                              activeColor: AppColors.primary,
                            ),
                            onTap: () {
                              themeNotifier.value = !isDark
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                            },
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
                            title: 'Help',
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
                          Divider(
                            color: isDark ? Colors.white10 : Colors.grey[200],
                            height: 1,
                            thickness: 1,
                          ),
                          _buildActionTile(
                            context: context,
                            icon: Icons.info_outline_rounded,
                            iconColor: Colors.teal,
                            title: 'About',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Small Logout Button ---
              Center(
                child: TextButton(
                  onPressed: () async {
                    await AuthService().signOut();
                    userProvider.clearUser();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
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
    );
  }

  // --- Helper Widget for Settings Actions ---
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
