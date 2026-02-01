import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../widgets/profile_modal.dart'; // Import Modal
import 'notifications_screen.dart'; // Import Screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ... (Auto Scroll Logic remains exactly the same as before) ...
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;
  final List<String> _bannerImages = [
    "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=800&auto=format&fit=crop", 
    "https://images.unsplash.com/photo-1626224583764-847890e058f5?q=80&w=800&auto=format&fit=crop", 
    "https://images.unsplash.com/photo-1531415074968-036ba1b575da?q=80&w=800&auto=format&fit=crop", 
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Updated Header with Interactions
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Profile (Clickable)
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent, // Important for rounded corners
                        isScrollControlled: true,
                        builder: (context) => const ProfileModal(),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).cardColor, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                          ),
                          child: const CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage("https://images.unsplash.com/photo-1588516903720-8ceb67f9ef84?q=80&w=300&auto=format&fit=crop"),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text("Alex Johnson", style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Right: Notification (Clickable)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: Stack(
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 26, color: Theme.of(context).iconTheme.color),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10, height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // ... (Rest of the body remains identical to previous code: Banners, Grid, Courts) ...
          // Just paste the Banners, Sports Grid, and Popular Courts sections here from the previous file.
          // For brevity, I assume you kept the previous body code.
          
           SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _bannerImages.length,
                onPageChanged: (int index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: DecorationImage(image: NetworkImage(_bannerImages[index]), fit: BoxFit.cover),
                      //boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
                      ),
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.bottomLeft,
                      child: const Text("Summer Tournament\nRegistration Open! 🏆", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(child: Text("Start Playing", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid.count(
              crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.9,
              children: [
                _SportCard(name: "Cricket", icon: Icons.sports_cricket, color: const Color(0xFFE91E63)),
                _SportCard(name: "Tennis", icon: Icons.sports_tennis, color: const Color(0xFFFF9800)),
                _SportCard(name: "Basketball", icon: Icons.sports_basketball, color: const Color(0xFFFF5722)),
                _SportCard(name: "Football", icon: Icons.sports_soccer, color: const Color(0xFF4CAF50)),
                _SportCard(name: "Badminton", icon: Icons.sports_tennis, color: const Color(0xFF009688)),
                _SportCard(name: "Swimming", icon: Icons.pool, color: const Color(0xFF2196F3)),
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
                  Text("Popular Nearby", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                  TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: AppColors.primary))),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _CreativeCourtCard(name: "Royal Badminton Complex", image: "https://images.unsplash.com/photo-1626224583764-847890e058f5?q=80&w=800&auto=format&fit=crop", price: "LKR 2500", rating: "4.9"),
                const SizedBox(height: 20),
                const _CreativeCourtCard(name: "Urban Basketball Arena", image: "https://images.unsplash.com/photo-1505666287802-931dc83948e9?q=80&w=800&auto=format&fit=crop", price: "LKR 1200", rating: "4.5"),
                const SizedBox(height: 20),
                const _CreativeCourtCard(name: "City Futsal Club", image: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800&auto=format&fit=crop", price: "LKR 3000", rating: "4.7"),
                const SizedBox(height: 20),
                const _CreativeCourtCard(name: "Blue Water Swimming", image: "https://images.unsplash.com/photo-1576610616656-d3aa5d1f4534?q=80&w=800&auto=format&fit=crop", price: "LKR 800", rating: "4.8"),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SUB-WIDGETS (Updated for Dark Mode) ---

class _SportCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  const _SportCard({required this.name, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }
}

class _CreativeCourtCard extends StatelessWidget {
  final String name;
  final String image;
  final String price;
  final String rating;
  const _CreativeCourtCard({required this.name, required this.image, required this.price, required this.rating});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.85)], stops: const [0.5, 1.0]))),
          Positioned(top: 16, right: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15)), child: Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 16), const SizedBox(width: 4), Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))]))),
          Positioned(bottom: 20, left: 20, right: 20, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 4), Text("$price / hour", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14))])), Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20))])),
        ],
      ),
    );
  }
}