import 'package:flutter/material.dart';

class StreakScreen extends StatefulWidget {
  final int currentStreak; // Usually 5 based on dummy data

  const StreakScreen({super.key, this.currentStreak = 5});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;

  late Animation<double> _timelineOpacity;
  late Animation<Offset> _timelineSlide;

  late Animation<double> _rewardsOpacity;
  late Animation<Offset> _rewardsSlide;

  late Animation<double> _rulesOpacity;
  late Animation<Offset> _rulesSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Staggered Animations
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
          ),
        );

    _timelineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _timelineSlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _rewardsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );
    _rewardsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _rulesOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _rulesSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Streak',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeTransition(
                  opacity: _headerOpacity,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeaderCard(),
                  ),
                ),

                const SizedBox(height: 25),

                // Timeline title & widget
                FadeTransition(
                  opacity: _timelineOpacity,
                  child: SlideTransition(
                    position: _timelineSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Milestone Timeline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildTimelineWidget(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Rewards title & row
                FadeTransition(
                  opacity: _rewardsOpacity,
                  child: SlideTransition(
                    position: _rewardsSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rewards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildRewardsRow(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Rules Card
                FadeTransition(
                  opacity: _rulesOpacity,
                  child: SlideTransition(
                    position: _rulesSlide,
                    child: _buildRulesCard(),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Pulsing Fire Icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale:
                    1.0 +
                    (_pulseController.value *
                        0.15), // Pulses between 1.0 and 1.15
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(
                          0.3 * _pulseController.value,
                        ),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.deepOrange,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          Text(
            '\${widget.currentStreak} Weeks Streak!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You\'ve played or booked a court at least once a week for \${widget.currentStreak} consecutive weeks. Keep it up!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blueGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress to 12 Weeks',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              int weekNum = index + 1;
              bool isCompleted = weekNum <= widget.currentStreak;
              bool isCurrent = weekNum == widget.currentStreak + 1;
              bool isRewardWeek = weekNum == 12;

              return Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    // Stagger the timeline circles pop-in effect
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? Colors.green
                                : (isCurrent
                                      ? Colors.orange.shade100
                                      : Colors.grey.shade200),
                            border: isCurrent
                                ? Border.all(color: Colors.orange, width: 2)
                                : null,
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: isRewardWeek
                                ? Icon(
                                    Icons.card_giftcard,
                                    color: isCompleted
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                    size: 20,
                                  )
                                : isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    '\$weekNum',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent
                                          ? Colors.orange
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wk \$weekNum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCompleted
                          ? Colors.green
                          : (isCurrent ? Colors.orange : Colors.grey),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildRewardCard(
            title: '12 Weeks',
            reward: 'Next Game is on Us!',
            icon: Icons.sports_tennis,
            color: Colors.orange,
            isNext: true,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildRewardCard(
            title: '24 Weeks',
            reward: 'Special 50% Discount',
            icon: Icons.star,
            color: Colors.purple,
            isNext: false,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard({
    required String title,
    required String reward,
    required IconData icon,
    required Color color,
    required bool isNext,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isNext
            ? Border.all(color: color.withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reward,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF1A202C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade400,
            size: 28,
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Don\'t break the streak!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'If you miss booking a court or matchmaking for an entire week, your streak will reset back to 0. Stay active to unlock rewards!',
                  style: TextStyle(
                    color: Colors.black87,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
