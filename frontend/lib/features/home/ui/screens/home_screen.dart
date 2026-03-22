import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/avatar_constants.dart';
import '../../../../core/services/user_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../chatbot/presentation/screens/chatbot_screen.dart';
import '../../../booking/data/booking_service.dart'; 
import '../../../booking/ui/screens/booking_screen.dart'; 
import '../../../booking/ui/screens/court_details_screen.dart'; 
import '../../../profile/ui/screens/profile_screen.dart'; // NEW: Imported Profile Screen
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  Timer? _timer;
  bool _isChatbotVisible = true;

  // Real Database integration
  final BookingService _bookingService = BookingService();
  List<Map<String, dynamic>> _popularCourts = [];
  bool _isLoadingCourts = true;

  final List<String> _bannerImages = [
    'https://images.unsplash.com/photo-1760174012435-630a17a434ed?q=80&w=800',
    'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?q=80&w=800',
    'https://images.unsplash.com/photo-1531415074968-036ba1b575da?q=80&w=800',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _fetchPopularCourts();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUser();
    });
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isChatbotVisible) {
        setState(() => _isChatbotVisible = false);
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isChatbotVisible) {
        setState(() => _isChatbotVisible = true);
      }
    }
  }

  Future<void> _fetchPopularCourts() async {
    final courts = await _bookingService.getAllCourts();
    if (mounted) {
      setState(() {
        _popularCourts = courts.take(4).toList(); 
        _isLoadingCourts = false;
      });
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      _currentPage = _currentPage < _bannerImages.length - 1 ? _currentPage + 1 : 0;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToBookingWithFilter(String sport) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(initialSportFilter: sport),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final userName = user?['name'] ?? 'Player';
    final profileImageCandidate = user?['profileImage'];
    final userImage = AvatarConstants.avatarUrl(profileImageCandidate?.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // NEW: Navigates to the ProfileScreen instead of the Modal
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).cardColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundImage: NetworkImage(userImage),
                                onBackgroundImageError: (_, __) =>
                                    const Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back,',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                userProvider.isLoading
                                    ? const SizedBox(
                                        width: 100,
                                        height: 20,
                                        child: LinearProgressIndicator(),
                                      )
                                    : Text(
                                        userName,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                size: 22,
                                color: isDark ? Colors.amber : Theme.of(context).iconTheme.color,
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
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Icon(
                                    Icons.notifications_none_rounded,
                                    size: 22,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _bannerImages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8, left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: NetworkImage(_bannerImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.bottomLeft,
                          child: const Text(
                            'Summer Tournament\nRegistration Open!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Start Playing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85, 
                  children: [
                    _SportCard(
                      name: 'Cricket',
                      icon: Icons.sports_cricket,
                      color: const Color(0xFFE91E63),
                      onTap: () => _navigateToBookingWithFilter('Cricket'),
                    ),
                    _SportCard(
                      name: 'Tennis',
                      icon: Icons.sports_tennis,
                      color: const Color(0xFFFF9800),
                      onTap: () => _navigateToBookingWithFilter('Tennis'),
                    ),
                    _SportCard(
                      name: 'Basketball',
                      icon: Icons.sports_basketball,
                      color: const Color(0xFFFF5722),
                      onTap: () => _navigateToBookingWithFilter('Basketball'),
                    ),
                    _SportCard(
                      name: 'Football',
                      icon: Icons.sports_soccer,
                      color: const Color(0xFF4CAF50),
                      onTap: () => _navigateToBookingWithFilter('Football'),
                    ),
                    _SportCard(
                      name: 'Badminton',
                      icon: Icons.sports_tennis,
                      color: const Color(0xFF009688),
                      onTap: () => _navigateToBookingWithFilter('Badminton'),
                    ),
                    _SportCard(
                      name: 'Swimming',
                      icon: Icons.pool,
                      color: const Color(0xFF2196F3),
                      onTap: () => _navigateToBookingWithFilter('Swimming'),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Nearby',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: _isLoadingCourts 
                  ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                  : _popularCourts.isEmpty
                    ? const SliverToBoxAdapter(child: Center(child: Text("No courts available right now.")))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final court = _popularCourts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _CreativeCourtCard(
                                court: court,
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: court))
                                ),
                              ),
                            );
                          },
                          childCount: _popularCourts.length,
                        ),
                      ),
              ),
            ],
          ),
          
          Positioned(
            right: 20,
            bottom: 110,
            child: AnimatedScale(
              scale: _isChatbotVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut, 
              child: AnimatedOpacity(
                opacity: _isChatbotVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const _AnimatedChatbotButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedChatbotButton extends StatefulWidget {
  const _AnimatedChatbotButton();

  @override
  State<_AnimatedChatbotButton> createState() => _AnimatedChatbotButtonState();
}

class _AnimatedChatbotButtonState extends State<_AnimatedChatbotButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                AppColors.primary, 
                Color(0xFF00E676), 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _iconScaleAnimation,
                child: RotationTransition(
                  turns: _rotateAnimation,
                  child: const Icon(
                    Icons.smart_toy_rounded, 
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Ask AI",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  const _SportCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap, 
  });

  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(isDark ? 0.3 : 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.1 : 0.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  icon,
                  size: 85,
                  color: color.withOpacity(isDark ? 0.15 : 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreativeCourtCard extends StatelessWidget {
  final Map<String, dynamic> court; 
  final VoidCallback onTap;

  const _CreativeCourtCard({required this.court, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String name = court['name'] ?? 'Awesome Court';
    String price = court['pricePerHour']?.toString() ?? '1500';
    String image = (court['images'] as List?)?.isNotEmpty == true 
        ? court['images'][0] 
        : 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=800';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '4.8', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LKR $price / hour',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}