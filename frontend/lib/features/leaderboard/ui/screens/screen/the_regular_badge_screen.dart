import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class TheRegularBadgeScreen extends StatefulWidget {
  const TheRegularBadgeScreen({super.key});

  @override
  State<TheRegularBadgeScreen> createState() => _TheRegularBadgeScreenState();
}

class _TheRegularBadgeScreenState extends State<TheRegularBadgeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final GlobalKey _badgeKey = GlobalKey();

  @override
  void initState() {
    super.initState();

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

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
      backgroundColor: const Color(0xFF0A1F0A), // Deep forest green
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
          // Background — rich green gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF1B5E20), // Deep green glow
                  Color(0xFF0A1F0A), // Dark background
                ],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: ScaleTransition(scale: _scaleAnimation, child: child),
                          ),
                        );
                      },
                      child: RepaintBoundary(key: _badgeKey, child: _buildBadgeArea()),
                    ),

                    const SizedBox(height: 48),

                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                              CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
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

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return Opacity(opacity: _fadeAnimation.value * 0.5, child: child);
                },
                child: CustomPaint(
                  painter: _ConfettiPainter(
                    controller: _entranceController,
                    colors: const [Color(0xFF66BB6A), Colors.white, Color(0xFFA5D6A7), Colors.lightGreenAccent],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return Opacity(
                opacity: Tween<double>(begin: 0, end: 1)
                    .animate(CurvedAnimation(parent: _entranceController, curve: const Interval(0.7, 1.0)))
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
        // Rotating green sparkle ring
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
                  const Color(0xFF66BB6A).withValues(alpha: 0.0),
                  const Color(0xFF66BB6A).withValues(alpha: 0.35),
                  const Color(0xFF66BB6A).withValues(alpha: 0.0),
                  const Color(0xFF66BB6A).withValues(alpha: 0.35),
                  const Color(0xFF66BB6A).withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Pulsing green glow
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
                    color: const Color(0xFF66BB6A).withValues(alpha: 0.3 * _pulseController.value),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            );
          },
        ),

        // Badge — rich green gradient
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF81C784), // Light green
                Color(0xFF388E3C), // Mid green
                Color(0xFF1B5E20), // Deep green
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.repeat_rounded, // 🔁 The Regular
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF66BB6A).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF66BB6A).withValues(alpha: 0.5)),
          ),
          child: const Text(
            'NEW BADGE UNLOCKED',
            style: TextStyle(
              color: Color(0xFF66BB6A),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'The Regular',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Creature of habit, master of the court! This badge is awarded for booking the exact same court at the exact same time for three consecutive weeks.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
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
            onPressed: () async {
              try {
                RenderRepaintBoundary boundary =
                    _badgeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                if (byteData != null) {
                  final buffer = byteData.buffer;
                  final tempDir = await getTemporaryDirectory();
                  final file = await File('${tempDir.path}/badge.png').create();
                  await file.writeAsBytes(
                    buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
                  );
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: "I just earned 'The Regular' badge on CourtConnect! Same court, same time, 3 weeks running!",
                  );
                }
              } catch (e) {
                debugPrint('Error sharing badge: $e');
                Share.share("I just earned 'The Regular' badge on CourtConnect! Same court, same time, 3 weeks running!");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF66BB6A),
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: const Color(0xFF66BB6A).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
            style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final Animation<double> controller;
  final List<Color> colors;

  _ConfettiPainter({required this.controller, required this.colors}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.value == 0) return;
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      double x = random.nextDouble() * size.width;
      double startY = random.nextDouble() * size.height / 2;
      double y = startY + (controller.value * size.height * 0.5);
      x += math.sin(controller.value * 2 * math.pi + i) * 20;
      double s = random.nextDouble() * 6 + 2;
      final color = colors[random.nextInt(colors.length)];
      paint.color = color.withValues(alpha: 1.0 - (controller.value * 0.8));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(controller.value * 4 * math.pi * random.nextDouble());
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: s, height: s), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
