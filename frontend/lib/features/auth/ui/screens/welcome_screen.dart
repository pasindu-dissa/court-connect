import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/ui/main_wrapper.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // 1. Hero Illustration Area (Placeholder for now)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.sports_tennis_rounded, size: 120, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              
              // 2. Typography
              Text(
                "Find Your Court,\nFind Your Game.",
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "The easiest way to book courts, join teams, and track your stats in real-time.",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),

              // 3. Main CTA
              ElevatedButton(
                onPressed: () {
                  // Navigate to Home
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => const MainWrapper()),
                  );
                },
                child: const Text("Get Started"),
              ),
              const SizedBox(height: 16),
              
              // 4. Secondary CTA
              TextButton(
                onPressed: () {},
                child: Text(
                  "I already have an account",
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}