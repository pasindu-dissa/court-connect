import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/health/data/health_notifier.dart';
import 'interactive_health_card.dart';

class ProfileHealthSection extends StatelessWidget {
  const ProfileHealthSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthNotifier = context.watch<HealthNotifier>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Health & Fitness',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (healthNotifier.isLoading && healthNotifier.isAuthorized)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0F766E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: (!healthNotifier.isAuthorized || healthNotifier.hasError)
                ? _buildPermissionCard(context, healthNotifier)
                : _buildHealthCards(context, healthNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context, HealthNotifier notifier) {
    final bool isConnecting = notifier.isLoading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isConnecting ? Icons.sync : Icons.health_and_safety_outlined,
            size: 40,
            color: Colors.grey.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          Text(
            isConnecting
                ? 'Connecting to health services...'
                : (notifier.errorMessage.isEmpty
                      ? 'Connect your health data to track your performance.'
                      : notifier.errorMessage),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isConnecting ? null : () => notifier.loadAll(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: isConnecting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Allow Access',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCards(BuildContext context, HealthNotifier notifier) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        InteractiveHealthCard(
          title: 'Steps',
          value: notifier.steps.toString(),
          icon: Icons.directions_walk,
          unit: 'today',
          gradient: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
        ),
        InteractiveHealthCard(
          title: 'Calories',
          value: notifier.calories.toStringAsFixed(0),
          icon: Icons.local_fire_department,
          unit: 'kcal',
          gradient: const [Color(0xFF0284C7), Color(0xFF0EA5E9)],
        ),
        InteractiveHealthCard(
          title: 'Heart Rate',
          value: notifier.heartRateData.isEmpty
              ? '--'
              : notifier.heartRateData.last.value.toString(),
          icon: Icons.favorite,
          unit: 'bpm',
          gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
          animateIcon: true,
        ),
        InteractiveHealthCard(
          title: 'Active Time',
          value: (notifier.steps / 100).toStringAsFixed(0),
          icon: Icons.timer_outlined,
          unit: 'mins',
          gradient: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
      ],
    );
  }
}
