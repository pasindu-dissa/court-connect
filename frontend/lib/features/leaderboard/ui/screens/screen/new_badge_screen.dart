import 'package:flutter/material.dart';
import 'dart:math' as math;

class NewBadgeScreen extends StatefulWidget {
  const NewBadgeScreen({super.key});

  @override
  State<NewBadgeScreen> createState() => _NewBadgeScreenState();
}

class _NewBadgeScreenState extends State<NewBadgeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation (Slide, Fade, Scale)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    // 2. Continuous Pulse Animation for the Badge
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 3. Sparkle Rotation Animation
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    // Start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Sleek dark theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background subtle gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF2C1B4D), // Deep purple glow
                  Color(0xFF121212), // Dark background
                ],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Badge Area
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _buildBadgeArea(),
                    ),

                    const SizedBox(height: 48),

                    // Text Content with delayed entrance
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: _entranceController,
                              curve: const Interval(
                                0.5,
                                1.0,
                                curve: Curves.easeIn,
                              ),
                            ),
                          ),
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _entranceController,
                                    curve: const Interval(
                                      0.5,
                                      1.0,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                                ),
                            child: child,
                          ),
                        );
                      },
                      child: _buildTextContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confetti overlay effect (Visual polish)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value * 0.5, // Subtle overlay
                    child: child,
                  );
                },
                child: CustomPaint(
                  painter: _ConfettiPainter(controller: _entranceController),
                ),
              ),
            ),
          ),
        ],
      ),

      // Interactive Bottom Action
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return Opacity(
                opacity: Tween<double>(begin: 0, end: 1)
                    .animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: const Interval(0.7, 1.0),
                      ),
                    )
                    .value,
                child: child,
              );
            },
            child: _buildActionButtons(),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeArea() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating background sparkles/rays
        AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _sparkleController.value * 2 * math.pi,
              child: child,
            );
          },
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.amber.withOpacity(0.0),
                  Colors.amber.withOpacity(0.3),
                  Colors.amber.withOpacity(0.0),
                  Colors.amber.withOpacity(0.3),
                  Colors.amber.withOpacity(0.0),
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Pulsing glow behind the badge
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 180 + (_pulseController.value * 20),
              height: 180 + (_pulseController.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFFFD700,
                    ).withOpacity(0.3 * _pulseController.value),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            );
          },
        ),

        // The central Badge Container
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFDF00), // Bright gold
                Color(0xFFD4AF37), // Metallic gold
                Color(0xFF996515), // Dark gold
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.wine_bar, // The Rival badge icon
              size: 70,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent() {
    return Column(
      children: [
        // "NEW BADGE UNLOCKED" Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: const Text(
            'NEW BADGE UNLOCKED',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Badge Title
        const Text(
          'The Rival',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),

        const SizedBox(height: 16),

        // Description
        Text(
          'You have proven yourself a worthy opponent! This badge is awarded for challenging and defeating a team ranked higher than yours in a competitive match.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Add interaction logic, e.g., share
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700), // Gold
              foregroundColor: Colors.black, // Dark text
              elevation: 8,
              shadowColor: Colors.amber.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Share Achievement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Keep Playing',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// Simple custom painter for a celebratory confetti effect during entrance
class _ConfettiPainter extends CustomPainter {
  final Animation<double> controller;

  _ConfettiPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.value == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Seeded for consistent particles

    for (int i = 0; i < 50; i++) {
      // Distribute confetti
      double x = random.nextDouble() * size.width;
      // Fall downwards based on animation
      double startY = random.nextDouble() * size.height / 2;
      double y = startY + (controller.value * size.height * 0.5);

      // Add some horizontal drift
      x += math.sin(controller.value * 2 * math.pi + i) * 20;

      // Vary sizes and colors
      double s = random.nextDouble() * 6 + 2;
      int colorChoice = random.nextInt(4);

      if (colorChoice == 0)
        paint.color = Colors.amber;
      else if (colorChoice == 1)
        paint.color = Colors.white;
      else if (colorChoice == 2)
        paint.color = Colors.pinkAccent;
      else
        paint.color = Colors.blueAccent;

      // Fade out towards the end
      paint.color = paint.color.withOpacity(1.0 - (controller.value * 0.8));

      // Draw rotated squares for confetti look
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(controller.value * 4 * math.pi * random.nextDouble());
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: s, height: s),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
