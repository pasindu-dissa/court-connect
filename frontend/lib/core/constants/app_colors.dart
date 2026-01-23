import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Teal)
  static const Color primary = Color(0xFF009688);       // Main Teal
  static const Color primaryDark = Color(0xFF00695C);   // Darker shade for status bars
  static const Color primaryLight = Color(0xFFB2DFDB);  // Light shade for backgrounds/accents
  static const Color accent = Color(0xFFFFC107);        // Amber/Gold for "Winner/Trophy" highlights

  // Neutral Colors (Minimalistic Backgrounds)
  static const Color background = Color(0xFFF8F9FA);    // Very light grey (almost white)
  static const Color surface = Colors.white;            // Card backgrounds
  static const Color error = Color(0xFFD32F2F);         // Red for errors/cancellations

  // Typography Colors
  static const Color textPrimary = Color(0xFF212121);   // Almost black, softer than #000000
  static const Color textSecondary = Color(0xFF757575); // Grey for subtitles
  static const Color textInverse = Colors.white;        // Text on Teal background
}